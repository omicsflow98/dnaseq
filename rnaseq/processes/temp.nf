process markduplicates {

        label 'markdup'

        publishDir "${params.outdir}/output/markdup"

        input:
        path bam

        output:
        tuple val(name), path("*.markdup.bam"), emit: mark_dup
	path("*.txt"), emit: metrics

        script:

	name = bam.toString().replaceAll(/_Aligned.sortedByCoord.out.bam/, "")
	
       
	"""
	read LibName Barcode Platform <<< \$(awk -v n="${name}" '\$1 == n {print \$2, \$3, \$4}' ${launchDir}/info.tsv)

	gatk AddOrReplaceReadGroups \
	-I ${bam} \
	-O ${bam}_RG \
	-RGLB \$LibName \
	-RGPL \$Platform \
	-RGPU \$Barcode \
	-RGSM ${name}

	gatk MarkDuplicates \
	--REMOVE_DUPLICATES false \
	--VALIDATION_STRINGENCY SILENT \
	--INPUT ${bam}_RG \
	--METRICS_FILE ${name}.markdup.txt \
	--OUTPUT ${name}.markdup.bam

	gatk CollectBaseDistributionByCycle \
	-CHART ${name}.pdf \
	-I ${name}.markdup.bam \
	-O ${name}.txt

        """
}
