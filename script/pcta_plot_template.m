basic_behavioral_data = pcta_gather_basic_behavioral_data();

%%  plot response time

response_time = cellfun( @(x) x, basic_behavioral_data.response_time );
labels = basic_behavioral_data.labels';

xcats = {'subject'};
gcats = {'patch-type'}; % make a group for each 'patch-type'
pcats = {'day'};  % make a panel for each day

pl = plotlabeled.make_common();
axs = pl.bar( response_time, labels, xcats, gcats, pcats );

%%  