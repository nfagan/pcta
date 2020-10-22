function tf = pcta_was_patch_collected(trial_data)

tf = cell( numel(trial_data), 1 );

for i = 1:numel(trial_data)
  % all patch acquired times
  acquired_times = trial_data(i).just_patches.patch_acquired_times;
  tf{i} = any( ~isnan(acquired_times), 1 );
end

end