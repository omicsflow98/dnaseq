#!/usr/bin/env nextflow

include {runfastqc} from './processes/fastqc.nf'
include {trimmomatic} from './processes/trimmomatic.nf'

workflow {

        reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	runfastqc(reads_ch)

	trimmomatic(reads_ch)

}

