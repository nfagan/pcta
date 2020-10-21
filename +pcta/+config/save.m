
function save(conf)

%   SAVE -- Save the config file.

pcta.config.assert__is_config( conf );
const = pcta.config.constants();
fprintf( '\n Config file saved\n\n' );
save( fullfile(const.config_folder, const.config_filename), 'conf' );

pcta.config.load( '-clear' );

end