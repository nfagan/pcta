function monitor_info = monitor_info(source_file)

monitor_info = struct();
monitor_info.identifier = source_file.identifier;
monitor_info.height = 14.5;
monitor_info.dist = 52;
monitor_info.rect = get( source_file.window.Rect );
monitor_info.vertical_resolution = ...
  shared_utils.rect.height( get(source_file.window.Rect) );

end