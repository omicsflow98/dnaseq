#!/usr/bin/env nextflow

include {runfastqc} from './processes/fastqc.nf'
include {trimmomatic} from './processes/trimmomatic.nf'
include {samtools} from './processes/samtools.nf'
include {markduplicates} from './processes/markdup.nf'
include {bedtools} from './processes/bedtools.nf'
include {bigwig} from './processes/bigwig.nf'
include {qualimap} from './processes/qualimap.nf'
include {multiqc} from './processes/multiqc.nf'

workflow {

        reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	runfastqc(reads_ch)

	trimmomatic(reads_ch)

//	bbsplit(trimmomatic.out.trimmed_fastq)

//	STAR(bbsplit.out.no_rrna)

//	rsem(STAR.out.transcript_aligned)

//	rsem.out.genes
//	| collect
//	| set { gene_files }

	markduplicates(STAR.out.gene_aligned)

//	rnaseqc(markduplicates.out.mark_dup)

	samtools(markduplicates.out.mark_dup)

	bedtools(markduplicates.out.mark_dup)

	bigwig(bedtools.out.bedtools)

//	gtf_files = stringtie(markduplicates.out.mark_dup).collect()

//	stringtie_merge(gtf_files)

//	stringtie_abund(stringtie_merge.out.annotation, markduplicates.out.mark_dup)

//	stringtie_abund.out[2]
//	| collect
//	| set { namesave }

	qualimap(markduplicates.out.mark_dup)

//	ballgown(namesave)

//	deseq2(gene_files)

//	edger(gene_files)

	multiqc(runfastqc.out.control_1.collect(), rnaseqc.out.control_2.collect(), samtools.out.control_3.collect(), bigwig.out.control_4.collect(), ballgown.out.control_5, qualimap.out.control_6.collect(), deseq2.out.control_7)

}

