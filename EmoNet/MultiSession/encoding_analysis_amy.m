% This script performs a ttest and makes a t-map of amygdala voxels, and thresholds by FDR q < .05
subjects = {'Damy001' 'Damy002' 'Damy003'}
% step one -- mask for amygdala voxels
for s = 1:length(subjects)
 dat = fmri_data(['/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-' subjects{s} '/ses-1/MNI152NLin2009cAsym/sub-' subjects{s} '_ses-1_task-gump0_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz']);
 masked_dat = apply_mask(dat,select_atlas_subset(load_atlas('canlab2023'),{'BL_L', 'BL_R', 'CE_L', 'CE_R', 'CM_L', 'CM_R'}));
 
 % Debugging information
 disp(['Subject: ' subjects{s}]);
 disp(['Size of masked_dat.removed_voxels: ' num2str(size(masked_dat.removed_voxels))]);
 
 excluded_voxels(s,:) = masked_dat.removed_voxels;
 
 % More debugging information
 disp(['Size of excluded_voxels after assignment: ' num2str(size(excluded_voxels))]);
end

% Rest of the script remains the same
% step two -- load n subj x n voxel amygdala output (atanh) for layer
load('/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_matrix_atanh.mat')
atanh_matrix(atanh_matrix==0) = NaN
% step three -- perform a ttest on that output
[h, p, ci, stats] = ttest(atanh_matrix);
% step four -- create a statistic image object
stats_object = statistic_image;
stats_object.volInfo = masked_dat.volInfo;
stats_object.removed_voxels = all(excluded_voxels);
% step five -- assign t values to that object
stats_object.dat = stats.tstat';
% step six -- write out as nifti image
stats_object.fullpath = '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/tstat_FisherZ_amygdala_imageFeatures_fc7.nii';
write(stats_object,'overwrite');
% thresholded by (FDR) False Discovery Rate, q < 0.05
th_stats_object = stats_object;
th_stats_object.dat(~(p<FDR(p,.05)))=NaN;
th_stats_object.fullpath = '/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/tstat_FisherZ_amygdala_imageFeatures_fc7_threshold_q05.nii';
write(th_stats_object,'overwrite');