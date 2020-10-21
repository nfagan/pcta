function ts = pcta_m1_patch_entry_times(patch_entry_times)

entry_ts = patch_entry_times(1, :);
ts = nan( numel(entry_ts), 1 );

for i = 1:numel(ts)
  if ( ~isempty(entry_ts{i}) )
    ts(i) = entry_ts{i}(1);
  end
end

end