function [params, loop_runner] = get_params_and_loop_runner(inputs, output, defaults, args)

%   GET_PARAMS_AND_LOOP_RUNNER -- Parse main-function inputs and obtain
%     parameters and loop runner.

if ( nargin < 4 )
  args = {};
end
if ( nargin < 3 )
  defaults = struct();
end

defaults = shared_utils.struct.union( pcta.get_common_make_defaults, defaults );
params = shared_utils.general.parsestruct( defaults, args );

if ( isfield(params, 'loop_runner') && ...
     pcta.util.is_valid_loop_runner(params.loop_runner) )
  loop_runner = params.loop_runner;
  return
end

loop_runner = pcta.get_looped_make_runner( params );

conf_arg = {};

if ( isfield(params, 'config') )
  conf_arg = { params.config };
end

loop_runner.input_directories = pcta.get_processed_dir( inputs, conf_arg{:} );
loop_runner.output_directory = pcta.get_processed_dir( output, conf_arg{:} );

end