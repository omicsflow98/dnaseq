process featurecounts {

	label 'featurecounts'
	
	publishDir "${params.outdir}/output/featurecounts"
	
	input:
	path bam
	
	output:
	path("counts.tsv"), emit: counts
	path("*.summary")
	
	script:

	"""
	featureCounts -p \
	--countReadPairs \
	-O \
	-a ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gtf \
	-o temp.tsv \
	${bam}

	tail -n +2 temp.tsv | \
	cut -d\$'\\t' -f2-6 --co | \
	sed '1s/\\([^[:space:]]*\\)_[^[:space:]]*/\\1/g' > counts.tsv 
	
	"""
	
}
