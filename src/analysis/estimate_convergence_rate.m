function rateInfo = estimate_convergence_rate(t, h1, h2, params)
%ESTIMATE_CONVERGENCE_RATE Fit exponential convergence of phase lag.
%
% Gravel states that the rate is extracted only where phase convergence is
% exponential. We therefore select a contiguous log-linear decay window
% and return NaN when the simulation contains no defensible such window.

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
rateInfo.fitStatus = 'insufficient phase peaks';

if numel(phase) < 6 || ~isfinite(phaseInfo.finalPhase)
    return;
end

finalCount = max(5, ceil(numel(phase) / 5));
finalPhase = median(phase(end - finalCount + 1:end));
errors = abs(phase - finalPhase);

timeStart = phaseTimes(1) + 0.05 * (phaseTimes(end) - phaseTimes(1));
timeStop = phaseTimes(1) + 0.95 * (phaseTimes(end) - phaseTimes(1));
mask = phaseTimes >= timeStart & phaseTimes <= timeStop & ...
    errors >= params.minPhaseErrorForFit & isfinite(errors) & errors < pi;
validIdx = find(mask);
if numel(validIdx) < 8
    rateInfo.fitStatus = 'too few above-noise phase errors';
    return;
end

% Do not bridge gaps caused by errors falling below the numerical floor.
breaks = [0; find(diff(validIdx) > 1); numel(validIdx)];
best = struct('score', -Inf, 'coeff', [], 'rSquared', NaN, 'idx', []);
for block = 1:(numel(breaks) - 1)
    blockIdx = validIdx((breaks(block) + 1):breaks(block + 1));
    if numel(blockIdx) < 8
        continue;
    end
    for first = 1:(numel(blockIdx) - 7)
        for last = (first + 7):numel(blockIdx)
            idx = blockIdx(first:last);
            fit = fit_log_line(phaseTimes(idx), errors(idx));
            if fit.slope >= 0 || fit.logDrop < log(2)
                continue;
            end
            score = fit.rSquared * fit.logDrop * sqrt(numel(idx));
            if fit.rSquared >= 0.80 && score > best.score
                best.score = score;
                best.coeff = fit.coeff;
                best.rSquared = fit.rSquared;
                best.idx = idx;
            end
        end
    end
end

if isempty(best.idx)
    rateInfo.fitStatus = 'no exponential decay window (R^2 >= 0.80)';
    return;
end

rateInfo.slope = best.coeff(1);
rateInfo.intercept = best.coeff(2);
rateInfo.rate = -best.coeff(1);
rateInfo.rSquared = best.rSquared;
rateInfo.fitTimes = phaseTimes(best.idx);
rateInfo.fitErrors = errors(best.idx);
rateInfo.fitStatus = 'exponential window found';
end

function fit = fit_log_line(times, errors)
values = log(errors);
coeff = polyfit(times, values, 1);
predicted = polyval(coeff, times);
residuals = values - predicted;
centered = values - mean(values);
denominator = sum(centered .^ 2);
if denominator > 0
    rSquared = 1 - sum(residuals .^ 2) / denominator;
else
    rSquared = -Inf;
end
fit = struct('coeff', coeff, 'slope', coeff(1), ...
    'rSquared', rSquared, 'logDrop', values(1) - values(end));
end
