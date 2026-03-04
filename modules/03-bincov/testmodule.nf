/* Initiate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { ESTCNV }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.bam" )
        // .toList()
//	.view( )
        .set { bam_channel }

/* declare scripts channel for testing */
estcnv_script = Channel.fromPath( "scripts/03-estcnv.R" )

all_materials = estcnv_script.combine( bam_channel )

workflow {
  ESTCNV( all_materials )
}
