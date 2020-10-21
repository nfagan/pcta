function types = pcta_patch_types(trial_data)

types = arrayfun( @get_types, trial_data );
types = types(:);

end

function types = get_types(trial)

types = {{}};

if ( isfield(trial, 'last_patch_type') && ischar(trial.last_patch_type) && ...
    ~isempty(trial.last_patch_type) )
  types = { {trial.last_patch_type} };
end

end