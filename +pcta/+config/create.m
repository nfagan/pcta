function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = pcta.config.constants();

conf = struct();

%   ID
conf.(const.config_id) = true;

project_dir = pcta.util.get_project_folder();

%   PATHS
PATHS = struct();
PATHS.data_root = fullfile( project_dir, 'data' );
PATHS.repositories = fileparts( project_dir );
PATHS.raw_subdirectory = 'raw';

conf.PATHS = PATHS;

if ( do_save )
  pcta.config.save( conf );
end

end