function f = projectFarFields(P_xyz, F, AFCN, ind, lq_weights)

[~, theta, phi] = models.utilities.converter.cart2sph( ...
    P_xyz(:, 1), P_xyz(:, 2), P_xyz(:, 3));

constants = bin.constants();

nSW = size(AFCN, 3);
nP  = size(F, 3);

f = nan(nSW, nP);
for sw = 1:nSW
    [An(:,1), An(:,2), An(:,3)] = sphWaves.vecSph2Cart(...
        AFCN(:, 1, sw), AFCN(:, 2, sw), AFCN(:, 3, sw), theta, phi);
	l   = ind(1, ind(5, sw));
    tau = ind(4, ind(5, sw));
    K   = (1j)^(-l-2+tau);

    for pw = 1:nP
        f(sw, pw) = K/sqrt(constants.Z0) * ...
            sum(dot(An, F(:, :, pw), 2) .* lq_weights);
    end
end

