function x = load_one_processed(kind, name_or_conf, conf)

%   LOAD_ONE_PROCESSED -- Load a processed file of a given kind.
%
%     file = ... load_one_processed( KIND ); loads a random intermediate
%     file of `KIND`, using the intermediate directory given by the saved
%     config file. An error is thrown if the full directory path to `KIND`
%     does not exist. If no files are present in the directory, `file` is
%     an empty array ([]).
%
%     file = ... load_one_processed( KIND, CONF ) works as above, but
%     uses the intermediate directory given by the config file `CONF`.
%
%     file = ... load_one_processed( KIND, CONTAINING ) where
%     `CONTAINING` is a char vector, attempts to load a file whose
%     file-path includes `CONTAINING`. If no such file exists, `file` is an
%     empty array ([]). The saved-config file is used to get the path to
%     `KIND`.
%
%     file = ... load_one_processed( KIND, CONTAINING, CONF ), where 
%     `CONF` is a config file, uses `CONF` to get the path to the 
%     intermediate folder, instead of the saved config file.
%
%     EXAMPLE //
%
%     events_file = pcta.load_one_intermediate( 'events' );
%     % look for a file called test.mat
%     events_file2 = pcta.load_one_intermediate( 'events', 'test.mat' );
%
%     See also pcta.get_processed_dir

if ( nargin == 2 && isstruct(name_or_conf) )
  name = '';
  conf = name_or_conf;
else
  if ( nargin < 2 ), name_or_conf = ''; end
  if ( nargin < 3 || isempty(conf) ), conf = pcta.config.load(); end
  
  name = name_or_conf;
end

intermediate_dir = pcta.get_processed_dir( kind, conf );
mats = shared_utils.io.find( intermediate_dir, '.mat' );

x = [];

if ( numel(mats) == 0 ), return; end

if ( isempty(name) )
  x = shared_utils.io.fload( mats{1} );
  return;
end

mats = shared_utils.cell.containing( mats, name );

if ( isempty(mats) ), return; end

x = shared_utils.io.fload( mats{1} );

end