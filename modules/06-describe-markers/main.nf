/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process describe {

    publishDir "${params.results_dir}/06-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
    path( marker_script )
    path( cnv_channel )
    path( snv_channel )
    path( ref_channel )

    output:
        path "*", emit: results_describe

    script:
    """
    Rscript --vanilla $marker_script $cnv_channel $snv_channel $ref_channel
    """

}

/* name a flow for easy import */
workflow DESCRIBE {

 take:
    marker_script
    cnv_channel
    snv_channel
    ref_channel

 main:

    describe( marker_script, cnv_channel, snv_channel, ref_channel )

  emit:
    describe.out[0]

}
