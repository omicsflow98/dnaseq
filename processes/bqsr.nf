process BQSR {

	label 'bqsr'

        publishDir "${params.outdir}/output/bqsr/"

        input:
        tuple val(name), path(bam)

        output:
        tuple val(name), path("*.recal.bam"), emit: bam_bqsr

        script:

        """
	gatk \
	--java-options "-Djava.io.tmpdir=\$TMPDIR" \
	BaseRecalibratorSpark \
        --input ${bam} \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --known-sites ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.vcf \
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
