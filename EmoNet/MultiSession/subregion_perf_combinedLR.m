% Load the data
load('/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_subregions_atanh.mat')

% Combine left and right subregions by averaging
avg_atanh_combined(:,1) = mean(avg_atanh_subregion(:,[1,2]), 2); % BL
avg_atanh_combined(:,2) = mean(avg_atanh_subregion(:,[3,4]), 2); % CE
avg_atanh_combined(:,3) = mean(avg_atanh_subregion(:,[5,6]), 2); % CM

% Plot the combined data
figure;
barplot_columns(avg_atanh_combined)
set(gca, 'XTickLabels', {'BL', 'CE', 'CM'})
xlabel('Amygdala Subregions')
ylabel('Performance (Fisher''s Z)')
title('Amygdala Encoding Model Performance by Subregion')

% Optional: Adjust figure properties for better visibility
set(gcf, 'Color', 'w')  % Set figure background to white
set(gca, 'FontSize', 12)  % Increase font size
box on  % Add box around the plot

% Save the figure (if needed)
% saveas(gcf, '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/New/encoding/amygdala_subregions_performance_combined.png')
% saveas(gcf, '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/New/encoding/amygdala_subregions_performance_combined.fig')
