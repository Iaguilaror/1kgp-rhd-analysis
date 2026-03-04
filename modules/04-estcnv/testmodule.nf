/* Initiate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { ESTCNV2 }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.tsv" )
        // .toList()
//	.view( )
        .set { cov_channel }

/* declare scripts channel for testing */
estcnv2_script = Channel.fromPath( "scripts/04-estcnv2.R" )

all_materials = estcnv2_script.combine( cov_channel )

workflow {
  ESTCNV2( all_materials )
}
