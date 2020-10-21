function date_str = mat_filename_to_datestr(filename)

n_chars = 19;
assert( numel(filename) >= n_chars ...
  , 'Expected at least %d characters in filename.', n_chars );

format = 'yyyy-mm-dd_HH-MM-SS';
date_str = filename(1:n_chars);
date_str = datestr( datenum(date_str, format) );

end