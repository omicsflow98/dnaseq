process trimmomatic {
        
        label 'trimmomatic'

        publishDir "${params.outdir}/output/trimmed_fastq"

        input:
        tuple val(sample_id), path(reads)

        output:
        path("*_P.fastq.gz"), emit: trimmed_fastq
	path("*.log")

        """
        trimmomatic PE \
        -phred33 \
	-threads 4 \
        ${reads[0]} \
        ${reads[1]} \
        ${sample_id}_R1_P.fastq.gz \
        ${sample_id}_R1_U.fastq.gz \
        ${sample_id}_R2_P.fastq.gz \
        ${sample_id}_R2_U.fastq.gz \
        ILLUMINACLIP:${launchDir}/adapter.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36 2> ${sample_id}.log
        """ 

}
