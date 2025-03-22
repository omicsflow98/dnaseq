process bwa {

	label 'bwa'

        publishDir "${params.outdir}/output/bwa"

        input:
        path fastq

        output:
        tuple val(namepair), path("*.sortedByCoord.out.bam"), emit: bam_files

        script:
        namepair = fastq[0].toString().replaceAll(/_R1_P.fastq.gz/, "")

        """
        read LibName Barcode Platform <<< \$(awk -v n="${namepair}" '\$1 == n {print \$2, \$3, \$4}' ${launchDir}/info.tsv)

        bwa mem \
        ${launchDir}/../../reference/${params.species}/${params.refversion}/index/bwa/genome.fa \
        ${fastq[0]} \
        ${fastq[1]} \
        -t 8 \
        -p \
        -R '@RG\\tID:${namepair}\\tPL:\$Platform\\tPU:\$Barcode\\tLB:\$LibName\\tSM:${namepair}' > ${namepair}.bam

	samtools sort \
	-o ${namepair}.sortedByCoord.out.bam \
	-O bam \
	--threads 7 \
	${namepair}.bam
        
        """
}
