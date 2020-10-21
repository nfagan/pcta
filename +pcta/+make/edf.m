function edf_file = edf(identifier, program_data, edf_obj)

tracker_sync = program_data.tracker_sync;
messages = edf_obj.Events.Messages;

is_sync = strcmp( messages.info, 'sync' );

assert( sum(is_sync) == numel(tracker_sync.times) ...
  , 'Expected number of .mat sync times (%d) to match number of .edf sync times (%d).' ...
  , numel(tracker_sync.times), sum(is_sync) );

edf_sync_times = reshape( messages.time(is_sync), [], 1 );
mat_sync_times = tracker_sync.times(:);

sync = struct( 'mat', mat_sync_times, 'edf', edf_sync_times );
events = edf_obj.Events;
samples = edf_obj.Samples;

edf_file = struct();
edf_file.identifier = identifier;
edf_file.sync = sync;
edf_file.events = events;
edf_file.samples = samples;
edf_file.samples.mat_time = ...
  shared_utils.sync.cinterp( edf_file.samples.time, sync.edf, sync.mat );

end