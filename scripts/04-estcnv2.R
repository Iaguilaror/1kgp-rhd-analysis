# load pkgs
pacman::p_load( "ggplot2", "dplyr", "vroom" )

# 1) Receive arg from command line
args <- commandArgs( trailingOnly = TRUE )

# for debug only
# args[ 1 ] <- "HG00107_subset.bam_readsperkb.tsv"

tsvfile <- args[ 1 ]

sampleid <- unlist( strsplit( tsvfile, split = "_" ) )[ 1 ]

# define params for limits of CNV
gen_start <- 25272393
gen_end <- 25330445

# read the dp file
read.df <- vroom( file = tsvfile ) %>% 
  as_tibble( )

# tag the gene limits
tag.df <- read.df %>% 
  mutate( region = case_when( position < gen_start ~ "upstream",
                              position >= gen_start & position <= gen_end ~ "gen",
                              position > gen_end ~ "downstream" ) ) %>% 
  group_by( region ) %>% 
  mutate( mean_rpkb = mean( depth ) ) %>% 
  ungroup( ) %>% 
  mutate( region = factor( region, levels = c( "upstream", "gen", "downstream" ) ) )

# plot
cov.p <- ggplot( data = tag.df,
                 mapping = aes( x = position,
                                y = depth,
                                fill = region ) ) +
  geom_col( color = NA ) +
  geom_vline( xintercept = c( gen_start, gen_end ), lty = 2, alpha = 0.5 ) +
  geom_point( mapping = aes( y = mean_rpkb ), shape = 15, size = 0.5 ) +
  scale_fill_manual( values = c( "skyblue", "steelblue", "skyblue" ) ) +
  labs( title = sampleid ) +
  theme_void( base_size = 15 ) +
  theme( legend.position = "none",
         # plot.title =  element_text( hjust = 0.5 ) 
  )

# save the plot
ggsave( plot = cov.p,
        filename = paste0( sampleid, "_covplot.png" ),
        width = 7, height = 5 )

# create a summary of sample
summ.df <- tag.df %>% 
  select( region, mean_rpkb ) %>% 
  unique( ) %>% 
  mutate( sample = sampleid,
          .before = 1 ) %>% 
  mutate( mean_rpkb = round( mean_rpkb, digits = 2 ) )

vroom_write( x = summ.df,
             file = paste0( sampleid, "_meancov.tsv" ) )
