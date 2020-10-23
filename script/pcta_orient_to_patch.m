function res = pcta_orient_to_patch(pos, patch_loc, screen_center, do_rotate)

%%

validateattributes( pos, {'double'}, {'nrows', 2}, mfilename, 'position' );
validateattributes( patch_loc, {'double'}, {'vector', 'nrows', 2} ...
  , mfilename, 'patch_loc' );
validateattributes( screen_center, {'double'}, {'numel', 2} ...
  , mfilename, 'screen_center' );

res = pos;

if ( do_rotate )

  to_patch = patch_loc(:) - screen_center(:);
  to_patch_dir = to_patch ./ sqrt(sum(to_patch .* to_patch));

  ortho_patch_dir = to_patch_dir;
  ortho_patch_dir(2) = to_patch_dir(1);
  ortho_patch_dir(1) = -to_patch_dir(2);

  m = [ ortho_patch_dir(:), to_patch_dir(:) ];

  for i = 1:size(res, 2)
    res(:, i) = m \ res(:, i);
  end

  new_patch_loc = m \ patch_loc(:);
  res = res - new_patch_loc;
  
else
  res = res - patch_loc;
end

end