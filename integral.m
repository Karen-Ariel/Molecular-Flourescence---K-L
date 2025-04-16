filename = 'RhB_x_const.xlsx';  % Replace with your Excel file name
x_cutoff = 455;                 % Set your cutoff value

% Get sheet names
[~, sheet_names] = xlsfinfo(filename);

% Loop through each sheet
for i = 1:length(sheet_names)
    sheet = sheet_names{i};
    fprintf('\nProcessing sheet: %s\n', sheet);
    
    % Read the data from the current sheet
    data = readmatrix(filename, 'Sheet', sheet);
    
    % Make sure there are at least two columns
    if size(data, 2) < 2
        fprintf('Sheet %s does not have enough columns. Skipping.\n', sheet);
        continue;
    end

    % Assume column 1 is x, column 2 is y
    x = data(:, 1);
    y = data(:, 2);
    
    % Find index where x >= x_cutoff
    cutoff_index = find(x >= x_cutoff, 1, 'first');
    
    if isempty(cutoff_index)
        fprintf('No x value >= %.2f found in sheet %s. Skipping.\n', x_cutoff, sheet);
        continue;
    end

    % Slice data from cutoff onward
    x_cut = x(cutoff_index:end);
    y_cut = y(cutoff_index:end);
    
    % Calculate the integral
    integral_value = trapz(x_cut, y_cut);
    error_value = 0.10 * integral_value;
    
    % Store results
    results{i, 1} = sheet;
    results{i, 2} = integral_value;
    results{i, 3} = error_value;

    % Display
    fprintf('Integral from x = %.2f in %s: %.4f ± %.4f\n', ...
        x_cutoff, sheet, integral_value, error_value);
end

% Convert to table for nicer formatting
results_table = cell2table(results, ...
    'VariableNames', {'SheetName', 'IntegralValue', 'Error10Percent'});

% Save to new Excel file
writetable(results_table, 'RhB_integral_results.xlsx');

fprintf('\nAll results saved to "RhB_integral_results.xlsx"\n');