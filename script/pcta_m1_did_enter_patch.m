function entered = pcta_m1_did_enter_patch(trial_data)

patch_entry_times = ...
  @(x) pcta_m1_patch_entry_times(x.just_patches.patch_entry_times);

entry_ts = arrayfun( patch_entry_times, trial_data, 'un', 0 );
entered = cellfun( @(x) ~isnan(x), entry_ts, 'un', 0 );
entered = entered(:);

end