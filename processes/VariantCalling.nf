process gvcf {

	label 'gvcf'

        publishDir "${params.outdir}/output/gvcf/"

        input:
        tuple val(name), path(bam)

        output:
        tuple path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf_files

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

	gatk IndexFeatureFile \
	--input ${name}.g.vcf.gz

        """
}

process mergedgvcf {

	label 'gvcf_merge'

        publishDir "${params.outdir}/output/gvcf_merged/"

        input:
        path(vcf_index)

        output:
        path("*.vcf.gz"), emit: merged_vcf

        script:
	
	def only_vcf = vcf_index.findAll{!it.name.endsWith('.tbi')}

        def sampleList = only_vcf.collect { file ->
                def base_name = file.name.replace('.g.vcf.gz', '')
                "${base_name}\t${file.name}"
        }.join("\n")	

        """
	echo "${sampleList}" > samples.map

	gatk \
	--java-options "-Xmx32G" \
	GenomicsDBImport \
        --reference ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
	--genomicsdb-workspace-path my_genomicsdb \
	--intervals ${launchDir}/../../reference/${params.species}/${params.refversion}/genome.list \
	--sample-name-map samples.map \
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
