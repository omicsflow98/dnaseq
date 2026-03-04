process bwa {

	label 'bwa'

        publishDir "${params.main.outdir}/output/bwa"

        input:
        path bwa_index
	tuple val(SampName), val(LibName), val(Barcode), val(Platform), path(fastq)

        output:
        tuple val(SampName), path("*.sortedByCoord.out.bam"), emit: bam_files

        script:
        def idxbase = bwa_index[0].baseName
        """
        bwa mem \
        ${idxbase} \
        ${fastq[0]} \
        ${fastq[1]} \
        -t 16 \
        -R "@RG\\tID:${SampName}\\tPL:${Platform}\\tPU:${Barcode}\\tLB:${LibName}\\tSM:${SampName}" | \
        samtools sort \
        -o ${SampName}.sortedByCoord.out.bam \
	-O bam \
	--threads 6

        """
}
