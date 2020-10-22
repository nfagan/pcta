function outs = pcta_basic_behavioral_data(trial_data_file, edf_file, meta_file, monitor_file)

trial_data = trial_data_file.data;
num_trials = numel( trial_data );

outs = struct();
outs.patch_types = pcta_patch_types( trial_data );
outs.string_patch_types = string_patch_types( outs.patch_types );
outs.did_initiate = pcta_did_initiate( trial_data );
outs.m1_acquired_patches = acquired_patches( trial_data );
outs.response_time = response_times( trial_data );
outs.reaction_time = reaction_times( trial_data, edf_file, monitor_file );
outs.labels = meta_file_to_labels( meta_file, outs.string_patch_types, num_trials );

end

function rts = reaction_times(trial_data, edf_file, monitor_file)

if ( isempty(edf_file) )
  rts = nan( numel(trial_data), 1 );
  
else
  mat_time = edf_file.samples.mat_time;
  x = edf_file.samples.posX;
  y = edf_file.samples.posY;
  
%   x = pcta.px2deg( x, monitor_file );
%   y = pcta.px2deg( y, monitor_file );
  
  start_t = @(x) x.just_patches.entry_time;
  stop_t = ...
    @(x) min(pcta_m1_patch_entry_times(x.just_patches.patch_entry_times));
  
  start_ts = arrayfun( start_t, trial_data );
  stop_ts = arrayfun( stop_t, trial_data );
  
  rts = pcta_first_patch_reaction_time( start_ts, stop_ts, mat_time, x, y );
end

end

function did_acquire = acquired_patches(data)

did_acquire = cell( numel(data), 1 );

for i = 1:numel(data)
  % m1 patch acquired times
  acquired_times = data(i).just_patches.patch_acquired_times(1, :);
  did_acquire{i} = ~isnan( acquired_times );
end

end

function rt = response_times(data)

rt = cell( numel(data), 1 );

for i = 1:numel(data)
  state_start = data(i).just_patches.entry_time;
  
  m1_entry_times = ...
    pcta_m1_patch_entry_times( data(i).just_patches.patch_entry_times );
  
  rt{i} = m1_entry_times - state_start;
end

end

function strs = string_patch_types(patch_types)

strs = cellfun( @(x) strjoin(x, '_'), patch_types, 'un', 0 );
strs(strcmp(strs, '')) = {'<patch-type>'};

end

function labels = meta_file_to_labels(meta_file, string_patch_types, num_trials)

fnames = fieldnames( meta_file );
fvals = struct2cell( meta_file );

create_args = cell( 1, numel(fnames)*2 );
create_args(1:2:end) = fnames;
create_args(2:2:end) = fvals;

labels = fcat.create( create_args{:} );
repmat( labels, num_trials );

if ( num_trials > 0 )
  addsetcat( labels, 'patch-type', string_patch_types );
end

end