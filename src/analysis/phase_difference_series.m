function phaseInfo = phase_difference_series(t, h1, h2, params, options)
%PHASE_DIFFERENCE_SERIES Estimate phase lag from prey maxima.
%
% The returned phase is reduced to [0, pi], so zero means in-phase and pi
% means anti-phase.

if nargin < 4 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 5 || isempty(options)
    options = struct();
end

if isfield(options, 'transientFraction')
    transientFraction = options.transientFraction;
else
    transientFraction = params.transientFraction;
end

t = t(:);
h1 = h1(:);
h2 = h2(:);

startTime = t(1) + transientFraction * (t(end) - t(1));
windowMask = t >= startTime;

tw = t(windowMask);
h1w = h1(windowMask);
h2w = h2(windowMask);

roughSeparation = 0.25 * params.singlePatchPeriod;
[peakTimes1, peakValues1] = find_local_maxima(tw, h1w, roughSeparation);
[peakTimes2, peakValues2] = find_local_maxima(tw, h2w, roughSeparation);

if numel(peakTimes1) >= 3
    period = median(diff(peakTimes1));
elseif numel(peakTimes2) >= 3
    period = median(diff(peakTimes2));
else
    period = NaN;
end

phaseTimes = [];
phaseValues = [];
lags = [];

if isfinite(period) && period > 0 && ~isempty(peakTimes1) && ~isempty(peakTimes2)
    for k = 1:numel(peakTimes1)
        [nearestDistance, nearestIdx] = min(abs(peakTimes2 - peakTimes1(k)));
        if nearestDistance <= 0.75 * period
            rawLag = peakTimes2(nearestIdx) - peakTimes1(k);
            lag = mod(rawLag, period);
            if lag > 0.5 * period
                lag = period - lag;
            end
            phaseTimes(end + 1, 1) = peakTimes1(k); %#ok<AGROW>
            phaseValues(end + 1, 1) = 2 * pi * lag / period; %#ok<AGROW>
            lags(end + 1, 1) = lag; %#ok<AGROW>
        end
    end
end

if isempty(phaseValues)
    finalPhase = NaN;
else
    tailCount = max(1, ceil(numel(phaseValues) / 3));
    finalPhase = median(phaseValues(end - tailCount + 1:end));
end

phaseInfo = struct();
phaseInfo.period = period;
phaseInfo.phaseTimes = phaseTimes;
phaseInfo.phaseValues = phaseValues;
phaseInfo.lags = lags;
phaseInfo.finalPhase = finalPhase;
phaseInfo.peakTimes1 = peakTimes1;
phaseInfo.peakValues1 = peakValues1;
phaseInfo.peakTimes2 = peakTimes2;
phaseInfo.peakValues2 = peakValues2;
end
