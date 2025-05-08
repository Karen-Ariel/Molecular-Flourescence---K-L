% Define file and output folder
filename = 'part 2 rh6g.xlsx';
output_folder = 'plots rh6g';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get all sheet names
[~, sheets] = xlsfinfo(filename);

for i = 1:length(sheets)
    sheet = sheets{i};
    data = readtable(filename, 'Sheet', sheet);

    % Display actual variable names to debug
    varNames = data.Properties.VariableNames;

    % Attempt to find the right columns
    x_col = contains(varNames, 'x', 'IgnoreCase', true);
    y_col = contains(varNames, 'intensity', 'IgnoreCase', true);
    err_x_col = contains(varNames, 'error', 'IgnoreCase', true) & x_col == 0;
    err_y_col = contains(varNames, 'error', 'IgnoreCase', true) & y_col == 0;

    % Extract data
    x = data{:, find(x_col, 1)};
    y = data{:, find(y_col, 1)};
    
    err_candidates = data{:, contains(varNames, 'error', 'IgnoreCase', true)};
    if size(err_candidates, 2) == 2
        err_x = err_candidates(:,1);
        err_y = err_candidates(:,2);
    else
        err_x = ones(size(x));  % fallback if only one error column
        err_y = ones(size(y));
    end

    % Weighted linear fit
    weights = 1 ./ err_y;
    X = [x ones(size(x))];
    W = diag(weights.^2);
    beta = (X' * W * X) \ (X' * W * y);
    y_fit = X * beta;
    residuals = y - y_fit;

    % Plot data with fit (no error bars)
    fig1 = figure('Visible', 'off');
    plot(x, y, '.', 'DisplayName', 'Data');
    hold on;
    plot(x, y_fit, '-', 'DisplayName', sprintf('Fit: y = %.3fx + %.3f', beta(1), beta(2)));
    xlabel('x [cm]');
    ylabel('Intensity [AU]');
    title(['Intensity as a Function of Path Length: Linear Fit ' sheet]);
    grid on;
    saveas(fig1, fullfile(output_folder, ['fit_' sheet '.png']));
    close(fig1);

    % Plot residuals (no error bars)
    fig2 = figure('Visible', 'off');
    plot(x, residuals, '.');
    hold on;
    yline(0, '--k');
    xlabel('x [cm]');
    ylabel('Residuals');
    title(['Intensity as a Function of Path Length: Residuals ' sheet]);
    grid on;
    saveas(fig2, fullfile(output_folder, ['residuals_' sheet '.png']));
    close(fig2);
end

disp('All plots saved.');
