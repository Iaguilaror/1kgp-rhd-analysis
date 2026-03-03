/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process dwbam {

    publishDir "${params.results_dir}/02-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    tag "$vcf"

    input:
      tuple path(link), path(script)

    output:
        path "*", emit: results_dwbam

    script:
    """
	ls > tmp
    """

}

/* name a flow for easy import */
workflow DWBAM {

 take:
    materials

 main:

    dwbam( materials )

  emit:
    dwbam.out[0]

}
