function label = classify_phase_locking(phase, params)
%CLASSIFY_PHASE_LOCKING Convert phase lag to a synchronization label.

if nargin < 2 || isempty(params)
    params = barbara_default_parameters();
end

if isempty(phase) || ~isfinite(phase)
    label = 'undetermined';
elseif phase <= params.inPhaseTolerance
    label = 'in-phase';
elseif abs(pi - phase) <= params.antiPhaseTolerance
    label = 'anti-phase';
else
    label = 'out-of-phase';
end
end
