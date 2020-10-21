function initiated = pcta_did_initiate(trial_data)

initiated = arrayfun( @(x) did_initiate(x), trial_data );
initiated = initiated(:);

end

function tf = did_initiate(trial)

tf = ~isnan( trial.fixation.did_fixate ) && trial.fixation.did_fixate;

end