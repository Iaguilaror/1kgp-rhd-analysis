# load pkgs
pacman::p_load( "ggplot2", "dplyr", "vroom", "tidyr" )

# 1) Receive arg from command line
args <- commandArgs( trailingOnly = TRUE )

# for debug only
# args[ 1 ] <- "1000G_2504_high_coverage.sequence.index"

samplefile <- args[ 1 ]

# load data
samples.df <- vroom( file = samplefile, delim = "\t",
                     comment = "#", col_names = FALSE ) %>% 
  select( X10, X11 ) %>% 
  rename( "sample" = 1,
          "pop" = 2 )

samples.df 

# load all cnv data
all_dp.v <- list.files( path = ".",
                        pattern = ".*_meancov.tsv" )

alldp.df <- vroom( file = all_dp.v,
                   # id = "test",
                   show_col_types = FALSE )

wide.df <- alldp.df %>% 
  pivot_wider( id_cols = sample,
               names_from = "region",
               values_from = "mean_rpkb" ) %>% 
  rowwise( ) %>% 
  mutate( mean_flanks = mean( c( upstream, downstream ), na.rm = TRUE ) ) %>% 
  ungroup( ) %>% 
  mutate( gene2flank_ratio = gen / mean_flanks,
          gene2flank_ratio = round( gene2flank_ratio, digits = 2 ) )

# annotate samples
wide_ann.df <- wide.df %>% 
  left_join( x = .,
             y = samples.df,
             by = "sample" )

# save the df
vroom_write( x = wide_ann.df,
             file = "all_covratio.tsv" )

# plot qc
qcpanel.p <- ggplot( data = wide_ann.df,
                     mapping =  aes( x = gene2flank_ratio * 2 ) ) +
  geom_histogram( binwidth = 0.3, fill = "cornflowerblue", color = "white" ) +
  scale_x_continuous( limits = c( 0, 2.5 ),
breaks = seq( 0, 2.5, by = 0.5 ),
labels = c( "0", ".5", "1", "1.5", "2", "2.5" ) ) +
  theme_classic( base_size = 20 ) +
  facet_wrap( ~pop, scales = "free" )

ggsave( plot = qcpanel.p, filename = "qcpanel.png", width = 15, height = 15 )
