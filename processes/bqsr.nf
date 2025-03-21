process BQSR {

	label 'bqsr'

        publishDir "${params.outdir}/output/bqsr/"

        input:
        tuple val(name), path(bam)

        output:
        path("*.recal.bam"), emit: tab_files

        script:

        """
	gatk BaseRecalibratorSpark \
        --input ${bam} \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --known-sites ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.vcf \
        --TMP_DIR \$TMPDIR \
	--spark-master local[*] \
        --output ${name}.table

        gatk ApplyBQSRSpark \
        --input ${bam} \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --bqsr-recal-file ${name}.table \
        --tmp-dir \$TMPDIR \
	--spark-master local[*] \
        --output ${name}.recal.bam

        """
}
