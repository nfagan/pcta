function pcta_make_trial_data(varargin)

defaults = pcta.get_common_make_defaults();
inputs = { 'source' };
output = 'trial_data';

[~, loop_runner] = ...
  pcta.get_params_and_loop_runner( inputs, output, defaults, varargin );

loop_runner.run( @main );

end

function trial_data_file = main(files)

trial_data_file = pcta.make.trial_data( files('source') );

end