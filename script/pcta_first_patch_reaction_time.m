function rts = pcta_first_patch_reaction_time(start_ts, t, sacc_info)

assert( numel(start_ts) == numel(sacc_info) ...
  , 'Expected 1 trial of start times for every trial of saccade info.' );

rts = nan( numel(start_ts), 1 );

for i = 1:numel(start_ts)
  start_t = start_ts(i);
  start_stops = sacc_info{i};
  
  if ( ~isempty(start_stops{1}) )
    % Find the start time of the start index of the first saccade.
    first_sacc = start_stops{1}(1); % index of first saccade.
    first_sacc_t = t(first_sacc); % time of first saccade.
    rts(i) = first_sacc_t - start_t;
  end
end

end