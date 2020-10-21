function pct_daily_comp_coop_training_analysis_plot_hitch(data)

if nargin < 2
  data = load_data();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extracting data from files %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initiate cell arrays to extract data from struct
data_cell = {};
% Get the fieldnames of the data struct
data_fieldnames = fieldnames( data{1} );
% Loop through all the data files of the data
for data_file_ind = 1:numel( data )
  % Convert data struct to cell and store in temporary variable
  temp_data_cell = struct2cell( data{data_file_ind} );
  % Catenate along the 3rd dimension, which is trials
  data_cell = cat( 3, data_cell, temp_data_cell );
end
% Remove the middle singleton dimension of data cell
data_cell = squeeze(data_cell);
% Index along 1st dim about last state
last_state_index = strcmp(data_fieldnames, 'last_state');
% Index along 1st dim about patch info
patch_info_index = strcmp(data_fieldnames, 'last_patch_type');
% Find index of initiated trials
initiated_trials_ind = ~strcmp(data_cell(last_state_index, :), 'fix');
% Siphon out the data of the trials that were initiated
data_initiated_trials = data_cell(:,initiated_trials_ind);
% From this, extract out the compete trials
data_compete_trials = data_initiated_trials(:,...
  strcmp(data_initiated_trials(patch_info_index, :), 'compete') );
% And the cooperation trials
data_cooperate_trials = data_initiated_trials(:,...
  strcmp(data_initiated_trials(patch_info_index, :), 'cooperate') );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract data separetely for competition and cooperation blocks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here we are using the convention of defining the beginning of, say a
% cooperation block as the first initiated cooperation trial, after a
% compete, and symmetrically, the end to be the trial before the first
% initiated cooperation trial after this block.

% Binary picture:
% coop_inds = 11110101000000000001111101011000000000
% comp_inds = 00000000011101010100000000000001011101
% comp block  |-------|          |----------|       
% coop block           |--------|            |-----|
% We store the comp data in a single 1D cell array and coop in a separate
% one

% Setting initial value of coopearation block flag to 0
cooperation_block_flag = 0;
% Index of competition trials that were initiated
comp_inds = strcmp(data_cell(patch_info_index, :), 'compete');
% Index of first initiated competion trial
comp_start_ind = find( comp_inds, 1 );
% Index of cooperation trials that were initiated
coop_inds = strcmp(data_cell(patch_info_index, :), 'cooperate');
% Index of first initiated cooperation trial
coop_start_ind = find( coop_inds, 1 );
% Is the first block cooperation?
coop_start_condition = (coop_start_ind < comp_start_ind);
% Initiate cell arrays to store data
data_compete_block = {};
data_cooperate_block = {};
% Iniaiate temporary block data cell arrays
temp_data_compete_block = {};
temp_data_cooperate_block = {};
% Initiate indcices of blocks
comp_block_ind = 0;
coop_block_ind = 0;
% Set flag to 1 if trials start with cooperation block
if coop_start_condition
  cooperation_block_flag = 1;
  coop_block_ind = coop_block_ind + 1;
else
  cooperation_block_flag = 0;
  comp_block_ind = comp_block_ind + 1;
end
% Iterate over all trials
for trial_ind = 1:size(data_cell, 2)
  % Check if it is cooperation block
  if cooperation_block_flag
    % Append data to coopeeration block cell array
    temp_data_cooperate_block = [temp_data_cooperate_block data_cell(:, trial_ind)];
    % Check if it is the last trial
    if trial_ind + 1 <= size(data_cell, 2) 
      % Check if the next trial is an initiated compete trial
      if (comp_inds(trial_ind + 1) == 1)
        % If yes, set flag to 0
        cooperation_block_flag = 0;
        % Concatenate the data of the block along 3rd dimension
        data_cooperate_block{coop_block_ind} = temp_data_cooperate_block;
        % Reset temp data
        temp_data_cooperate_block = {};
        % Update index of competition block
        comp_block_ind = comp_block_ind + 1;
      end
    end
  % If not cooperation block
  else
    % Append data to compete block
    temp_data_compete_block = [temp_data_compete_block data_cell(:, trial_ind)];
    % Check if it is the last trial
    if trial_ind + 1 <= size(data_cell, 2)
      % Check if next trial is an initiated cooperation trial
      if (coop_inds(trial_ind + 1) == 1)
        % If yes, set flag to 1
        cooperation_block_flag = 1;
        % Concatenate the data of the block along 3rd dimension
        data_compete_block{comp_block_ind} = temp_data_compete_block;
        % Reset temp data
        temp_data_compete_block = {};
        % Update index of competition block
        coop_block_ind = coop_block_ind + 1;
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of trials initiated in different blocks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for compete_block_ind = 1:numel( data_compete_block )
  initiated_trial_percent_compete(compete_block_ind) = mean(~strcmp(data_compete_block{...
    compete_block_ind}(last_state_index, :), 'fix'))*100;
end
mean_percent_initiated_compete = nanmean(initiated_trial_percent_compete);
if numel(initiated_trial_percent_compete) >= 3
  stdev_percent_initiated_compete = nanstd(initiated_trial_percent_compete);
else
  stdev_percent_initiated_compete = nan;
end

for cooperate_block_ind = 1:numel( data_cooperate_block )
  initiated_trial_percent_cooperate(cooperate_block_ind) = mean(~strcmp(data_cooperate_block{...
    cooperate_block_ind}(last_state_index, :), 'fix'))*100;
end
mean_percent_initiated_cooperate = nanmean(initiated_trial_percent_cooperate);
if numel(initiated_trial_percent_cooperate) >= 3
  stdev_percent_initiated_cooperate = nanstd(initiated_trial_percent_cooperate);
else
  stdev_percent_initiated_cooperate = nan;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean response time for cooperation versus competition trials %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the index for patch entry times in just patches
patch_entry_times_index = strcmp(data_fieldnames, 'just_patches');

comp_resp_times = [];
coop_resp_times = [];

% Compete
for compete_block_ind = 1:numel( data_compete_block )
  compete_block_entry_times{compete_block_ind} = data_compete_block{...
    compete_block_ind}(patch_entry_times_index, :);
  for trial_ind = 1:numel( compete_block_entry_times{compete_block_ind} )
    if isempty(compete_block_entry_times{compete_block_ind}{trial_ind}.patch_entry_times{1})
      comp_resp_times = [comp_resp_times, nan];
    else
      comp_resp_times = [comp_resp_times, (-compete_block_entry_times{compete_block_ind}{trial_ind}.entry_time ...
        + compete_block_entry_times{compete_block_ind}{trial_ind}.patch_entry_times{1})];
    end
  end
end
mean_comp_resp_time = nanmean(comp_resp_times);
if numel( comp_resp_times ) >= 3
  stdev_comp_resp_time = nanstd(comp_resp_times);
else
  stdev_comp_resp_time = nan;
end

% Cooperate
for cooperate_block_ind = 1:numel( data_cooperate_block )
  cooperate_block_entry_times{cooperate_block_ind} = data_cooperate_block{...
    cooperate_block_ind}(patch_entry_times_index, :);
  for trial_ind = 1:numel( cooperate_block_entry_times{cooperate_block_ind} )
    if isempty(cooperate_block_entry_times{cooperate_block_ind}{trial_ind}.patch_entry_times{1})
      coop_resp_times = [coop_resp_times, nan];
    else
      coop_resp_times = [coop_resp_times, (-cooperate_block_entry_times{cooperate_block_ind}{trial_ind}.entry_time ...
        + cooperate_block_entry_times{cooperate_block_ind}{trial_ind}.patch_entry_times{1})];
    end
  end
end
mean_coop_resp_time = nanmean(coop_resp_times);
if numel( coop_resp_times ) >= 3
  stdev_coop_resp_time = nanstd(coop_resp_times);
else
  stdev_coop_resp_time = nan;
end

%%%%%%%%%
% Plots %
%%%%%%%%%

% Comparing initiated trials
subplot(1,2,1)
initiated_trials_percent = [mean_percent_initiated_compete mean_percent_initiated_cooperate];
initiated_trials_stdev = [stdev_percent_initiated_compete stdev_percent_initiated_cooperate];
bar(initiated_trials_percent); hold on;
errorbar(initiated_trials_percent, initiated_trials_stdev);

% Comparing response time per block
subplot(1,2,2)
resp_time_mean = [mean_comp_resp_time mean_coop_resp_time];
resp_time_stdev = [stdev_comp_resp_time stdev_coop_resp_time];
bar(resp_time_mean); hold on;
errorbar(resp_time_mean, resp_time_stdev);

end

function data = load_data()

folder_path = fullfile('pct-training-hitch', 'comp-coop/');
data_files = dir([folder_path '*.mat']);
latest_file_name = data_files(end).name;
latest_file_date = latest_file_name(1:10);
file_name_list = cell(1);
file_counter = 0;
for file_ind = 1:numel( data_files )
  if strcmp( latest_file_date, data_files( file_ind ).name(1:10) )
    file_counter = file_counter + 1;
    file_name_list{file_counter} = data_files( file_ind ).name;
  end
end

for load_file_ind = 1:numel( file_name_list )
  file_path = fullfile( 'pct-training-hitch/comp-coop/', file_name_list{load_file_ind} );
  temp_storage = load( file_path );
  temp_data = temp_storage.program_data.data.Value;
  data{load_file_ind} = temp_data;
end

end