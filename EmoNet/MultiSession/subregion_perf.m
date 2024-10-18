% This script makes violin plots of amygdala encoding model performance by subregion
load('/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_subregions_atanh.mat')

figure;
barplot_columns(avg_atanh_subregion)
set(gca, 'XTickLabels', {'BL_L', 'BL_R', 'CE_L', 'CE_R', 'CM_L', 'CM_R'})
xlabel('Amygdala Subregions')
ylabel('Performance (Fisher''s Z)')
title('Amygdala Encoding Model Performance by Subregion')

% Optional: Adjust figure properties for better visibility
set(gcf, 'Color', 'w')  % Set figure background to white
set(gca, 'FontSize', 12)  % Increase font size
box on  % Add box around the plot

% Save the figure
%saveas(gcf, '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/New/encoding/amygdala_subregions_performance.png')
%saveas(gcf, '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/New/encoding/amygdala_subregions_performance.fig')