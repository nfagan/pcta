function pcta_make_meta(varargin)

defaults = pcta.get_common_make_defaults();
inputs = { 'source' };
output = 'meta';

[~, loop_runner] = ...
  pcta.get_params_and_loop_runner( inputs, output, defaults, varargin );

loop_runner.run( @main );

end

function meta_file = main(files)

meta_file = pcta.make.meta( files('source') );

end