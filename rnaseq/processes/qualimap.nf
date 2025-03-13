process qualimap {

        label 'qualimap'

        publishDir "${params.outdir}/output/QC"

        input:
        tuple val(name), path(bam)

	output:
	path("qualimap/*.pdf")
	val("process_complete"), emit: control_6

        script:
        
        """

	samtools sort \
	-n \
	-o ${name}.sortedbyname.bam \
	${bam}

        qualimap rnaseq \
	-bam ${name}.sortedbyname.bam \
	-gtf ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gtf \
	-pe \
	-sorted \
	-outdir qualimap \
	-outfile ${name}

        """
}
