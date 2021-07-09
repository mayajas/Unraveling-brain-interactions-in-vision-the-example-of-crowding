function [] = extractVOIs4DCM(commondir, subdir)
% extract VOIs for DCM analysis
% Maya A. Jastrz?bowska

nrois = 5;

for sub = 1:size(subdir,1)
    ROIdir = [commondir subdir(sub,:) filesep 'ROIs\'];
    
    gratings_dir = [commondir subdir(sub,:) filesep 'gratings' filesep];
    DCM_dir = [commondir subdir(sub,:) filesep 'gratings' filesep 'DCM' filesep];
    cd(gratings_dir)
    if ~exist('DCM','dir')
        mkdir(DCM_dir)
    end
    cd(DCM_dir)


    for sess = 1
        matlabbatch{1}.spm.util.voi.spmmat = {[DCM_dir 'SPM.mat']};
        matlabbatch{1}.spm.util.voi.adjust = 8; % F contrast over all target conditions
        matlabbatch{1}.spm.util.voi.session = sess;
        matlabbatch{1}.spm.util.voi.name = 'V1';
        matlabbatch{1}.spm.util.voi.roi{1}.mask.image = {[ROIdir 'V1_target_sizematched.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.expression = 'i1';

        matlabbatch{2}.spm.util.voi.spmmat = {[DCM_dir 'SPM.mat']};
        matlabbatch{2}.spm.util.voi.adjust = 8;
        matlabbatch{2}.spm.util.voi.session = sess;
        matlabbatch{2}.spm.util.voi.name = 'V2';
        matlabbatch{2}.spm.util.voi.roi{1}.mask.image = {[ROIdir 'V2_target_sizematched.nii,1']};
        matlabbatch{2}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{2}.spm.util.voi.expression = 'i1';

        matlabbatch{3}.spm.util.voi.spmmat = {[DCM_dir 'SPM.mat']};
        matlabbatch{3}.spm.util.voi.adjust = 8;
        matlabbatch{3}.spm.util.voi.session = sess;
        matlabbatch{3}.spm.util.voi.name = 'V3';
        matlabbatch{3}.spm.util.voi.roi{1}.mask.image = {[ROIdir 'V3_target_sizematched.nii,1']};
        matlabbatch{3}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{3}.spm.util.voi.expression = 'i1';

        matlabbatch{4}.spm.util.voi.spmmat = {[DCM_dir 'SPM.mat']};
        matlabbatch{4}.spm.util.voi.adjust = 8;
        matlabbatch{4}.spm.util.voi.session = sess;
        matlabbatch{4}.spm.util.voi.name = 'V4';
        matlabbatch{4}.spm.util.voi.roi{1}.mask.image = {[ROIdir 'V4_target_sizematched.nii,1']};
        matlabbatch{4}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{4}.spm.util.voi.expression = 'i1';

        matlabbatch{5}.spm.util.voi.spmmat = {[DCM_dir 'SPM.mat']};
        matlabbatch{5}.spm.util.voi.adjust = 8;
        matlabbatch{5}.spm.util.voi.session = sess;
        matlabbatch{5}.spm.util.voi.name = 'LOC';
        matlabbatch{5}.spm.util.voi.roi{1}.mask.image = {[ROIdir 'LOC_sizematched.nii,1']};
        matlabbatch{5}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{5}.spm.util.voi.expression = 'i1';

        spm_jobman('run',matlabbatch)
        clear matlabbatch
    end
end