process bwa {

	label 'bwa'

        publishDir "${params.outdir}/output/bwa"

        input:
        path fastq

        output:
        path("*.bam"), emit: bam_files

        script:
        def namepair = fastq[0].toString().replaceAll(/.fastq.gz/, "")

        """
        read LibName Barcode Platform <<< \$(awk -v n="${namepair}" '\$1 == n {print \$2, \$3, \$4}' ${launchDir}/info.tsv)

        bwa mem \
        ${launchDir}/../../reference/${params.species}/${params.refversion}/index/bwa/genome.fa \
        ${fastq[0]} \
        ${fastq[1]} \
        -t 8 \
        -p \
        -R '@RG\\tID:${namepair}\\tPL:\$Platform\\tPU:\$Barcode\\tLB:\$LibName\\tSM:${namepair}'
        
        """
}
