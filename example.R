## read TCK files

# install dependencies if needed 
local({
  lop = c('freesurferformats', 'microbenchmark', 'ggplot2')
  np = lop[!(lop %in% installed.packages()[, 'Package'])]
  if (length(np)) install.packages(np)
})

# data from here: 
# https://openneuro.org/datasets/ds001226/versions/00001
f = list.files('./FOD_iFOD2_trackings', pattern='.tck$', full.names=TRUE) 

# show error due to early exit:
lapply(f, freesurferformats::read.dti.tck)
# do not forget to continue execution below this line 

# quick-fix to run function and benchmark: 
if (exists('hasRun')==FALSE) {
  library(freesurferformats)
  body(read.dti.tck)[[6L]]
  read.dti.tck2 = read.dti.tck
  # remove check: 
  body(read.dti.tck2)[[6L]] = NULL
  hasRun = TRUE 
}

# load function from file (no package build):
source('read.tck.R')

# run benchmark: 
B = 
  microbenchmark::microbenchmark(
  fixed_original = lapply(f, read.dti.tck2),
  rewrite = lapply(f, read.tck),
  times = 10L
  )

# print and plot benchmark results
B
ggplot2::autoplot(B)





