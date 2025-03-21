process markduplicates {

	label 'markdup'

        publishDir "${params.outdir}/output/markdup"

        input:
        tuple val(name), path(bam)

        output:
        tuple val(name), path("*.markdup.bam"), emit: mark_dup
	path("*.txt"), emit: metrics

        script:
       
	"""

	gatk MarkDuplicatesSpark \
	--REMOVE_DUPLICATES false \
	--VALIDATION_STRINGENCY SILENT \
	--INPUT ${bam} \
	--TMP_DIR \$TMPDIR \
	--spark-master local[*] \
	--METRICS_FILE ${name}.markdup.txt \
	--OUTPUT ${name}.markdup.bam

	gatk CollectBaseDistributionByCycleSpark \
	-CHART ${name}.pdf \
	--TMP_DIR \$TMPDIR \
	--spark-master local[*]
	-I ${name}.markdup.bam \
	-O ${name}.txt

        """
}
