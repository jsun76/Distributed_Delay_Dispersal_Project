function rateInfo = estimate_convergence_rate(t, h1, h2, params)
%ESTIMATE_CONVERGENCE_RATE Fit exponential convergence of phase lag.
%
% This is a simulation-based proxy for Barbara's convergence-rate figure.
% Near bifurcations the fit can be poor or non-monotone; inspect rSquared.

if nargin < 4 || isempty(params)
    params = barbara_default_parameters();
end

phaseOptions = struct('transientFraction', 0.05);
phaseInfo = phase_difference_series(t, h1, h2, params, phaseOptions);

phase = phaseInfo.phaseValues;
phaseTimes = phaseInfo.phaseTimes;

rateInfo = struct();
rateInfo.rate = NaN;
rateInfo.slope = NaN;
rateInfo.intercept = NaN;
rateInfo.rSquared = NaN;
rateInfo.finalPhase = phaseInfo.finalPhase;
rateInfo.phaseInfo = phaseInfo;
rateInfo.fitTimes = [];
rateInfo.fitErrors = [];

if numel(phase) < 6 || ~isfinite(phaseInfo.finalPhase)
    return;
end

finalCount = max(3, ceil(numel(phase) / 4));
finalPhase = median(phase(end - finalCount + 1:end));
errors = abs(phase - finalPhase);

timeStart = phaseTimes(1) + 0.1 * (phaseTimes(end) - phaseTimes(1));
timeStop = phaseTimes(1) + 0.85 * (phaseTimes(end) - phaseTimes(1));
mask = phaseTimes >= timeStart & phaseTimes <= timeStop & ...
    errors >= params.minPhaseErrorForFit & isfinite(errors);

if sum(mask) < 4
    return;
end

fitTimes = phaseTimes(mask);
fitErrors = errors(mask);
coeff = polyfit(fitTimes, log(fitErrors), 1);
predicted = polyval(coeff, fitTimes);
residuals = log(fitErrors) - predicted;
centered = log(fitErrors) - mean(log(fitErrors));

rateInfo.slope = coeff(1);
rateInfo.intercept = coeff(2);
rateInfo.rate = max(0, -coeff(1));
rateInfo.fitTimes = fitTimes;
rateInfo.fitErrors = fitErrors;

if sum(centered .^ 2) > 0
    rateInfo.rSquared = 1 - sum(residuals .^ 2) / sum(centered .^ 2);
end
end
