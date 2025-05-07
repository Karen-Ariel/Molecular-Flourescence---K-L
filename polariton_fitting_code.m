% Load data
upper_data = readmatrix('Upper.xlsx');
lower_data = readmatrix('Lower.xlsx');

x_upper = upper_data(:,1);    % K_up
y_upper = upper_data(:,3);    % E_up

x_lower = lower_data(:,1);    % k_lp
y_lower = lower_data(:,3);    % E_LP

% Define models
model_upper = @(a, x) 0.5 * (a(1) + a(2).*sqrt(x.^2 + a(3)^2) + sqrt(a(4) + (a(1) - a(2).*sqrt(x.^2 + a(3)^2)).^2));
model_lower = @(a, x) 0.5 * (a(1) + a(2).*sqrt(x.^2 + a(3)^2) - sqrt(a(4) + (a(1) - a(2).*sqrt(x.^2 + a(3)^2)).^2));

% Initial guesses [a1, a2, a3, a4]
a0_upper = [2.3, 100, 0.01, 0.01];
a0_lower = [2.3, 200, 0.01, 0.1];

% Fit using lsqcurvefit with Jacobian for uncertainty estimation
opts = optimoptions('lsqcurvefit', 'Display', 'off');

[a_upper, ~, r_upper, ~, ~, ~, J_upper] = ...
    lsqcurvefit(model_upper, a0_upper, x_upper, y_upper, [-Inf, -Inf, 0, 0], [Inf, Inf, Inf, Inf], opts);

[a_lower, ~, r_lower, ~, ~, ~, J_lower] = ...
    lsqcurvefit(model_lower, a0_lower, x_lower, y_lower, [-Inf, -Inf, 0, 0], [Inf, Inf, Inf, Inf], opts);

% Compute standard errors from Jacobian
cov_upper = full(inv(J_upper' * J_upper)) * var(r_upper);
cov_lower = full(inv(J_lower' * J_lower)) * var(r_lower);

stderr_upper = sqrt(diag(cov_upper));
stderr_lower = sqrt(diag(cov_lower));

% Generate fit curves
x_fit = linspace(min([x_upper; x_lower]), max([x_upper; x_lower]), 500);
y_fit_upper = model_upper(a_upper, x_fit);
y_fit_lower = model_lower(a_lower, x_fit);

% Plot fits and data
figure;
hold on;
plot(x_fit, y_fit_upper, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Upper Energy Fit');
plot(x_fit, y_fit_lower, 'm-', 'LineWidth', 1.5, 'DisplayName', 'Lower Energy Fit');
plot(x_upper, y_upper, 'b.', 'MarkerSize', 15, 'MarkerFaceColor', 'none', 'DisplayName', 'Upper Energy Data');
plot(x_lower, y_lower, 'r.', 'MarkerSize', 15, 'MarkerFaceColor', 'none', 'DisplayName', 'Lower Energy Data');

xlabel('K [1/nm]');
ylabel('E_u / E_l [eV]');
title('Upper and Lower Polariton Energy as a Function of Parallel Wave Number K');
legend('Location','best');
grid on;

% Display fitted parameters and uncertainties
fprintf('\n--- LOWER Polariton Fit Parameters ---\n');
for i = 1:4
    fprintf('  a%d = %.6f ± %.6f\n', i, a_lower(i), stderr_lower(i));
end

fprintf('\n--- UPPER Polariton Fit Parameters ---\n');
for i = 1:4
    fprintf('  a%d = %.6f ± %.6f\n', i, a_upper(i), stderr_upper(i));
end

% Residuals
residual_lower = y_lower - model_lower(a_lower, x_lower);
residual_upper = y_upper - model_upper(a_upper, x_upper);

% Plot residuals
figure('Name', 'Residuals');
subplot(1,2,1);
plot(x_lower, residual_lower, 'o', 'Color', 'k', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
yline(0, '--r');
xlabel('K [1/nm]');
ylabel('Residuals [eV]');
title('Residuals: Lower Polariton Fit');
grid on;

subplot(1,2,2);
plot(x_upper, residual_upper, 'o', 'Color', 'k', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
yline(0, '--r');
xlabel('K [1/nm]');
ylabel('Residuals [eV]');
title('Residuals: Upper Polariton Fit');
grid on;
