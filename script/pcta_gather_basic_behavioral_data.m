function outs = pcta_gather_basic_behavioral_data(varargin)

defaults = pcta.get_common_make_defaults();

inputs = {'trial_data', 'edf', 'meta', 'monitor_info'};

[params, runner] = ...
  pcta.get_params_and_loop_runner( inputs, '', defaults, varargin );

runner.load_func = @load_or_empty;
runner.convert_to_non_saving_with_output();

results = runner.run( @main );
outputs = shared_utils.pipeline.extract_outputs_from_results( results );

if ( isempty(outputs) )
  outs = struct();
else
  outs = shared_utils.struct.soa( outputs );
end

end

function outs = main(files)

trial_data_file = files('trial_data');
edf_file = files('edf');
meta_file = files('meta');
monitor_file = files('monitor_info');

outs = pcta_basic_behavioral_data( trial_data_file, edf_file ...
  , meta_file, monitor_file );

end

function file = load_or_empty(file_path)

if ( shared_utils.io.fexists(file_path) )
  file = shared_utils.io.fload( file_path );
else
  file = [];
end

end