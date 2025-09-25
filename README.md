# read.tck2
Suggestions for a re-write of [`freesurferformats::read.dti.tck()`](https://github.com/dfsp-spirit/freesurferformats/blob/master/R/read_dti_tck.R) in base `R`. 

Discussion: https://github.com/dfsp-spirit/freesurferformats/issues/34

Needs approximately 4,2% of the time, i.e., ~23 times faster. 

Data for `example.R` generated from here: 
https://openneuro.org/datasets/ds001226/versions/00001

Faster versions would require the [`{fastverse}`](https://github.com/fastverse/fastverse) (not needed IMO). 
