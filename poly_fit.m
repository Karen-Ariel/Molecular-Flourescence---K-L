% Define file and output folder
filename = 'part 2 RhB.xlsx';
output_folder = 'poly_plots_rhb';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Degree of polynomial
poly_deg = 4;  % Change to 3, 4, etc., if needed

% Get all sheet names
[~, sheets] = xlsfinfo(filename);

for i = 1:length(sheets)
    sheet = sheets{i};
    data = readtable(filename, 'Sheet', sheet);

    % Identify variable names
    varNames = data.Properties.VariableNames;
    x_col = contains(varNames, 'x', 'IgnoreCase', true);
    y_col = contains(varNames, 'intensity', 'IgnoreCase', true);

    % Extract x and y
    x = data{:, find(x_col, 1)};
    y = data{:, find(y_col, 1)};

    % Extract or create error arrays
    err_candidates = data{:, contains(varNames, 'error', 'IgnoreCase', true)};
    if size(err_candidates, 2) == 2
        err_y = err_candidates(:,2);
    else
        err_y = ones(size(y));
    end

    % Remove rows with NaNs in x, y, or err_y
    valid = ~(isnan(x) | isnan(y) | isnan(err_y));
    x = x(valid);
    y = y(valid);
    err_y = err_y(valid);
    
    % Weighted polynomial fit using Curve Fitting Toolbox
    ft = fittype(sprintf('poly%d', poly_deg));
    weights = 1 ./ err_y;
    [fitresult, ~] = fit(x, y, ft, 'Weights', weights);

    % Evaluate fit and residuals
    y_fit = feval(fitresult, x);
    residuals = y - y_fit;

    % Plot: data and polynomial fit
    fig1 = figure('Visible', 'off');
    plot(x, y, '.', 'DisplayName', 'Data');
    hold on;
    plot(x, y_fit, '-', 'LineWidth', 2, 'DisplayName', sprintf('Polynomial Fit (deg %d)', poly_deg));
    xlabel('x [cm]');
    ylabel('Intensity [AU]');
    title(['Polynomial Fit - Sheet: ' sheet]);
    legend();
    grid on;
    saveas(fig1, fullfile(output_folder, ['polyfit_' sheet '.png']));
    close(fig1);

    % Plot: residuals
    fig2 = figure('Visible', 'off');
    plot(x, residuals, '.');
    hold on;
    yline(0, '--k');
    xlabel('x [cm]');
    ylabel('Residuals');
    title(['Residuals - Sheet: ' sheet]);
    grid on;
    saveas(fig2, fullfile(output_folder, ['residuals_poly_' sheet '.png']));
    close(fig2);
end

disp('All polynomial fit plots saved.');
