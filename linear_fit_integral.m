% === Load your dataset ===
data = readtable('Fl_fit.xlsx');  % <-- change to your file

% === Select columns ===
x = data.concentration;  % e.g., data.k
y = data.S;  % e.g., data.E

% === Fit linear model ===
p = polyfit(x, y, 3);       % Linear fit: y = p(1)*x + p(2)
y_fit = polyval(p, x);      % Evaluate fit

% === Plot main data and fit ===
figure('Name', 'Polynomial Fit');
subplot(2,1,1);
plot(x, y, 'o', 'Color', 'r', 'MarkerFaceColor', 'r', 'MarkerSize', 5, 'DisplayName', 'Data');
hold on;
plot(x, y_fit, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Fitting', p));
xlabel('Concentration [mM]');  % <-- change as needed
ylabel('Integrated Intensity (normelized)');  % <-- change as needed
title('Polynomial Fit of Intensity as a function of Concentration - Fluorescein');     % <-- change as needed
legend('Location','best');
grid on;

% === Compute and plot residuals ===
residuals = y - y_fit;

subplot(2,1,2);
plot(x, residuals, 'o', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
yline(0, '--r');
xlabel('Concentration [mM]');   % <-- change as needed
ylabel('Residuals');
title('Residuals of Polynomial Fit of Intensity as a function of Concentration - Fluorescein');
grid on;


% === Save plot ===
outputFolder = pwd;  % Save to current folder (or specify path)
filename = 'Polynomial_fit_plot_fl.png';  % Change filename as needed
saveas(gcf, fullfile(outputFolder, filename));
fprintf('Plot saved to: %s\n', fullfile(outputFolder, filename));