function extracted = extract_matcont_lc_run(x, s, f, shape, branchLabel, options)
%EXTRACT_MATCONT_LC_RUN Convert MatCont LC output into plot-ready records.

nphase = 4 + 2 * shape;
tps = round((size(x, 1) - 2) / nphase);
if tps < 4 || nphase * tps + 2 ~= size(x, 1)
    error('extract_matcont_lc_run:UnexpectedSize', ...
        'Unexpected MatCont limit-cycle state size.');
end

emptyPoint = struct('shape', [], 'branch', '', 'tau', [], 'period', [], ...
    'phase', [], 'stable', [], 'maxNontrivialMultiplier', [], ...
    'amplitudeH1', [], 'amplitudeH2', [], 'minH1', [], 'maxH1', []);
points = repmat(emptyPoint, size(x, 2), 1);

for col = 1:size(x, 2)
    [phase, amp1, amp2, minH1, maxH1] = cycle_metrics(x(:, col), nphase, tps);
    multipliers = column_multipliers(f, nphase, col);
    [stable, maxMult] = classify_floquet_stability(multipliers, ...
        options.multiplierTolerance);

    points(col).shape = shape;
    points(col).branch = branchLabel;
    points(col).tau = x(end, col);
    points(col).period = x(end - 1, col);
    points(col).phase = phase;
    points(col).stable = stable;
    points(col).maxNontrivialMultiplier = maxMult;
    points(col).amplitudeH1 = amp1;
    points(col).amplitudeH2 = amp2;
    points(col).minH1 = minH1;
    points(col).maxH1 = maxH1;
end

specialPoints = extract_special_points(x, s, nphase, tps, shape, branchLabel);

extracted = struct();
extracted.points = points;
extracted.specialPoints = specialPoints;
end

function [phase, amp1, amp2, minH1, maxH1] = cycle_metrics(xcol, nphase, tps)
period = xcol(end - 1);
ups = reshape(xcol(1:(nphase * tps)), nphase, tps);
h1 = ups(1, :);
h2 = ups(3, :);

[~, idx1] = max(h1);
[~, idx2] = max(h2);
lagIndex = abs(idx2 - idx1);
lagIndex = min(lagIndex, tps - lagIndex);
phase = 2 * pi * lagIndex / max(1, tps - 1);
phase = min(phase, pi);

amp1 = max(h1) - min(h1);
amp2 = max(h2) - min(h2);
minH1 = min(h1);
maxH1 = max(h1);

if ~isfinite(period) || period <= 0
    phase = NaN;
end
end

function multipliers = column_multipliers(f, nphase, col)
if isempty(f) || size(f, 1) < nphase || col > size(f, 2)
    multipliers = [];
    return;
end
multipliers = f((end - nphase + 1):end, col);
multipliers = multipliers(isfinite(real(multipliers)) & isfinite(imag(multipliers)));
end

function [stable, maxMult] = classify_floquet_stability(multipliers, tolerance)
if isempty(multipliers)
    stable = NaN;
    maxMult = NaN;
    return;
end

[~, trivialIdx] = min(abs(multipliers - 1));
multipliers(trivialIdx) = [];
if isempty(multipliers)
    stable = NaN;
    maxMult = NaN;
    return;
end

maxMult = max(abs(multipliers));
stable = maxMult < 1 + tolerance;
end

function specialPoints = extract_special_points(x, s, nphase, tps, shape, branchLabel)
emptySpecial = struct('shape', [], 'branch', '', 'type', '', 'tau', [], ...
    'phase', [], 'index', []);
specialPoints = repmat(emptySpecial, 0, 1);

for k = 1:numel(s)
    if ~isfield(s(k), 'msg') || isempty(s(k).msg) || ~isfield(s(k), 'index')
        continue;
    end
    type = special_type_from_message(s(k).msg);
    if isempty(type)
        continue;
    end
    col = s(k).index;
    if col < 1 || col > size(x, 2)
        continue;
    end
    [phase, ~, ~, ~, ~] = cycle_metrics(x(:, col), nphase, tps);
    specialPoints(end + 1, 1).shape = shape; %#ok<AGROW>
    specialPoints(end).branch = branchLabel;
    specialPoints(end).type = type;
    specialPoints(end).tau = x(end, col);
    specialPoints(end).phase = phase;
    specialPoints(end).index = col;
end
end

function type = special_type_from_message(message)
message = lower(strtrim(message));
if contains(message, 'branch point')
    type = 'BPC';
elseif contains(message, 'limit point')
    type = 'LPC';
else
    type = '';
end
end
