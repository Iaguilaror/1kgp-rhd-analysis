# load pkgs
pacman::p_load( "vroom", "dplyr", "tidyr", "ggplot2", "scales" )

# 1) Receive arg from command line
args <- commandArgs( trailingOnly = TRUE )

# for debug only
args[ 1 ] <- "all_covratio.tsv" # cnv_channel
args[ 2 ] <- "1kgp_RHD_500kb_upanddown_window_gts_unrelated.tsv.gz" # snv_channel
args[ 3 ] <- "1kgp_samplepops.tsv" # ref_channel

cnv_file <- args[ 1 ]
snv_file <- args[ 2 ]
refpop_file <- args[ 3 ]

# define the markers
# Chr1  25,235,176  G:A
# Chr1  25,257,119  C:G

# load the cnv data
cnv.df <- vroom( file = cnv_file )

# load pop annotations
pop.df <- vroom( file = refpop_file )

# annotate
cnv_ann.df <- cnv.df %>% 
  left_join( x = .,
             y = pop.df,
             by = "sample" ) %>% 
  mutate( cnv_est = round( gene2flank_ratio * 2 ) ) %>% 
  mutate( cnv_tag = case_when( cnv_est <= 0.5 ~ "0",
                               cnv_est <= 1.5 ~ "1",
                               cnv_est > 1.5 ~ "2" ) %>% 
            as.factor( ) ) %>% 
  filter( !is.na( `Superpopulation code` ) ) %>% 
  filter( !is.na( cnv_tag ) )

# see dist by superpop
base_histo.p <- ggplot( data = cnv_ann.df,
                        mapping = aes( x = gene2flank_ratio * 2,
                                       fill = cnv_tag ) ) +
  geom_histogram( binwidth = 0.1, color = "black" ) +
  geom_vline( xintercept = c( 0.5, 1.5 ), lty = 2, alpha = 0.5 ) +
  scale_x_continuous( breaks = seq( 0, 3, by = 0.5 ) ) +
  theme_classic( base_size = 20 ) +
  theme( legend.position = "none" )

base_histo.p

base_histo.p +
  labs( title = "1KGP worldwide distribution of RHD Deletion" )

base_histo.p +
  labs( title = "Distribution of RHD Deletion by POP in 1KGP" ) +
  facet_wrap( ~`Superpopulation code`, scales = "free_y" )

byppop_count.df <- cnv_ann.df %>% 
  select( `Superpopulation code`, cnv_tag ) %>% 
  count( `Superpopulation code`, cnv_tag ) %>% 
  ungroup( ) %>% 
  group_by( `Superpopulation code`  ) %>% 
  mutate( total = sum( n ),
          percent = percent( n / total ) ) %>% 
  ungroup( ) %>% 
  mutate( RHD = case_when( cnv_tag == "0" ~ "-/-",
                           cnv_tag == "1" ~ "-/+",
                           cnv_tag == "2" ~ "+/+" ) )

byppop_count.df

# select only the useful tag
cnv_use.df <- cnv_ann.df %>% 
  select( sample, `Superpopulation code`, cnv_tag )

### process the snv data -----
# load snv data
snv.df <- vroom( file = snv_file ) %>% 
  rename( "CHROM" = 1 )

# define the markers
# Chr1  25,235,176  G:A
# Chr1  25,257,119  C:G

# marker 1
snv_mk1.df <- snv.df %>% 
  filter( CHROM == 1,
          POS == 25235176,
          REF == "G",
          ALT == "A" ) 

long_mk1.df <- snv_mk1.df %>% 
  pivot_longer( cols = -CHROM:-ALT,
                names_to = "sample",
                values_to = "chr1_25235176_G_A" ) %>% 
  select( -CHROM:-ALT ) %>% 
  mutate( chr1_25235176_G_A = case_when( chr1_25235176_G_A == "0/0" ~ "0",
                                         chr1_25235176_G_A == "1/0" | chr1_25235176_G_A == "0/1" ~ "1",
                                         chr1_25235176_G_A == "1/1" ~ "2" ) )

long_mk1.df$chr1_25235176_G_A %>% 
  unique( )

# Chr1  25,257,119  C:G
snv_mk2.df <- snv.df %>% 
  filter( CHROM == 1,
          POS == 25257119,
          REF == "C",
          ALT == "G" ) 

long_mk2.df <- snv_mk2.df %>% 
  pivot_longer( cols = -CHROM:-ALT,
                names_to = "sample",
                values_to = "chr1_25257119_C_G" ) %>% 
  select( -CHROM:-ALT ) %>% 
  mutate( chr1_25257119_C_G = case_when( chr1_25257119_C_G == "0/0" ~ "0",
                                         chr1_25257119_C_G == "1/0" | chr1_25257119_C_G == "0/1" ~ "1",
                                         chr1_25257119_C_G == "1/1" ~ "2" ) )

long_mk2.df$chr1_25257119_C_G %>% 
  unique( )

# join cnv and gt data
all_cnvsnv.df <- cnv_use.df %>% 
  left_join( x = .,
             y = long_mk1.df,
             by = "sample" ) %>% 
  left_join( x = .,
             y = long_mk2.df,
             by = "sample" )

# summarise ----
mk1_table.df <- all_cnvsnv.df %>% 
  group_by( `Superpopulation code`, cnv_tag, chr1_25235176_G_A ) %>% 
  summarise( n = n( ) )

mk2_table.df <- all_cnvsnv.df %>% 
  group_by( `Superpopulation code`, cnv_tag, chr1_25257119_C_G ) %>% 
  summarise( n = n( ) )

# plot the panel ----
ggplot( data = mk1_table.df,
        mapping = aes( x = cnv_tag,
                       y = chr1_25235176_G_A,
                       fill = n,
                       label = n ) ) +
  geom_tile( ) +
  geom_text( ) +
  scale_fill_gradient( low = "white",
                       high = "tomato" ) +
  theme_classic( ) +
  facet_wrap( ~`Superpopulation code`, scales = "free" )

# lets do a function to chose the marker column, and the superpop
# the_data <- all_cnvsnv.df
# the_pop <- "AFR"
# the_marker <- "chr1_25235176_G_A"

plot_table.f <- function( the_data, the_pop, the_marker ){
  
  toplot.df <- the_data %>% 
    filter( `Superpopulation code` == the_pop ) %>% 
    select( sample, `Superpopulation code`, cnv_tag, all_of( the_marker ) ) %>% 
    rename( "snv_marker" = 4 ) %>% 
    group_by( `Superpopulation code`, cnv_tag, snv_marker ) %>% 
    summarise( n = n( ) ) %>% 
    ungroup( )
  
  the_plot <- ggplot( data = toplot.df,
                      mapping = aes( x = cnv_tag,
                                     y = snv_marker,
                                     fill = n,
                                     label = n ) ) +
    geom_tile( color = "white", size = 3 ) +
    geom_text( size = 10 ) +
    scale_fill_gradient( low = "white",
                         high = "tomato" ) +
    labs( title = paste( the_pop, the_marker, sep = "  -  " ) ) +
    scale_x_discrete( limits = c( "0", "1", "2" )   ) +
    scale_y_discrete( limits = c( "0", "1", "2" )   ) +
    theme_classic( base_size = 15 ) +
    theme( legend.position = "none",
           plot.title = element_text( hjust = 0.5 ) )

  ggsave( plot = the_plot,
          filename = paste0( the_marker, "-", the_pop, ".svg" ),
          width = 7, height = 7  )
  
  return( the_plot )
  
}

for ( pop_inturn in all_cnvsnv.df$`Superpopulation code` %>% unique( ) ) {
  
  message( "[>..] plotting ", pop_inturn )

  plot_table.f( the_data = all_cnvsnv.df,
                the_pop = pop_inturn,
                the_marker = "chr1_25235176_G_A" )
  
  plot_table.f( the_data = all_cnvsnv.df,
                the_pop = pop_inturn,
                the_marker = "chr1_25257119_C_G" )
  
}
