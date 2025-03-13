process multiqc {

        label 'multiqc'

        publishDir "${params.outdir}/output/multiqc"

        input:
        val(control_1)
	val(control_2)
	val(control_3)
	val(control_4)
	val(control_5)
	val(control_6)
	val(control_7)
//	val(control_8)

        output:
	path("*.html")
        path("*.zip")

        script:
               
        """
        multiqc --config ${projectDir}/multiqc_config.yaml ${launchDir}/output

	zip -r test_multiqc_report_data.zip test_multiqc_report_data

        """
}
