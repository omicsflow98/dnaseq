process runfastqc {
        
        label 'fastqc'
       
        publishDir "${params.outdir}/output/fastqc", mode: 'move'

        input:
        tuple val(sample_id), path(reads)

        output:
        path("*.{html,zip}")
	val("process_complete"), emit: control_1

        """
        fastqc -o . \
        ${reads[0]} \
        ${reads[1]}
        """

}
