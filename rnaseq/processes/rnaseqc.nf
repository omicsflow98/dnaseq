process rnaseqc {

        label 'rnaseqc'

        publishDir "${params.outdir}/output/rnaseqc"

        input:
        tuple val(name), path(bam)

        output:
        path("*.metrics.tsv")
	path("*.exon_reads.gct")
	path("*.gene_reads.gct")
	path("*.gene_tpm.gct")
	path("*.fragmentSizes.txt")
	path("*.coverage.tsv")
	val("process_complete"), emit: control_2

        script:
       
        """
        rnaseqc \
	${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gtf \
	${bam} \
	--bed ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.bed12 \
	--coverage \
	.

        """
}
