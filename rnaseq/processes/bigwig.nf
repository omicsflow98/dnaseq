process bigwig {

        label 'bigwig'

        publishDir "${params.outdir}/output/bigwig"

        input:
        path bedgraph

        output:
        path("*.bw"), emit: bigwig
	val("process_complete"), emit: control_4
	
	script:

	def name = bedgraph.toString().replaceAll(/.sort.bedgraph/, "")	

        """
	bedGraphToBigWig ${bedgraph} \
	${projectDir}/../../reference/${params.species}/${params.refversion}/index/samtools/genome.sizes \
	${name}.bw
        """

}
