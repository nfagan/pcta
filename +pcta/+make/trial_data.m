function trial_data_file = trial_data(source_file)

trial_data_file = struct();
trial_data_file.identifier = source_file.identifier;
trial_data_file.data = source_file.data.Value;

end