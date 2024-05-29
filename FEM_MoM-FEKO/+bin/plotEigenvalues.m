function hndl = plotEigenvalues(x, tn, type, addNumbers)
% PLOTEIGENVALUES: plot eigenvalues as tn, lambdan, deltan, or modal
% significance
% 
% Inputs:
%    x    ~ data for x axis (could be f-/omega-/ka-/k- vector
%    tn   ~ eigenvalues of T-matrix (one row one trace)
%    type ~ type of plot {'angle', 'lambda', 'tn', 'MS'}, optional param.
%    addNumbers ~ show indices (boolean)
% 
% Outputs:
%    hndl ~ references to all grapical objects, in particular, hndl.fcn
%           contains prescription of eigenvalues postprocessing (anonymous
%           function)
% 
% (c) 2022, Miloslav Capek, CTU in Prague, miloslav.capek@fel.cvut.cz

% If type of the plot is not specified, show eigen-angles:

nInputs = nargin;
if nInputs < 3
    type = 'angle';
end
if nInputs < 4
    addNumbers = false;
end

% Prepare data processing and graph settings:
switch type
    case 'lambda'
        fcn  = @(x) real((1./x + 1)*1j);
        ylab = '$\lambda_n$ (-)';
        yLim = [-100 100];
    case 'tn'
        fcn  = @(x) x;
        ylab = 'Im($t_n$) (-)';
    case 'MS'
        fcn  = @(x) abs(x);
        ylab = '$|t_n| = 1/\sqrt(1 + \lambda_n^2)$ (-)';
        yLim = [0 1];
    otherwise % 'angle'
        fcn  = @(x) 180*(angle(-x)/pi + 1);
        ylab = '$\delta_n$ (-)';
        yLim = [90 270];
end

M = size(tn, 1);

% Plot data
hndl.fig = figure('color', 'w', 'Position', [50 50 700 500]);
if strcmp(type, 'tn')
    for m = 1:M
        hndl.traces(m) = plot(real(tn(m,:)), imag(tn(m,:)), 'x', ...
            'MarkerSize', 13, 'LineWidth', 2);
        hold on;
    end
    phi = linspace(0, 2*pi, 1001);
    hndl.circle = plot(...
        1/2*cos(phi(1:end-1))-1/2, 1/2*sin(phi(1:end-1)), 'k', ...
        'LineStyle', '--', 'LineWidth', 1);
    axis equal;
    xlabel('Re($t_n$) (-)', 'FontSize', 14, 'Interpreter', 'latex');
else
    hndl.traces = plot(x, fcn(tn), '-d', 'LineWidth', 1, ...
        'MarkerSize', 5, 'MarkerFaceColor', [0.7 0.7 0.7]);
    xlim([x(1)-1e3*eps(x(1)) x(end)+1e3*eps(x(end))]);
    ylim(yLim);
end

ylabel(ylab, 'FontSize', 14, 'Interpreter', 'latex');
grid on;
hndl.fcn = fcn;

labels = arrayfun(@(x) ['m. ' num2str(x)], 1:M, 'UniformOutput', false);
legend(labels, 'FontSize', 9, 'Location', 'best');

if addNumbers
    hold on;
    txtNo = arrayfun(@(n) num2str(n), 1:size(tn, 2), 'UniformOutput', false);
    text(x, abs(tn(1, :)), txtNo, 'HorizontalAlignment', 'center', ...
        'Color', 'r', 'Fontsize', 10, 'FontWeight', 'bold', ...
        'VerticalAlignment', 'top');
end