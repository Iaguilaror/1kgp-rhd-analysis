/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process estcnv {

    publishDir "${params.results_dir}/03-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path( all_materials )

    output:
        path "*", emit: results_estcnv

    script:
    """
    Rscript --vanilla *.R *.bam
    """

}

/* name a flow for easy import */
workflow ESTCNV {

 take:
    all_materials

 main:

    estcnv( all_materials )

  emit:
    estcnv.out[0]

}
