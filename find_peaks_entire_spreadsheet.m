% Set input and output file names
inputFile = 'polariton.xlsx';
outputExcel = 'top2_peaks_summary.xlsx';

% Get sheet names
[~, sheetNames] = xlsfinfo(inputFile);

% Initialize result cell array
results = {'Sheet', 'Peak1_X (nm)', 'Peak2_X (nm)'};

% Loop through each sheet
for s = 1:length(sheetNames)
    sheet = sheetNames{s};
    
    % Read data from the current sheet
    data = xlsread(inputFile, sheet);
    x = data(:,1); % Wavelength
    y = data(:,2); % Intensity
    
    % Smooth using Savitzky-Golay filter
    y_smooth = sgolayfilt(y, 3, 21);
    
    % Find peaks
    [peakValues, locs] = findpeaks(y_smooth, ...
        'MinPeakProminence', 0.002, ...
        'MinPeakDistance', 20);
    
    % Prepare figure
    figure('Visible','off'); % Hide figure during loop
    plot(x, y, 'b'), hold on
    plot(x, y_smooth, 'r', 'LineWidth', 1.5)
    
    if length(peakValues) >= 2
        [~, sortIdx] = sort(peakValues, 'descend');
        top2Locs = locs(sortIdx(1:2));
        top2X = x(top2Locs);
        plot(x(top2Locs), y(top2Locs), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8)
        
        % Store results
        results(end+1, :) = {sheet, top2X(1), top2X(2)};
    else
        % Fewer than two peaks
        results(end+1, :) = {sheet, NaN, NaN};
    end

    % Finalize and save plot
    title(['Top 2 Peaks - ' sheet])
    xlabel('Wavelength (nm)')
    ylabel('Intensity')
    legend('Original', 'Smoothed', 'Top 2 Peaks')
    grid on
    saveas(gcf, ['plot_' sheet '.png']);
    close;
end

% Save results to Excel
writecell(results, outputExcel);
disp(['Results saved to ' outputExcel]);
