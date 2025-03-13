process deseq2 {

	label 'DE'

	input:
	path counts

	output:
	val("process_complete"), emit: control_7

	script:

	"""
	#!/usr/bin/env Rscript

	library(DESeq2)
	library(tidyverse)

	dir.create(file.path("${launchDir}", "output", "DE"))

	countfile <- as.matrix(read.csv("${counts}",sep="\\t",row.names="Geneid",check.names=FALSE))
	sampletable <- read.table(file="${launchDir}/ballgown.txt", sep='\\t', header=TRUE)
	rownames(sampletable) <- sampletable\$SampID
	sampletable\$SampID <- NULL

	countfile <- countfile[, match(rownames(sampletable), colnames(countfile))]
	
	for (condition in colnames(sampletable)) {

		newtable <- sampletable %>%
			select(all_of(condition))

		newtable[,1] <- as.factor(newtable[,1])

		newtable <- newtable %>%
			filter(.[[1]] != 2)
		
		countnew <- countfile[, colnames(countfile) %in% rownames(newtable)]
		
		colnameformula <- as.formula(paste("~", colnames(newtable)[1]))

		dds <- DESeqDataSetFromMatrix(countData=countnew, colData=newtable, design=colnameformula)
		dds <- DESeq(dds)
		res <- results(dds)
		res <- as.data.frame(res)
		res <- arrange(res,padj)
		res\$geneIDs <- rownames(res)
		res <- res %>% relocate(geneIDs)

		final_path <- file.path("${launchDir}", "output", "DE", condition, "deseq")

		dir.create(final_path, recursive=TRUE)
		full_path <- file.path(final_path, "DGE.csv")

		write.csv(res, file=full_path, row.names=FALSE, quote=FALSE)

	}

	"""
}



process edger {

label 'DE'

        publishDir "${params.outdir}/output/DGE/edger"

        input:
        path genes

        output:
        path("*.csv")
	val("process_complete"), emit: control_8

        script:

	def names = genes.toString().replaceAll(/.genes.results/, "")

	"""
	#!/usr/bin/env Rscript

	library(edgeR)
	library(tidyverse)
	library(tximport)

	samples <- c("${names}")
        rsem <- c("${genes}")

        rsem <- unlist(strsplit(rsem, " "))
	samples <- unlist(strsplit(samples, " "))

	names(rsem) <- samples

	sampletable <- read.table(file="${launchDir}/ballgown.txt", sep='\\t', header=TRUE)
	rownames(sampletable) <- sampletable\$SampID
	sampletable\$SampID <- NULL

	for (condo in colnames(sampletable)) {

		newtable <- sampletable %>%
			select(all_of(condo))

		newtable[,1] <- as.factor(newtable[,1])
		
		newtable <- newtable %>%
			filter(.[[1]] != 2)
		
		print(newtable)
		
		rsemout <- rsem[names(rsem) %in% rownames(newtable)]

		txi <- tximport(rsemout, type="rsem", txIn=FALSE, txOut=FALSE)
		
	        unexpressed <- (apply(txi\$abundance, 1, max) == 0) & (apply(txi\$length, 1, min) == 0)

		txi\$length <- txi\$length[!unexpressed, ]
		txi\$abundance <- txi\$abundance[!unexpressed, ]
		txi\$counts <- txi\$counts[!unexpressed, ]

		colnames(txi\$counts) <- rownames(newtable)

		cts <- txi\$counts
		normMat <- txi\$length

		normMat <- normMat/exp(rowMeans(log(normMat)))
		normCts <- cts/normMat

		eff.lib <- calcNormFactors(normCts)*colSums(normCts)

		normMat <- sweep(normMat, 2, eff.lib, "*")
		normMat <- log(normMat)

		dgelist <- DGEList(cts)

		dgelist\$samples\$lib.size <- colSums(dgelist\$counts)

		dgelist <- calcNormFactors(dgelist, method="TMM")

		newtable_formula <- as.formula(paste("~", newtable[,1]))

		design <- model.matrix(~get(condo), data=newtable)
		
		print(head(design))
		print(head(txi\$counts))

		rownames(design) <- colnames(txi\$counts)

		print("one")

		dgelist <- estimateDisp(dgelist, design, robust=TRUE)

		print("two")

		fit <- glmFit(dgelist, design)
		lrt <- glmLRT(fit)

		print("three")

		de_table <- lrt[["table"]]
		de_table\$geneIDs <- rownames(de_table)
		de_table <- de_table %>% relocate(geneIDs)

		print("four")

		BH <- p.adjust(de_table\$PValue, method="BH")
		de_table\$padj <- BH
		de_table <- de_table %>% relocate(padj, .after = PValue)

		novel_gene <- de_table %>%
			filter(startsWith(geneIDs, "MSTRG"))
	
		known_gene <- de_table %>%
			filter(!startsWith(geneIDs, "MSTRG"))
		known_gene\$geneIDs <- sub("^([^\\\\.]+\\\\.[^\\\\.]+).*", "\\\\1", known_gene\$geneIDs)

		write.csv(known_gene, paste0(condo, 'edger_mapped_genes.csv'), row.names=FALSE, quote=FALSE)
		write.csv(novel_gene, paste0(condo, 'edger_unmapped_genes.csv'), row.names=FALSE, quote=FALSE)
	
	}


	"""

}
