function pcta_reorganize_raw_data_by_session(edf_p, mat_p, dest_p)

edf_dirs = shared_utils.io.find( edf_p, 'folders' );
mat_files = shared_utils.io.find( mat_p, '.mat' );

mat_filenames = shared_utils.io.filenames( mat_files );
edf_dirnames = shared_utils.io.filenames( edf_dirs );

dates = cellfun( @pcta.util.mat_filename_to_datestr, mat_filenames, 'un', 0 );
mat_sessions = cellfun( @(x) datestr(x, 'mmddyy'), dates, 'un', 0 );

unique_mat_sessions = unique( mat_sessions );

for i = 1:numel(unique_mat_sessions)
  mat_session = unique_mat_sessions{i};
  
  mats_matching_session = strcmp( mat_sessions, mat_session );
  edf_dirs_matching_session = find( strcmp(edf_dirnames, mat_session) );
  
  if ( numel(edf_dirs_matching_session) ~= 1 )
    warning( 'Expected 1 edf directory matching session "%s".', mat_session );
    continue;
  end
  
  mat_dates_matching_session = dates(mats_matching_session);
  mat_date_nums = datenum( mat_dates_matching_session );
  [~, mat_sort_ind] = sort( mat_date_nums );
  
  edf_files = shared_utils.io.find( edf_dirs{edf_dirs_matching_session}, '.edf' );
  edf_filenames = shared_utils.io.filenames( edf_files );
  edf_filenums = str2double( edf_filenames );
  
  if ( any(isnan(edf_filenums)) )
    warning( 'Failed to parse .edf file number for one of: "%s".' ...
      , strjoin(edf_filenames, ' | ') );
    continue;
  end
  
  [~, edf_sort_ind] = sort( edf_filenums );
  
  edf_files = edf_files(edf_sort_ind);
  mat_files_this_session = mat_files(mats_matching_session);
  mat_files_this_session = mat_files_this_session(mat_sort_ind);  
  
  if ( numel(edf_files) ~= numel(mat_files_this_session) )
    warning( 'Expected 1 .edf file for each .mat file (%s).', mat_session );
    continue;
  end
  
  save_p = fullfile( dest_p, mat_session );
  shared_utils.io.require_dir( save_p );
  
  for j = 1:numel(edf_files)
    dest_filename = shared_utils.io.filenames( mat_files_this_session{j} );
    dest_edf_file = fullfile( save_p, sprintf('%s.edf', dest_filename) );
    dest_mat_file = fullfile( save_p, sprintf('%s.mat', dest_filename) );
    
    copyfile( edf_files{j}, dest_edf_file );
    copyfile( mat_files_this_session{j}, dest_mat_file );    
  end
end

end