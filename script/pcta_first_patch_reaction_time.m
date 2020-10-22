function rts = pcta_first_patch_reaction_time(start_ts, stop_ts, t, x, y, varargin)

defaults = struct();
defaults.vel_thresh = 100;
defaults.dur_thresh = 50;
defaults.sample_rate = 1e3;
defaults.smooth_func = @(data) smoothdata( data, 'smoothingfactor', 0.05 );

params = shared_utils.general.parsestruct( defaults, varargin );
assert( numel(start_ts) == numel(stop_ts) ...
  , 'Expected equal number of start and stop times.' );

rts = nan( numel(start_ts), 1 );

for i = 1:numel(start_ts)
  start_t = start_ts(i);
  stop_t = stop_ts(i);
  
  look_within = t >= start_t & t < min( stop_t );
  
  sub_t = t(look_within);
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