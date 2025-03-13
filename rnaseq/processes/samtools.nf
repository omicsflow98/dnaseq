process samtools {

        label 'samtools'

        publishDir "${params.outdir}/output/markdup"

        input:
	tuple val(names), path(bam)

        output:
        path("*.csi"), emit: index
	path("*.bai")
	path("*.idx"), emit: stats
	val("process_complete"), emit: control_3

        script:

        """
        samtools index \
	-c \
	-o ${bam}.csi \
	${bam}

	samtools index \
	-b \
	-o ${bam}.bai \
	${bam}

	samtools idxstats ${bam} > ${bam}.idx 

        """
}
