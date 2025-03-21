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
        -I ${bam} \
        -R ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --known-sites ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.vcf \
        --TMP_DIR \$TMPDIR \
	--spark-master local[*] 
        -O ${name}.table

        gatk ApplyBQSRSpark \
        -I ${bam} \
        -R ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --bqsr-recal-file ${name}.table \
        --TMP_DIR \$TMPDIR \
	--spark-master local[*]
        -O ${name}.recal.bam

        """
}
