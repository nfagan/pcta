function pcta_session_to_processed_data(session_p, processed_p)

mats = shared_utils.io.find( session_p, '.mat' );
edfs = shared_utils.io.find( session_p, '.edf' );

process_edfs = true;

if ( numel(edfs) ~= numel(mats) )
  assert( numel(edfs) == 0, ['Expected the number of .edf files (%d) to match' ...
    , ' the number of .mat files (%d), or else to find 0 .edf files.'] ...
    , numel(edfs), numel(mats) );
  process_edfs = false;
end

n_process = numel( mats );

for i = 1:n_process
  program_data = shared_utils.io.fload( mats{i} );
  identifier = shared_utils.io.filenames( mats{i} );
  program_data.identifier = identifier;
  
  if ( process_edfs )
    edf = Edf2Mat( edfs{i} );

    edf_file = pcta.make.edf( identifier, program_data, edf );

    edf_dir = fullfile( processed_p, 'edf' );
    shared_utils.io.require_dir( edf_dir );
    edf_filename = fullfile( edf_dir, sprintf('%s.mat', identifier) );

    save( edf_filename, 'edf_file' );
  end
  
  mat_dir = fullfile( processed_p, 'source' );
  mat_filename = fullfile( mat_dir, sprintf('%s.mat', identifier) );
  shared_utils.io.require_dir( mat_dir );
  save( mat_filename, 'program_data' );
end

end