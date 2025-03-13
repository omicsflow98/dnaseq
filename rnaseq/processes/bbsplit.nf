process bbsplit {

        label 'bbsplit'

        publishDir "${params.outdir}/output/bbsplit"

        input:
        path fastq

        output:
        path("*_norrna.fastq.gz"), emit: no_rrna
        path("*_junk.fastq.gz"), emit: junk

        script:

        def name0 = fastq[0].toString().replaceAll(/.fastq.gz/, "")
        def name1 = fastq[1].toString().replaceAll(/.fastq.gz/, "")

        """
	bbsplit.sh \
        ref=/home/moe001/tools/sortmerna/smr_v4.3_default_db.fasta \
        in1=${fastq[0]} \
        in2=${fastq[1]} \
        basename=%_junk.fastq.gz \
        outu1=${name0}_norrna.fastq.gz \
        outu2=${name1}_norrna.fastq.gz

        """

}
