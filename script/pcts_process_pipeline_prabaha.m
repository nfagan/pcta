%%  group files by session

pcta_data_p = '/Users/prabaha/repositories/pcta/data';

edf_p = fullfile( pcta_data_p, 'raw/edf' );
mat_p = fullfile( pcta_data_p, 'raw/mat' );
dest_p = fullfile( pcta_data_p, 'by-session-old' );

pcta_reorganize_raw_data_by_session( edf_p, mat_p, dest_p );

sessions = shared_utils.io.find( dest_p, 'folders' );
processed_p = fullfile( pcta_data_p, 'processed' );

for i = 1:numel(sessions)
  pcta_session_to_processed_data( sessions{i}, processed_p );
end

%%  save trial data separatey from program data

pcta_make_trial_data();
pcta_make_meta();