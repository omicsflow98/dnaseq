process sortmerna {

        label 'local'

        publishDir "${params.outdir}/output/sortmerna", mode: 'copy'

        input:
        path fastq

        output:
        path("*.gz"), emit: norrna
        val true, emit: signal

        """
        sortmerna \
        --ref /home/moe001/tools/sortmerna/smr_v4.3_default_db.fasta \
        --reads ${fastq[0]} \
        --reads ${fastq[2]}
        """
}
