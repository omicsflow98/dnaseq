process ballgown {

        label 'DE'

        input:
        path namesave

        output:
	val("process_complete"), emit: control_5

        script:

        """
	#!/usr/bin/env Rscript
	
	library(ballgown)
	library(tidyverse)
	library(metaMA)

	samplenames <- "${namesave}"
	samplenames <- strsplit(samplenames, split = " ")[[1]]

	sampletable <- read.table(file="${launchDir}/ballgown.txt", sep='\\t', header=TRUE)

	samplenames <- samplenames[match(sampletable\$SampID, samplenames)]

	for (condition in colnames(sampletable)[-1]) {

		newtable <- sampletable %>%
			select(SampID, all_of(condition))

		newtable <- newtable %>%
			filter(.[[2]] != 2)

		newtable[,2] <- as.factor(newtable[,2])

		keepsamples <- samplenames[samplenames %in% newtable[,1]]

		keepsamples <- paste0("${params.outdir}/output/stringtie/", keepsamples)

		bg <- ballgown(samples=keepsamples, meas="all")
		bg_filt <- subset(bg, "rowVars(texpr(bg))>1", genomesubset=TRUE)

		pData(bg_filt) <- newtable

		DEres <- stattest(bg_filt, feature='transcript', meas='FPKM', covariate=condition, getFC=TRUE)

		DEres <- data.frame(geneNames=ballgown::geneNames(bg_filt), geneIDs=ballgown::geneIDs(bg_filt),DEres)

		DEres[,'log2fc'] <- log2(DEres[,'fc'])

		DEres <- DEres[, c('geneNames', 'geneIDs', 'feature', 'id', 'fc', 'log2fc', 'pval', 'qval')]

		DEres <- arrange(DEres, qval)

		#novel_gene <- DEres %>%
		#	filter(startsWith(geneNames, "MSTRG") | startsWith(geneNames, "."))

		#known_gene <- DEres %>%
		#	filter(!startsWith(geneNames, "MSTRG") & !startsWith(geneNames, "."))
		#known_gene\$geneNames <- sub("^([^\\\\.]+\\\\.[^\\\\.]+).*", "\\\\1", known_gene\$geneIDs)

		final_path <- file.path("${launchDir}", "output", "DE", condition, "ballgown")

                dir.create(final_path, recursive=TRUE)

                #full_path <- file.path(final_path, "mapped_genes.csv")
		full_path <- file.path(final_path, "DTE.csv")

                #write.csv(known_gene, file=full_path, row.names=FALSE, quote=FALSE)
		write.csv(DEres, file=full_path, row.names=FALSE, quote=FALSE)
                #full_path <- file.path(final_path, "unmapped_genes.csv")

                #write.csv(novel_gene, file=full_path, row.names=FALSE, quote=FALSE)


	}

        """
}
