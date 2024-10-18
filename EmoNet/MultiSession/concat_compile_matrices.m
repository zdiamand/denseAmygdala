% This script compiles all subjects' amygdala activations in a matrix and does atanh conversion for normalization
subjects = {'Damy001' 'Damy002' 'Damy003'}
for s = 1:length(subjects)
 dat = fmri_data(['/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-' subjects{s} '/ses-1/MNI152NLin2009cAsym/sub-' subjects{s} '_ses-1_task-gump0_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz']);
 masked_dat = apply_mask(dat,select_atlas_subset(load_atlas('canlab2023'),{'BL_L', 'BL_R', 'CE_L', 'CE_R', 'CM_L', 'CM_R'}));
 excluded_voxels = masked_dat.removed_voxels
 % Only change: Load the all-sessions output instead of single session
 load(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/sub-' subjects{s} '_amygdala_fc7_invert_imageFeatures_output_allsessions.mat'])
 matrix(s,~excluded_voxels) = mean_diag_corr
end
save(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_compilation_matrix.mat'],'matrix')
% clean matrix by excluding empty arrays (end result: new_matrix=3xN, where N is the number of non-zero columns)
new_matrix = matrix(:,~all(matrix==0))
save(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_matrix_clean.mat'],'new_matrix')
% make any values that were 0 into NaN in new_matrix
new_matrix(new_matrix==0) = NaN
save(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_matrix_nan.mat'],'new_matrix')
% do atanh conversion of the data to normalize (Fisher's Z)
atanh_matrix = atanh(new_matrix)
save(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_matrix_atanh.mat'],'atanh_matrix')