% This script takes the amygdala atanh matrix and masks by subregions to get predicted activations for each subregion
% addpath(genpath('Github'))
rois = {'BL_L', 'BL_R', 'CE_L', 'CE_R', 'CM_L', 'CM_R'};
load('/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_fc7_invert_imageFeatures_output_matrix_atanh.mat')
atanh_matrix(atanh_matrix==0) = NaN
dat = fmri_data(['/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-Damy001/ses-1/MNI152NLin2009cAsym/sub-Damy001_ses-1_task-gump0_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz']);
masked_dat = apply_mask(dat,select_atlas_subset(load_atlas('canlab2023'),rois));
masked_dat = replace_empty(masked_dat);
amy_bin = double(masked_dat.dat(:,1)~=0);
for r = 1:length(rois)
 masked_dat = apply_mask(dat,select_atlas_subset(load_atlas('canlab2023'),{rois{r}}));
 masked_dat = replace_empty(masked_dat);
 rois_bin(r,:) = masked_dat.dat(amy_bin==1,1)~=0;
 rois_inds{r} = find(rois_bin(r,:));
 atanh_subregion = atanh_matrix(:,rois_bin(r,:)==1);
 avg_atanh_subregion(:,r) = mean(atanh_subregion,2);
end
save(['/Users/zacharydiamandis/Documents/MATLAB/EmoNet/ConcatTry/amygdala_subregions_atanh.mat'],'avg_atanh_subregion')