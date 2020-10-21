function rts = pcta_first_patch_reaction_time(trial_data, edf_file, varargin)

defaults = struct();
defaults.vel_thresh = 100;
defaults.dur_thresh = 50;
defaults.sample_rate = 1e3;
defaults.smooth_func = @(data) smoothdata( data, 'smoothingfactor', 0.05 );

params = shared_utils.general.parsestruct( defaults, varargin );

mat_time = edf_file.samples.mat_time;
x = edf_file.samples.posX;
y = edf_file.samples.posY;

rts = nan( numel(trial_data), 1 );

for i = 1:numel(trial_data)
  start_t = trial_data(i).just_patches.entry_time;
  entry_ts = pcta_m1_patch_entry_times( trial_data(i).just_patches.patch_entry_times );
  
  look_within = mat_time >= start_t & mat_time < min( entry_ts );
  
  sub_t = mat_time(look_within);
  sub_x = x(look_within);
  sub_y = y(look_within);

  % have to play with these parameters.
  smooth_func = params.smooth_func;
  vel_thresh = params.vel_thresh;
  dur_thresh = params.dur_thresh;
  sr = params.sample_rate;

  start_stops = ...
    hwwa.find_saccades( sub_x(:)', sub_y(:)', sr, vel_thresh, dur_thresh, smooth_func );
  
  if ( ~isempty(start_stops) && ~isempty(start_stops{1}) )
    % Find the start time of the start index of the first saccade.
    first_sacc = start_stops{1}(1); % index of first saccade.
    first_sacc_t = sub_t(first_sacc); % time of first saccade.
    rts(i) = first_sacc_t - start_t;
  end
end

end