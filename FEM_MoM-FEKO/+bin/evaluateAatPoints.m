function AFCN = evaluateAatPoints(P, ind, Lmax)

[R, theta, phi] = bin.cart2sph(P(:, 1), P(:, 2), P(:, 3));

nSW  = size(ind, 2);
AFCN = nan(size(P, 1), 3, nSW);
for lmax = 1:Lmax
    degreeL = repmat(lmax, [lmax+1, 1]);
    orderM  = (0:lmax).';
    
    [Y1, Y2] = sphWaves.functionY( ...
        degreeL, orderM, theta, phi);
    
    A = nan(2, 2, lmax+1, size(R, 1), 3); % [tau, sigma, points, [x y z]]
    A(1, 1, :, :, :) = imag(Y1);
    A(1, 2, :, :, :) = real(Y1);
    A(2, 2, :, :, :) = real(Y2);
    A(2, 1, :, :, :) = imag(Y2);
    
    for m = 0:lmax
        for sigma = 1:2
            for tau = 1:2
                vec = [lmax; m; sigma; tau];
                pos = find(all(vec == ind(1:4, :), 1));
                if ~isempty(pos)
                    AFCN(:, :, ind(5, pos)) = ...
                        squeeze(A(tau, sigma, m+1, :, :));
                end
            end
        end
    end
end