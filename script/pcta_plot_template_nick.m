basic_behavioral_data = pcta_gather_basic_behavioral_data();

%%  plot response time

response_time = cellfun( @(x) x, basic_behavioral_data.response_time );
response_time = basic_behavioral_data.reaction_time;

labels = basic_behavioral_data.labels';

xcats = {'subject'};
gcats = {'patch-type'}; % make a group for each 'patch-type'
pcats = {'day'};  % make a panel for each day

pl = plotlabeled.make_common();
axs = pl.bar( response_time, labels, xcats, gcats, pcats );

%%  ranksum compete vs. coop

reaction_time = basic_behavioral_data.reaction_time;
acquired = cellfun( @(x) x, basic_behavioral_data.m1_acquired_patches );

labels = basic_behavioral_data.labels';

mask = fcat.mask( labels, find(acquired) ...
  , @findnone, '<patch-type>' ...
  , @findnone, '092820' ...
);

comp = find( labels, 'compete', mask );
coop = find( labels, 'cooperate', mask );

comp_rt = reaction_time(comp);
coop_rt = reaction_time(coop);

p = ranksum( comp_rt, coop_rt );