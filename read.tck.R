read.tck = function(filepath, n=50L) {
  # https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html#tracks-file-format-tck
  
  # check n first lines for header information
  L = readLines(filepath, n=n, warn=FALSE) 
  id = trimws(L[1L])
  if (id != 'mrtrix tracks') 
    stop('File not in TCK format: invalid first line.')  
  
  fs = file.size(filepath) 
  if (fs/1024 < 100) # put sth. more meaningful here
    stop('File not in TCK format: file too small.')
  
  k = grep(pattern='END', x=L, useBytes=TRUE)
  if (length(k)==0L) 
    stop('File not in TCK format: invalid format.')
  
  header = read.table(text=L[2L:(k-1L)], sep=':', header=FALSE)
  header = c(list(id=id), split.default(trimws(header$V2), header$V1)) 
  
  if (!grepl(pattern='.', x=header$file)) 
    #  "only the single-file format is supported [...] file name part must be specified as '.'"  
    stop('Multi-file TCK files not supported.') else {
      tmp = strsplit(header$file, ' ', fixed=TRUE)
      filename_part = tmp[[1L]][1L]
      offset = strtoi(tmp[[1L]][2L])
    }
  if (strtoi(header$count)==0L) # system('tckinfo <path> -count')
    stop('Invalid datatype. Number of streamlines ("count") is zero.')
  
  valid_datatypes = c('Float32BE', 'Float32LE', 'Float64BE', 'Float64LE')
  if (!header$datatype %in% valid_datatypes) 
    stop('Invalid data type in TCK file header.')
  
  endian = if (endsWith(header$datatype, 'BE')) 'big' else 'little'
  dsize = if (startsWith(header$datatype, 'Float64')) 8L else 4L
  n2r = (fs - offset) / dsize
  derived = list(derived = list(filename_part=filename_part, data_offset=offset, 
                                endian=endian, dsize=dsize))
  
  fh = file(description=filepath, open='rb')
  on.exit(close(fh), add=TRUE)
  seek(con=fh, where=offset, origin='start')
  tracks_rawdata = readBin(con=fh, what=numeric(), n=n2r, size=dsize, endian=endian)
  
  # "The binary track data themselves are stored as triplets of floating-point values:"
  tracks_raw_matrix = matrix(tracks_rawdata, ncol=3L, byrow=TRUE)
  
  # "tracks are separated using a triplet of NaN (Not A Number) values"
  # "a triplet of Inf values is used to indicate the end of the file"
  i = rowSums(is.finite(tracks_raw_matrix))==3L
  tracks = split.data.frame(tracks_raw_matrix[i, ], cumsum(!i)[i]) |> unname()
  list(header=c(derived, header), tracks=tracks)
}
