#!/usr/bin/env nextflow

include {runfastqc} from './processes/fastqc.nf'
include {trimmomatic} from './processes/trimmomatic.nf'
include {bwa} from './processes/bwa.nf'
include {markduplicates} from './processes/markdup.nf'
include {BQSR} from './processes/bqsr.nf'
include {gvcf} from './processes/VariantCalling.nf'

workflow {

        reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	runfastqc(reads_ch)

	trimmomatic(reads_ch)

	bwa(trimmomatic.out.trimmed_fastq)

	markduplicates(bwa.out.bam_files)

	BQSR(markduplicates.out.mark_dup)

	gvcf(BQSR.out.bam_bqsr)
}

