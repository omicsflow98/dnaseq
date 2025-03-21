process BQSR {

	label 'bqsr'

        publishDir "${params.outdir}/output/bqsr/"

        input:
        tuple val(name), path(bam)

        output:
        path("*.recal.bam"), emit: tab_files

        script:

        """
	gatk BaseRecalibrator \
        -I ${bam} \
        -R ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --known-sites ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.vcf \
        --TMP_DIR \$TMPDIR \
        -O ${name}.table

        gatk ApplyBQSR \
        -I ${bam} \
        -R ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --bqsr-recal-file ${name}.table \
        --TMP_DIR \$TMPDIR \
        -O ${name}.recal.bam

        """
}
