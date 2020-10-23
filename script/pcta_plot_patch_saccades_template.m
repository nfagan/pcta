%%

behav_outs = pcta_gather_basic_behavioral_data();

%%

patch_pos = behav_outs.approx_patch_locations;
sacc_pos = behav_outs.saccade_positions;
screen_centers = shared_utils.rect.center( behav_outs.screen_rect );
rt = behav_outs.reaction_time;
labels = behav_outs.labels';

within_rt_bounds = find( rt >= 0.1 & rt <= 0.6 );

non_empty = @(x) ~isempty(x);
non_empty_patch_loc = cellfun( non_empty, patch_pos );
non_empty_sacc_info = cellfun( non_empty, sacc_pos );

non_empties = find( non_empty_patch_loc & non_empty_sacc_info );

[reoriented, in_bounds_sacc_end] = reoriented_saccade_positions( sacc_pos, patch_pos, screen_centers, non_empties ...
  , 'px_thresh', 100 ...
  , 'sample_thresh', 10 ...
  , 'do_rotate', false ...
  , 'use_sacc_end_as_patch_pos', false  ...
);

require_in_bounds_sacc_end = true;
plot_lims = [-250, 250];

base_mask = intersect( non_empties, within_rt_bounds );
if ( require_in_bounds_sacc_end )
  base_mask = intersect( base_mask, find(in_bounds_sacc_end) );
end

mask = fcat.mask( labels, base_mask ...
  , @findnone, '<patch-type>' ...
  , @findnone, '092820' ...
  , @findnone, '101520' ...
);

plot_traces( reoriented, labels', mask ...
  , 'plot_lims', [-250, 250] ...
  , 'color_func', @hsv ...
  , 'patch_size', [100, 100] ...
);

%%

function plot_traces(traces, labels, mask, varargin)

assert_ispair( traces, labels );

defaults = struct();
defaults.plot_lims = [];
defaults.color_func = @hot;
defaults.patch_size = [];
params = shared_utils.general.parsestruct( defaults, varargin );

plot_lims = params.plot_lims;
patch_size = params.patch_size;

pcats = { 'patch-type' };
gcats = { 'day' };

[p_I, p_C] = findall( labels, pcats, mask );
shp = plotlabeled.get_subplot_shape( numel(p_I) );
axs = gobjects( size(p_I) );

for i = 1:numel(p_I)
  ax = subplot( shp(1), shp(2), i );
  cla( ax );
  hold( ax, 'on' );
  axs(i) = ax;
  
  p_ind = p_I{i};
  [g_I, g_C] = findall( labels, gcats, p_ind );
  colors = params.color_func( numel(g_I) );
  leg_hs = gobjects( size(g_I) );
  
  for j = 1:numel(g_I)
    g_ind = g_I{j};
    
    for k = 1:numel(g_ind)
      trace = traces{g_ind(k)};
      h = scatter( ax, trace(1, :), trace(2, :), 'k*' );
      set( h, 'MarkerEdgeColor', colors(j, :) );
      set( h, 'SizeData', 0.2 );
      
      if ( k == 1 )
        leg_hs(j) = h;
      end
    end
  end
    
  legend( leg_hs, g_C );
  title( ax, strrep(strjoin(p_C(:, i), ' | '), '_', ' ') );
  
  if ( ~isempty(patch_size) )
    rpos = [ -patch_size(1)/2, -patch_size(2)/2, patch_size(1), patch_size(2) ];
    rh = rectangle( ax, 'position', rpos );
  end
end

if ( isempty(plot_lims) )
  min_lim = min( arrayfun(@(x) min(min(get(x, 'xlim')), min(get(x, 'ylim'))), axs) );
  max_lim = max( arrayfun(@(x) max(max(get(x, 'xlim')), max(get(x, 'ylim'))), axs) );
  max_v = max( abs(min_lim), abs(max_lim) );

  shared_utils.plot.set_xlims( axs, [-max_v, max_v] );
  shared_utils.plot.set_ylims( axs, [-max_v, max_v] );
else
  shared_utils.plot.set_xlims( axs, plot_lims );
  shared_utils.plot.set_ylims( axs, plot_lims );
end

end

function [reoriented, in_bounds_sacc_end] = ...
  reoriented_saccade_positions(sacc_pos, patch_pos, screen_centers, mask, varargin)

defaults = struct();
defaults.sample_thresh = 10;
defaults.px_thresh = 50;
defaults.do_rotate = false;
defaults.use_sacc_end_as_patch_pos = false;

params = shared_utils.general.parsestruct( defaults, varargin );
px_thresh = params.px_thresh;
sample_thresh = params.sample_thresh;
do_rotate = params.do_rotate;
use_sacc_end_as_patch_pos = params.use_sacc_end_as_patch_pos;

reoriented = cell( numel(sacc_pos), 1 );
in_bounds_sacc_end = false( size(reoriented) );

r = [ -px_thresh/2, -px_thresh/2, px_thresh/2, px_thresh/2 ];

for i = 1:numel(mask)
  ind = mask(i);
  sp = sacc_pos{ind};
  pp = patch_pos{ind};
  sc = screen_centers(ind, :);
  
  if ( use_sacc_end_as_patch_pos )
    last_samples = sample_n_last_cols( sp, sample_thresh );
    mean_last = nanmean( last_samples, 2 );
    pp = mean_last;
  end
  
  sp = pcta_orient_to_patch( sp, pp, sc, do_rotate );
  
  last_samples = sample_n_last_cols( sp, sample_thresh );
  mean_last = nanmean( last_samples, 2 );
  ib = rect_in_bounds( r, mean_last(1), mean_last(2) );
  in_bounds_sacc_end(ind) = ib;
  
  reoriented{ind} = sp;
end

end

function last = sample_n_last_cols(s, num)

cols = size( s, 2 );
last = s(:, max(1, cols-num+1):end);

end

function tf = rect_in_bounds(rect, x, y)

in_x = x >= rect(1) & x <= rect(3);
in_y = y >= rect(2) & y <= rect(4);

tf = in_x & in_y;

end

