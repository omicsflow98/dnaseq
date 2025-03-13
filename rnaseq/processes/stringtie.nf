process stringtie {

        label 'stringtie'

        input:
        tuple val(name), path(bam)

        output:
        path("*.gtf"), emit: diffexp

	publishDir "${params.outdir}/output/stringtie/${name}"

        script:
       
        """
        stringtie \
	-G ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gff3 \
	-o ${name}.gtf \
	${bam}

        """
}

process stringtie_merge {

	label 'stringtie'

	publishDir "${params.outdir}/output/stringtie"

	input:
	path stringtie

	output:
	path("merged.annotated.gtf"), emit: annotation
	path("merged*"), emit: stats

	script:

	"""
	stringtie \
        --merge ${stringtie} \
	-G ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gff3 \
	-o stringtie_merged.gtf

	gffcompare \
	-r ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gff3 \
	-R \
	-o merged \
	stringtie_merged.gtf

	"""

}

process stringtie_abund {

	label 'stringtie'

        input:
	path mergedgtf
        tuple val(name), path(bam)

	output:
	path("*.tsv"), emit: expression
	path("*.ctab"), emit: ballgown
	val(namesave)
	path("*.gtf"), emit: gtf_file

	publishDir "${params.outdir}/output/stringtie/${name}"
	
	script:

	namesave="${params.outdir}/output/stringtie/${name}"

	"""
	stringtie \
        -e -B \
	-G ${mergedgtf} \
	-A expression.tsv \
	-o ${name}.gtf \
        ${bam}

	"""
}
