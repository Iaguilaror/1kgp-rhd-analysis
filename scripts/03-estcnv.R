# load pkgs
pacman::p_load( "GenomicAlignments", "ggplot2", "dplyr", "vroom" )

# 1) Receive arg from command line
args <- commandArgs( trailingOnly = TRUE )

# for debug only
# args[ 1 ] <- "HG00103_subset.bam"

bamfile <- args[ 1 ]

# 2) Read the BAM file
# We read the alignments and convert to a GRanges object
alignments <- readGAlignments( file = bamfile )
gr_data <- granges( x = alignments )

# 3) Bin the data in 1kb bins
# Determine the range of the data
chrom <- as.character( x = seqnames( x = gr_data )[ 1 ] )
start_pos <- min( start( x = gr_data ) )
end_pos <- max( end( x = gr_data ) )

# Create 1kb bins across the range
bins <- seq( from = start_pos, to = end_pos, by = 1000 )
bin_centers <- bins + 500

# Calculate coverage depth per bin
# We use findOverlaps to count how many reads fall into each 1kb window
bin_ranges <- GRanges( seqnames = chrom, 
                       ranges = IRanges( start = bins, end = bins + 999 ) )
counts <- countOverlaps( query = bin_ranges, subject = gr_data )

plot_df <- data.frame( position = bin_centers, 
                       depth = counts )

# 4) Plot the coverage depth

# prepare a function to X
myxaxis.f <- function( the_n ){
  
  paste( prettyNum(the_n / 1e3,
                   big.mark = "," ), "Mb" )
  
}

# mark the start and end of RHD
# 1:25272393-25330445

p <- ggplot( data = plot_df, mapping = aes( x = position, y = depth ) ) +
  geom_line( color = "steelblue" ) +
  geom_area( fill = "steelblue" ) +
  geom_vline( xintercept = c( 25272393, 25330445 ),
              color = "tomato",
              lty = 2 ) +
  labs( title = paste( "Coverage Depth for", bamfile ),
        subtitle = "Binned by 1kb",
        x = paste( chrom ),
        y = "Read Count (Depth X)" ) +
  scale_x_continuous( labels = myxaxis.f ) +
  theme_minimal( )

# p

# Save the plot
output_name <- paste0( bamfile, "_coverage.png" )
ggsave( filename = output_name, plot = p, width = 10, height = 6 )

# save the df
vroom_write( x = plot_df, file =  paste0( bamfile, "_readsperkb.tsv" )  )
