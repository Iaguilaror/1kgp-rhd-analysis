/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process estcnv2 {

    publishDir "${params.results_dir}/04-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path( all_materials )

    output:
        path "*", emit: results_estcnv2

    script:
    """
    Rscript --vanilla *.R *.tsv
    """

}

/* name a flow for easy import */
workflow ESTCNV2 {

 take:
    all_materials

 main:

    estcnv2( all_materials )

  emit:
    estcnv2.out[0]

}
