function dzdt = DDDModel(~, z, alpha, mu, eps, d, numpatches, p, tau)
%DDDMODEL Legacy two-patch form of Gravel's distributed-delay model.

    % z: vector of size numpatches (N) * 2 + N * p. First N numbers are preys in
    % patches N, Nth to 2Nth numbers are predators in patches in N, rest
    % are gamma functions with the linear chain trick.

    %Splitting the column vector for the ODE solver used into the
    %corresponding prey, predator columns, then for gamma functions
    h = z(1:numpatches);
    pred = z(numpatches+1:numpatches*2);
    y = z(numpatches*2+1:end);

    newy = reshape(y, numpatches, p);

    dydt = zeros(numpatches, p);

    if numpatches ~= 2
        error('DDDModel:TwoPatchesOnly', ...
            'Barbara Gravel''s model and this implementation use two patches.');
    end
    if tau <= 0
        error('DDDModel:PositiveTau', 'tau must be positive in the chain model.');
    end

    % Equation (11): predation is inside the factor 1/epsilon, and arrivals
    % are the last chain state belonging to the other patch.
    arrivals = flipud(newy(:, end));
    dNdt = (h .* (1 - alpha .* h) - h .* pred ./ (1 + h)) ./ eps + ...
        d .* (arrivals - h);
    dPdt = h.*pred ./ (1 + h) - mu .* pred;

    %Terms derived from linear chain trick
    inity0 = sum(h) - h;

    dydt(:, 1) = p/tau * (inity0 - newy(:,1));

    for j = 2:p
        dydt(:, j)  = p/tau .* (newy(:, j - 1) - newy(:, j));           
    end

    dydt = dydt(:);

    %Return
    dzdt = [dNdt; dPdt; dydt];
end
