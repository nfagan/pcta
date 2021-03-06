basic_behavioral_data = pcta_gather_basic_behavioral_data();

%%  plot response time

% response_time = cellfun( @(x) x, basic_behavioral_data.response_time );
% response_time = basic_behavioral_data.reaction_time;
% 
% labels = basic_behavioral_data.labels';
% 
% xcats = {'subject'};
% gcats = {'patch-type'}; % make a group for each 'patch-type'
% %pcats = {'day'};  % make a panel for each day
% pcats = {};
% 
% pl = plotlabeled.make_common();
% axs = pl.bar( response_time, labels, xcats, gcats, pcats );

%% plot reaction time

reaction_time = basic_behavioral_data.reaction_time;
labels = basic_behavioral_data.labels';

mask = fcat.mask( labels, ...
    @findnone, '<patch-type>' ...
  , @findnone, '092820' ...
  , @findnone, '101520' ...
);
labels = labels(mask);
reaction_time = reaction_time(mask);
reaction_time(reaction_time<0.1) = nan;
reaction_time(reaction_time>0.6) = nan;

%xcats = {'day'};
xcats = {'day', 'patch-type'};
gcats = {'patch-type'}; % make a group for each 'patch-type'
%pcats = {'day'};  % make a panel for each day
pcats = {'subject'};

[I, C] = findall( labels, 'day' );
ps = nan( numel(I), 1 );
n_trials_comp = nan( numel(I), 1 );
n_trials_coop = nan( numel(I), 1 );
for i = 1:numel(I)
  comp = find( labels, 'compete', I{i} );
  coop = find( labels, 'cooperate', I{i} );
  comp_rt = reaction_time(comp);
  coop_rt = reaction_time(coop);
  n_trials_comp(i) = numel( comp_rt );
  n_trials_coop(i) = numel( coop_rt );
  ps(i) = ranksum( comp_rt, coop_rt );
end

pl = plotlabeled.make_common();
pl.summary_func = @nanmedian;
% axs = pl.bar( reaction_time, labels, xcats, gcats, pcats );
% axs = pl.violinplot( reaction_time, labels, gcats, pcats );
axs = pl.violinplot( reaction_time, labels, xcats, [] );
