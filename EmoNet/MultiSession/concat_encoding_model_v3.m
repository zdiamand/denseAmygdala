% Updated Amygdala Encoding Model Script with Percent Signal Change for Multiple Sessions
% Load features
% addpath(genpath('/Users/zacharydiamandis/Documents/MATLAB/CanlabCore'));
sessions = 0:7; % Define sessions
% Define subjects
subjects = {'Damy001' 'Damy002' 'Damy003'};

% Define file paths
file_paths = { ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-1/MNI152NLin2009cAsym/sub-{subject}_ses-1_task-gump0_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-1/MNI152NLin2009cAsym/sub-{subject}_ses-1_task-gump1_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-2/MNI152NLin2009cAsym/sub-{subject}_ses-2_task-gump2_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-2/MNI152NLin2009cAsym/sub-{subject}_ses-2_task-gump3_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-3/MNI152NLin2009cAsym/sub-{subject}_ses-3_task-gump4_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-3/MNI152NLin2009cAsym/sub-{subject}_ses-3_task-gump5_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-4/MNI152NLin2009cAsym/sub-{subject}_ses-4_task-gump6_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz', ...
    '/Volumes/T7Shield/DenseAmygdala/Routine/derivatives/slabpreproc/sub-{subject}/ses-4/MNI152NLin2009cAsym/sub-{subject}_ses-4_task-gump7_part-mag_recon-clean_space-MNI152NLin2009cAsym_bold.nii.gz' ...
};

for s = 1:length(subjects)
    all_data = [];
    all_features = [];
    for ses = 1:length(sessions)
        clear features conv_features timematched_features

        load(sprintf('/Users/zacharydiamandis/Documents/MATLAB/EmoNet/New/features/fg_av_eng_seg%d_fc7_features.mat', sessions(ses)))
        lendelta = size(video_imageFeatures, 1);
        
        % Use the file_paths array to get the correct fMRI file path
        fmri_file = strrep(file_paths{ses}, '{subject}', subjects{s});
        dat = fmri_data(fmri_file);
        
        mean_image = mean(dat.dat, 2);
        psc_data = bsxfun(@rdivide, bsxfun(@minus, dat.dat, mean_image), mean_image) * 100;
        dat.dat = psc_data;
        masked_dat = apply_mask(dat, select_atlas_subset(load_atlas('canlab2023'), {'BL_L', 'BL_R', 'CE_L', 'CE_R', 'CM_L', 'CM_R'}));
        disp('masked_dat done')
        
        if ses == 1
            excluded_voxels(s,:) = masked_dat.removed_voxels;
        end
        
        features = resample(double(video_imageFeatures), size(masked_dat.dat,2), lendelta);
        disp('resample features done')
        
        % Convolute features to match time delay of hemodynamic BOLD data
        for i = 1:size(features, 2)
            tmp = conv(double(features(:,i)), spm_hrf(0.556));
            conv_features(:,i) = tmp(:);
        end
        
        % Match length of features to length of BOLD data
        timematched_features = conv_features(1:size(masked_dat.dat,2),:);
        disp('timematched_features done')
        
        all_data = [all_data, masked_dat.dat];
        all_features = [all_features; timematched_features];
    end
    
    % Extract regression coefficients (betas) for encoding models
    [~,~,~,~,b] = plsregress(all_features, all_data', 20);
    disp('beta done')
    kinds = crossvalind('k', size(all_data,2), 5);
    disp('kinds done')
    clear yhat pred_obs_corr diag_corr conv_features
    
    % 5-fold cross-validation
    for k = 1:5
        [xl,yl,xs,ys,beta_cv,pctvar] = plsregress(all_features(kinds~=k,:), all_data(:,kinds~=k)', min(20,size(all_data,1)));
        disp('plsregress done')
        yhat(kinds==k,:) = [ones(length(find(kinds==k)),1) all_features(kinds==k,:)] * beta_cv;
        disp('yhat done')
        pred_obs_corr(:,:,k) = corr(yhat(kinds==k,:), all_data(:,kinds==k)');
        disp('pred_obs_corr done')
        diag_corr(k,:) = diag(pred_obs_corr(:,:,k));
        disp('diag_corr done')
    end
    
    mean_diag_corr = mean(diag_corr);
    save(['sub-' subjects{s} '_amygdala_fc7_invert_imageFeatures_output_allsessions.mat'], 'mean_diag_corr', '-v7.3')
    save(['beta_sub-' subjects{s} '_amygdala_fc7_invert_imageFeatures_allsessions.mat'], 'b', '-v7.3')
end