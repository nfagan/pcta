function outs = pcta_basic_behavioral_data(trial_data_file, edf_file, meta_file, monitor_file)

trial_data = trial_data_file.data;
num_trials = numel( trial_data );

[sacc_info, start_ts] = m1_patch_saccade_info( edf_file, trial_data );
approx_patch_locs = approx_patch_locations( trial_data, edf_file );
sacc_positions = saccade_positions( sacc_info, edf_file );

outs = struct();
outs.patch_types = pcta_patch_types( trial_data );
outs.string_patch_types = string_patch_types( outs.patch_types );

outs.did_initiate = pcta_did_initiate( trial_data );
outs.collected_patches = pcta_was_patch_collected( trial_data );

outs.m1_entered_patches = pcta_m1_did_enter_patch( trial_data );
outs.m1_acquired_patches = m1_acquired_patches( trial_data );

outs.response_time = response_times( trial_data );
outs.reaction_time = reaction_times( start_ts, sacc_info, edf_file );

outs.approx_patch_locations = approx_patch_locs;
outs.saccade_positions = sacc_positions;
outs.screen_rect = repmat( monitor_file.rect, num_trials, 1 );

outs.labels = meta_file_to_labels( meta_file, outs.string_patch_types, num_trials );

end

function positions = saccade_positions(sacc_info, edf_file)

positions = cell( size(sacc_info) );

if ( ~isempty(edf_file) )
  x = edf_file.samples.posX;
  y = edf_file.samples.posY;
  
  for i = 1:numel(sacc_info)
    if ( ~isempty(sacc_info{i}) )
      first_info = sacc_info{i}(1, :);
      start_ind = first_info(1);
      stop_ind = first_info(2);
      
      sub_x = x(start_ind:stop_ind);
      sub_y = y(start_ind:stop_ind);
      
      positions{i} = [ sub_x(:)'; sub_y(:)' ];
    end
  end
end

end

function [start_stops, start_ts] = m1_patch_saccade_info(edf_file, trial_data)

start_t = @(x) x.just_patches.entry_time;
stop_t = ...
  @(x) min(pcta_m1_patch_entry_times(x.just_patches.patch_entry_times));
  
start_ts = arrayfun( start_t, trial_data );
stop_ts = arrayfun( stop_t, trial_data );  

if ( isempty(edf_file) )
  start_stops = repmat( {{}}, numel(start_ts), 1 );
  
else    
  mat_time = edf_file.samples.mat_time;
  x = edf_file.samples.posX;
  y = edf_file.samples.posY;
  
  start_stops = pcta_first_patch_saccade_info( start_ts, stop_ts, mat_time, x, y );
end

end

function rts = reaction_times(start_ts, start_stops, edf_file)

if ( isempty(edf_file) )
  rts = nan( numel(start_ts), 1 );
  
else
  mat_time = edf_file.samples.mat_time;
  rts = pcta_first_patch_reaction_time( start_ts, mat_time, start_stops );
end

end

function locs = approx_patch_locations(trial_data, edf_file)

entry_t = @(x) pcta_m1_patch_entry_times(x.just_patches.patch_entry_times);
entry_ts = arrayfun( entry_t, trial_data, 'un', 0 );
entry_ts = entry_ts(:);

mat_time = edf_file.samples.mat_time;
x = edf_file.samples.posX;
y = edf_file.samples.posY;

locs = cell( size(entry_ts) );

for i = 1:numel(entry_ts)
  per_patch_locs = nan( 2, numel(entry_ts{i}) );
  for j = 1:numel(entry_ts{i})
    entry_time = entry_ts{i}(j);
    per_patch_locs(:, j) = ...
      approx_patch_location( mat_time, x, y, entry_time, 0.2 );
  end
  locs{i} = per_patch_locs;
end

end

function loc = approx_patch_location(t, x, y, entry_t, look_ahead)

t_ind = t >= entry_t & t <= entry_t + look_ahead;
avg_x = nanmean( x(t_ind) );
avg_y = nanmean( y(t_ind) );

loc = [avg_x, avg_y];

end

function did_acquire = m1_acquired_patches(data)

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