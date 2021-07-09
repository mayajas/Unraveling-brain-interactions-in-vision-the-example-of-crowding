function [] = makeLOCROI_sizematched(commondir, subdir)
% make LOC ROI with VOI extraction tool 
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    step = 0;
    LOCdir = [commondir subdir(sub,:) filesep 'LOC'];
    ROIdir = [commondir subdir(sub,:) filesep 'ROIs'];
    
    thresh = 0.001;
    nvoxels = 0;
    maxnum = 200;
    minnum = 50;
    while nvoxels > maxnum || nvoxels < minnum
        matlabbatch{1}.spm.util.voi.spmmat = {[LOCdir '\SPM.mat']};
        matlabbatch{1}.spm.util.voi.adjust = 0;
        matlabbatch{1}.spm.util.voi.session = 1;
        matlabbatch{1}.spm.util.voi.name = 'LOC_sizematched';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
        matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh(end);
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 15;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V1.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[ROIdir '\V2.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{4}.mask.image = {[ROIdir '\V3.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{4}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{5}.mask.image = {[ROIdir '\V4.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{5}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{6}.mask.image = {[ROIdir '\brain_mask.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{6}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.expression = 'i1 & ~i2 & ~i3 & ~i4 & ~i5 & i6';
        spm_jobman('run',matlabbatch)
        clear matlabbatch
        cd(LOCdir)
        if thresh(end) > 1e-5
            dthresh = 1e-5;
        elseif thresh(end) < 1e-5 && thresh(end) > 1e-6
            dthresh = 1e-6;
        elseif thresh(end) < 1e-6 && thresh(end) > 1e-7
            dthresh = 1e-7;
        elseif thresh(end) < 1e-7 && thresh(end) > 1e-8
            dthresh = 1e-8;
        elseif thresh(end) < 1e-8 && thresh(end) > 1e-9
            dthresh = 1e-9;
        elseif thresh(end) < 1e-9 && thresh(end) > 1e-10
            dthresh = 1e-10;
        elseif thresh(end) < 1e-10 && thresh(end) > 1e-11
            dthresh = 1e-11;
        elseif thresh(end) < 1e-11 && thresh(end) > 1e-12
            dthresh = 1e-12;
        elseif thresh(end) < 1e-12 && thresh(end) > 1e-13
            dthresh = 1e-13;
        elseif thresh(end) < 1e-13 && thresh(end) > 1e-14
            dthresh = 1e-14;
        else
            dthresh = 1e-15;
        end
        try
            v=spm_read_vols(spm_vol([LOCdir filesep 'VOI_LOC_sizematched_mask.nii']));
            nvoxels = sum(v(:)>0);
            if nvoxels > maxnum
                
                if thresh(end) - dthresh > 0
                    thresh(end+1) = thresh(end) - dthresh;
                    delete('VOI_LOC_sizematched_mask.nii')
                else 
                    break
                end
            elseif nvoxels < minnum
                thresh(end+1) = thresh(end) + dthresh;
                delete('VOI_LOC_sizematched_mask.nii')
            end
            
        catch
            nvoxels = 0;
            thresh(end+1) = thresh(end) + dthresh;
            delete('VOI_LOC_sizematched_mask.nii')
        end
    end
    thresh = thresh(end);
    savedthresh(sub) = thresh;

    movefile([LOCdir '\VOI_LOC_sizematched_mask.nii'],[ROIdir '\LOC_sizematched.nii'])
    delete([LOCdir '\VOI_LOC_sizematched_1.mat'])
    delete([LOCdir '\VOI_LOC_sizematched_1_eigen.nii'])
    
end
save([commondir filesep 'LOCThresholds.mat'],'savedthresh')