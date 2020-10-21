function dr = dataroot(conf)

if ( nargin < 1 || isempty(conf) )
  conf = pcta.config.load();
end

pcta.config.assert__is_config( conf );
dr = conf.PATHS.data_root;

end