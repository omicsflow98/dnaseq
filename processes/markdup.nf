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
	--remove-all-duplicates false \
	--read-validation-stringency SILENT \
	--input ${bam} \
	--tmp-dir \$TMPDIR \
	--spark-master local[*] \
	--metrics-file ${name}.markdup.txt \
	--output ${name}.markdup.bam

	gatk CollectBaseDistributionByCycleSpark \
	--chart ${name}.pdf \
	--tmp-dir \$TMPDIR \
	--spark-master local[*] \
	--input ${name}.markdup.bam \
	--output ${name}.txt

        """
}
