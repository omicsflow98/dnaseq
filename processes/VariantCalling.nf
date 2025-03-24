process gvcf {

	label 'gvcf'

        publishDir "${params.outdir}/output/gvcf/"

        input:
        tuple val(name), path(bam)

        output:
        path("*.vcf.gz"), emit: vcf_files

        script:

        """
	gatk \
	--java-options "-Xmx12G" \
	HaplotypeCaller \
        --input ${bam} \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
        --output ${name}.g.vcf.gz \
        --tmp-dir \$TMPDIR \
        -ERC GVCF

        """
}

process mergedgvcf {

	label 'gvcf_merge'

        publishDir "${params.outdir}/output/gvcf_merged/"

        input:
        path vcf

        output:
        path("*.vcf.gz"), emit: merged_vcf

        script:

        """
	gatk \
	--java-options "-Xmx32G" \
	GenomicsDBImport \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
	--genomicsdb-workspace-path my_genomicsdb \
	--intervals ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.list \
	--variant ${vcf} \
	--reader-threads 8 \
	--tmp-dir \$TMPDIR

	gatk \
	--java-options "-Xmx32G" \
	GenotypeGVCFs \
	--reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
	--variant gendb://my_genomicsdb \
	--output merged.vcf.gz

        """
}
