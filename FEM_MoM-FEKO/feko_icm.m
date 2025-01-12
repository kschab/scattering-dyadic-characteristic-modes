% FEKO_ICM.M: Iterative solver for scattering-based CMs
% 
% This script utilizes all input variables provided by the user in the
% staring script (see files ExXX_YYY.m) and calculates XXXXX
% 
% (c) 2022-2025, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

options.deleteAuxFiles  = true; % perform cleanup
options.preFEKOfileName = 'characteristicModeEvaluation';

if ~isfield(options, 'nModes')
    options.nModes = 10;
end
if ~isfield(options, 'relativeError')
    options.relativeError = 1e-4;
end
if ~isfield(options, 'eigSolver')
    options.eigSolver   = 'std'; % {std, subs}
end
fprintf(1, '''%s'' Solver used for the iterative CMA evaluation.\n', ...
    upper(options.eigSolver));

if strcmp(options.eigSolver, 'subs')
    fprintf(1, 'Substructure iterative solver, two models assumed.\n');
else
    fprintf(1, 'Standard iterative solver, one model assumed.\n')
end

if ~isfield(options, 'adaIters')
    options.eigSolver   = 0;
end
if ~isfield(options, 'adaMSmax')
    options.eigSolver   = inf;
end

% Assign file name
fullFileName = fullfile('data', [outputFileName '.mat']);

%% ------------------------------------------------------------------------
% Calculate characteristic modes by iterative procedure approximating
% scattering dyadics (UNIFORM SAMPLING)
clear CMA_IP;
CMA_IP.k0        = k0;
CMA_IP.model     = model;
CMA_IP.materials = Materials;

t0 = tic;
wtb = waitbar(0, 'Evaluating CMA with iterative solver...', ...
    'Name', 'Evaluating CMA with iterative solver...');
Nk0 = length(k0);
for m = 1:Nk0
    [V, N, quadrature, PW, FF, Info] = ...
        feko.calculateCharacteristicModesIterativeEigs(...
        model, k0(m), Materials, nDegree, solver, EXTR, options);
    N = diag(N);

    % Normalize modal excitations to unitary size for substructure case
    if strcmp(options.eigSolver, 'subs')

        V = bin.normalizeAnToRadiatedPower(...
            V, diag(repmat(quadrature.w, 2, 1)));
    end

    % Sort the data from the most modal significant to the less...
    [~, inds] = sort(abs(N), 'descend');

    % Save the data
    CMA_IP.tn_orig(1:options.nModes,m)   = N(inds(1:options.nModes));
    CMA_IP.Fn_orig(:,1:options.nModes,m) = V(:, inds(1:options.nModes));

    CMA_IP.Info(m) = Info;

    try
        save(fullfile('data', [outputFileName '.mat']), 'CMA_IP', '-append');
    catch % When 'data' folder and/or *.mat file do not exist
        save(fullfile('data', [outputFileName '.mat']), 'CMA_IP');
    end    

    tt = toc(t0);
    waitbar(m/Nk0, wtb, ...
        sprintf('%d/%d done\n Elapsed: %1.0fs | Remaining: %1.0fs', ...
        m, Nk0, tt, tt*(1/m*Nk0 - 1)));    
end
delete(wtb);

% Assign all output variables
CMA_IP.W         = diag(repmat(quadrature.w, 2, 1));
CMA_IP.P         = [quadrature.x, quadrature.y, quadrature.z];
CMA_IP.PW        = PW;
CMA_IP.FF        = FF;
CMA_IP.tt        = toc(t0);
CMA_IP.type      = options.eigSolver;

% Far-field tracking
CMA_IP = bin.farFieldTracking(CMA_IP);

% Save the data
try
    save(fullFileName, 'CMA_IP', '-append');
catch % When 'data' folder and/or *.mat file do not exist
    save(fullFileName, 'CMA_IP');
end
fprintf(2, '*** Iter-CMA Evaluation complete (UNIFORM SAMPLING)! (Total time: %1.0fs) *** \n', ...
    CMA_IP.tt);

%% ------------------------------------------------------------------------
% Calculate characteristic modes by iterative procedure approximating
% scattering dyadics (ADAPTIVE SAMPLING)

% Plot the results of uniform solver
fh = @(x) bin.k0tof0(x);
ms = @(x) abs(x);

hndl.fig = figure('color', 'w', 'pos', [50 50 900 700]);
hndl.ax  = axes('parent', hndl.fig);
xlabel('frequency $f$ (Hz)', 'FontSize', 14, 'Interpreter', 'LaTeX');
ylabel('modal significance $|t_n|$', 'FontSize', 14, 'Interpreter', 'LaTeX');

% Add data from uniform solver:
hndl.ln{1}  = plot(fh(CMA_IP.k0), ms(CMA_IP.tn), '-o');
xlim([fh(CMA_IP.k0(1))*(1-1e5*eps), fh(CMA_IP.k0(end))*(1+1e5*eps)]);
grid on;
hold on;

% Start adaptive solver
thisIt = 0;
totK0  = CMA_IP.k0(end) - CMA_IP.k0(1); % for identifying most signif. mode
if totK0 > 0  % start adaptive solver in case of finite band only
while thisIt < options.adaIters
    thisIt = thisIt + 1;
    
    %----------------------------------------------------------------------
    % Find gaps between MS of the dominant mode:
    % Find the most significant mode
    avMS = (abs(CMA_IP.tn(:, 1:(end-1))) + abs(CMA_IP.tn(:, 2:end)))/2;
    spectralSignificance = sum(avMS .* diff(CMA_IP.k0), 2) / totK0;
    [~, mostSigMode] = max(spectralSignificance);
%     mostSigMode = 6;

    % Add new samples
    k0piv = find(abs(diff(abs(CMA_IP.tn(mostSigMode, :)))) > options.adaMSmax);
    k0new = (CMA_IP.k0(k0piv) + CMA_IP.k0(k0piv+1)) / 2;

    % k0piv = [36 37 59 60 85 86 176 177 202 203 244 245];
    % k0new = (CMA_IP.k0(k0piv) + CMA_IP.k0(k0piv+1)) / 2;

    %----------------------------------------------------------------------
    % Find peaks for other (reasonable) modes
    if isempty(k0new)
        usedModes     = 1:6;  % used modes with respect to the highest peak
        minPeakHeight = 0.2;  % minimum MS to take the peak into account
        minPeakPromin = 0.03; % is the marker isolated?

        % Find the highest peaks
        maxPeaks = max(ms(CMA_IP.tn), [], 2);
        [~, inds] = sort(maxPeaks, 'descend');
        
        % Take only first nModes into consideration
        modesToRefine = inds(usedModes);
        
        % Get all the peaks together
        k0LOC = [];
        for nMd = 1:length(usedModes)
            % Find all peaks
            [~, k0loc] = findpeaks(ms(CMA_IP.tn(modesToRefine(nMd), :)), ...
                'MinPeakHeight', minPeakHeight);

            % Check if the peak is represented by well isolated marker
            dMSBellow = abs(ms(CMA_IP.tn(modesToRefine(nMd), k0loc+1)) - ...
                            ms(CMA_IP.tn(modesToRefine(nMd), k0loc)));
            dMSAbove  = abs(ms(CMA_IP.tn(modesToRefine(nMd), k0loc-1)) - ...
                            ms(CMA_IP.tn(modesToRefine(nMd), k0loc)));
            dMS = any([dMSBellow; dMSAbove] > minPeakPromin);
            
            % Add point into list
            k0LOC = [k0LOC k0loc(dMS)];
        end
        k0LOC = unique(k0LOC);
        
        % Add samples below LOCS
        meanShift = @(k0, shift) mean(CMA_IP.k0(repmat(k0, 2, 1) + [0; shift]));
        
        if ~isempty(k0LOC)
            % Take one sample above and one below prominent peak
            k0bellow = meanShift(k0LOC(k0LOC > 1), -1);
            k0above  = meanShift(k0LOC(k0LOC < size(CMA_IP.tn, 2)), +1);
            
            % Add all new sample together, consider final numerical precision
            k0new = uniquetol([k0bellow, k0above]);
    
            % Show modes used to find new frequency samples around peaks
            set(hndl.ln{thisIt}(usedModes), 'LineWidth', 2);
        end
    end

    %----------------------------------------------------------------------
    % Add actual markers
    X = reshape([fh(k0new); fh(k0new); NaN(1, length(k0new))], 1, []);
    Y = reshape(repmat([0; 1; NaN], 1, length(k0new)), 1, []);
    
    hndl.mrk{thisIt} = line(hndl.ax, 'XData', X, 'YData', Y, ...
        'LineStyle', '--', 'LineWidth', 0.5, 'Color', 'r');

    %----------------------------------------------------------------------
    % Calculate with uniform solver
    t0 = tic;
    wtbStr = ['IT: ' num2str(thisIt) ' | Evaluating CMA with iterative solver...'];
    wtb = waitbar(0, wtbStr, 'Name', wtbStr);
    Nk0 = length(k0new);
    for m = 1:Nk0
        try % (Dummy workaround for the cases when FEKO solver terminates unexpectedly
            [V, N, quadrature, PW, FF, Info] = ...
                feko.calculateCharacteristicModesIterativeEigs(...
                model, k0new(m), Materials, nDegree, solver, EXTR, options);
            N = diag(N);
        
            % Sort the data from the most modal significant to the less...
            [~, inds] = sort(abs(N), 'descend');
        
            % Store data into CMA_IP variable
            CMA_IP.tn_orig(1:options.nModes, end+1)    = N(inds(1:options.nModes));
            CMA_IP.Fn_orig(:, 1:options.nModes, end+1) = V(:, inds(1:options.nModes));
            CMA_IP.k0(end+1)   = k0new(m);
            CMA_IP.Info(end+1) = Info;
        
            % Save data
            save(fullFileName, 'CMA_IP', '-append');
        end

        % Update waitbar
        tt = toc(t0);
        waitbar(m/Nk0, wtb, ...
            sprintf('%d/%d done\n Elapsed: %1.0fs | Remaining: %1.0fs', ...
            m, Nk0, tt, tt*(1/m*Nk0 - 1)));    
    end
    delete(wtb);

    % Far-field tracking
    CMA_IP = bin.farFieldTracking(CMA_IP);

    % Save data
    save(fullFileName, 'CMA_IP', '-append');

    % Add actual traces
    set(hndl.ln{thisIt}, 'LineStyle', '--', 'LineWidth', 0.5, ...
        'Color', [0.5 0.5 0.5], 'Marker', 'none');
    hndl.ln{1+thisIt} = plot(fh(CMA_IP.k0), ms(CMA_IP.tn), '-o');
    set(hndl.mrk{thisIt}, 'Color', [0.5 0.5 0.5]);
end
fprintf(2, '*** CMA Iteration Evaluation (ADAPTIVE SAMPLING) complete! *** \n');
end

%% Plot results
hndl = bin.plotEigenvalues(bin.k0tof0(CMA_IP.k0), CMA_IP.tn, 'MS', true);
xlabel('frequency $f$ (Hz)', 'Interpreter', 'LaTeX', 'FontSize', 14);