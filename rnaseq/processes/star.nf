process STAR_run1 {

	label 'STAR'

        publishDir "${params.outdir}/output/STAR/firstpass"

        input:
        path fastq

        output:
        path("*.out.tab"), emit: tab_files

        script:
        def namepair = fastq[0].toString().replaceAll(/_R1_P_norrna.fastq.gz/, "")

        """
	read LibName Barcode Platform <<< \$(awk -v n="${namepair}" '\$1 == n {print \$2, \$3, \$4}' ${launchDir}/info.tsv)

        STAR \
        --runMode alignReads \
        --genomeDir ${projectDir}/../../reference/${params.species}/${params.refversion}/index/STAR_index \
        --readFilesCommand gunzip -c \
	--runThreadN 4 \
	--outSAMunmapped Within \
        --outSAMtype BAM Unsorted \
        --outFileNamePrefix ${namepair}_ \
        --outSAMattrRGline ID:${namepair}      PL:\$Platform   PU:\$Barcode    LB:\$LibName    SM:${namepair} \
        --readFilesIn ${fastq[0]} ${fastq[1]}

        """
}

process STAR_genome {

	label 'STAR_REF'

	publishDir "${params.outdir}/output/STAR/newref"

	input:
	path tabfiles

	output:
	path("*"), emit: starindex
	val("Ready"), emit: control

	script:

	"""

	STAR \
	--runMode genomeGenerate \
	--genomeDir . \
	--runThreadN 4 \
	--genomeFastaFiles ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.fa \
	--sjdbFileChrStartEnd ${tabfiles} \
	--sjdbGTFfile ${projectDir}/../../reference/${params.species}/${params.refversion}/genome.gff3 \
	--sjdbGTFtagExonParentTranscript Parent \
	--sjdbOverhang 99 \
	--genomeSAindexNbases 13

	"""

}

process STAR_run2 {

        label 'STAR'

        publishDir "${params.outdir}/output/STAR/aligned", mode: 'copy'

        input:
        path fastq
	val ready

        output:
        tuple val(namepair), path("*.sortedByCoord.out.bam"), emit: gene_aligned
	path("*.sortedByCoord.out.bam"), emit: bam
	path("*.out")

        script:
        namepair = fastq[0].toString().replaceAll(/_R1_P_norrna.fastq.gz/, "")
	
        """
	read LibName Barcode Platform <<< \$(awk -v n="${namepair}" '\$1 == n {print \$2, \$3, \$4}' ${launchDir}/info.tsv)

        STAR \
	--runMode alignReads \
	--genomeDir ${params.outdir}/output/STAR/newref \
        --runThreadN 4 \
	--readFilesCommand gunzip -c \
	--outSAMunmapped Within \
        --outSAMtype BAM SortedByCoordinate \
        --outFileNamePrefix ${namepair}_ \
	--outSAMattrRGline ID:${namepair}	PL:\$Platform	PU:\$Barcode	LB:\$LibName	SM:${namepair} \
        --readFilesIn ${fastq[0]} ${fastq[1]}

        """
}
