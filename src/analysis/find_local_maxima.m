function [peakTimes, peakValues, peakIdx] = find_local_maxima(t, x, minSeparation)
%FIND_LOCAL_MAXIMA Lightweight local maxima detector without toolboxes.

if nargin < 3 || isempty(minSeparation)
    minSeparation = 0;
end

t = t(:);
x = x(:);

if numel(t) ~= numel(x)
    error('find_local_maxima:SizeMismatch', ...
        'Time and signal vectors must have the same length.');
end

if numel(x) < 3
    peakTimes = [];
    peakValues = [];
    peakIdx = [];
    return;
end

candidateIdx = find(x(2:end - 1) > x(1:end - 2) & ...
    x(2:end - 1) >= x(3:end)) + 1;

if isempty(candidateIdx)
    peakTimes = [];
    peakValues = [];
    peakIdx = [];
    return;
end

signalRange = max(x) - min(x);
if signalRange > 0
    minHeight = min(x) + 0.25 * signalRange;
    candidateIdx = candidateIdx(x(candidateIdx) >= minHeight);
end

if isempty(candidateIdx)
    peakTimes = [];
    peakValues = [];
    peakIdx = [];
    return;
end

if minSeparation <= 0
    peakIdx = candidateIdx;
else
    peakIdx = candidateIdx(1);
    for k = 2:numel(candidateIdx)
        thisIdx = candidateIdx(k);
        lastIdx = peakIdx(end);
        if t(thisIdx) - t(lastIdx) >= minSeparation
            peakIdx(end + 1, 1) = thisIdx; %#ok<AGROW>
        elseif x(thisIdx) > x(lastIdx)
            peakIdx(end) = thisIdx;
        end
    end
end

% Refine each sample-grid maximum with a local quadratic. Returning only
% grid times quantizes phase lags and makes convergence fits depend on the
% requested output grid rather than on the dynamics.
peakTimes = t(peakIdx);
peakValues = x(peakIdx);
for k = 1:numel(peakIdx)
    idx = peakIdx(k);
    if idx <= 1 || idx >= numel(x)
        continue;
    end
    centerTime = t(idx);
    localTimes = t(idx - 1:idx + 1) - centerTime;
    coeff = polyfit(localTimes, x(idx - 1:idx + 1), 2);
    if coeff(1) >= 0 || ~all(isfinite(coeff))
        continue;
    end
    refinedTime = centerTime - coeff(2) / (2 * coeff(1));
    if refinedTime >= t(idx - 1) && refinedTime <= t(idx + 1)
        peakTimes(k) = refinedTime;
        peakValues(k) = polyval(coeff, refinedTime);
    end
end
end
