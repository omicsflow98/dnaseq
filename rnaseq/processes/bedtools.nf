process bedtools {

        label 'bedtools'

	publishDir "${params.outdir}/output/bigwig"

        input:
        tuple val(name), path(bam)

        output:
        path("*.sort.bedgraph"), emit: bedtools
        
        script:
        
        """
        genomeCoverageBed \
	-bga \
        -ibam ${bam} | sort -k1,1 -k2,2n > ${name}.sort.bedgraph  

        """
}

