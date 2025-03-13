#!/usr/bin/env nextflow

include {runfastqc} from './processes/fastqc.nf'
include {trimmomatic} from './processes/trimmomatic.nf'
include {bbsplit} from './processes/bbsplit.nf'
include {STAR_run1} from './processes/star.nf'
include {STAR_run2} from './processes/star.nf'
include {STAR_genome} from './processes/star.nf'
include {samtools} from './processes/samtools.nf'
include {featurecounts} from './processes/featurecounts.nf'
include {markduplicates} from './processes/markdup.nf'
include {bedtools} from './processes/bedtools.nf'
include {bigwig} from './processes/bigwig.nf'
include {stringtie} from './processes/stringtie.nf'
include {stringtie_merge} from './processes/stringtie.nf'
include {stringtie_abund} from './processes/stringtie.nf'
include {qualimap} from './processes/qualimap.nf'
include {ballgown} from './processes/ballgown.nf' 
include {deseq2} from './processes/DGE.nf'
include {edger} from './processes/DGE.nf'
include {rnaseqc} from './processes/rnaseqc.nf'
include {multiqc} from './processes/multiqc.nf'

workflow {

        reads_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

	runfastqc(reads_ch)

	trimmomatic(reads_ch)

	bbsplit(trimmomatic.out.trimmed_fastq)

	STAR_run1(bbsplit.out.no_rrna)

	STAR_run1.out.tab_files
	| collect
	| set { tab_files }

	STAR_genome(tab_files)

	STAR_run2(bbsplit.out.no_rrna, STAR_genome.out.control)

	markduplicates(STAR_run2.out.gene_aligned)

	rnaseqc(STAR_run2.out.gene_aligned)

	samtools(STAR_run2.out.gene_aligned)

	bedtools(STAR_run2.out.gene_aligned)

	bigwig(bedtools.out.bedtools)

	stringtie(STAR_run2.out.gene_aligned)
	
	stringtie.out.diffexp
	| collect
	| set { gtf_files }

	stringtie_merge(gtf_files)

	stringtie_abund(stringtie_merge.out.annotation, STAR_run2.out.gene_aligned)

	stringtie_abund.out[2]
	| collect
	| set { namesave }

	qualimap(STAR_run2.out.gene_aligned)

	ballgown(namesave)

	STAR_run2.out.bam
	| collect
	| set { bam_files }

	featurecounts(bam_files)

	deseq2(featurecounts.out.counts)

//	edger(featurecounts.out.counts)

	multiqc(runfastqc.out.control_1.collect(), rnaseqc.out.control_2.collect(), samtools.out.control_3.collect(), bigwig.out.control_4.collect(), ballgown.out.control_5, qualimap.out.control_6.collect(), deseq2.out.control_7)

}

