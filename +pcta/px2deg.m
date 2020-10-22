function deg = px2deg(px, monitor_info)

deg = hwwa.px2deg( px, monitor_info.height, monitor_info.dist ...
  , monitor_info.vertical_resolution );

end