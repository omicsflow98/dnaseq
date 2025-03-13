#!/usr/bin/env nextflow

include {runfastqc} from './processes/fastqc.nf'
workflow {

        reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	runfastqc(reads_ch)

}

