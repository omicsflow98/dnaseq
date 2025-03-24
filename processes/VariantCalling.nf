process gvcf {

	label 'gvcf'

        publishDir "${params.outdir}/output/gvcf/"

        input:
        tuple val(name), path(bam)

        output:
        tuple val(name), path("*.vcf.gz"), emit: vcf_files

        script:

        """
	gatk HaplotypeCaller \
        --input ${bam} \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --output ${name}.vcf.gz \
        --tmp-dir \$TMPDIR \
        -ERC GVCF

        """
}
