function [] = makeTargetROIs_sizematched(commondir, subdir)
% make target ROIs with VOI extraction tool 
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    step = 0;
    targetROIdir = [commondir subdir(sub,:) filesep 'targetROI'];
    ROIdir = [commondir subdir(sub,:) filesep 'ROIs'];
    gratingsdir = [commondir subdir(sub,:) filesep 'gratings\DCM\'];
    
    load([targetROIdir '\SPM.mat']);    
    
    cd(ROIdir)
    
    thresh = 0.001;
    nvoxels = 0;
    maxnum = 50;
    minnum = 10;
    while nvoxels > maxnum || nvoxels < minnum
        matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
        matlabbatch{1}.spm.util.voi.adjust = 0;
        matlabbatch{1}.spm.util.voi.session = 1;
        matlabbatch{1}.spm.util.voi.name = 'V1_target_sizematched';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
        matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
        matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh(end);
        matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
        matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V1.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
        matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
        matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
        matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
        matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
        matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
        matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
        matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
        try    spm_jobman('run',matlabbatch)
        catch
        end
        clear matlabbatch
        cd(targetROIdir)
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
            v=spm_read_vols(spm_vol([targetROIdir filesep 'VOI_V1_target_sizematched_mask.nii']));
            nvoxels = sum(v(:)>0);
            if nvoxels > maxnum
                
                if thresh(end) - dthresh > 0
                    thresh(end+1) = thresh(end) - dthresh;
                    delete('VOI_V1_target_sizematched_mask.nii')
                else 
                    break
                end
            elseif nvoxels < minnum
                thresh(end+1) = thresh(end) + dthresh;
                delete('VOI_V1_target_sizematched_mask.nii')
            end
        catch
            nvoxels = 0;
            thresh(end+1) = thresh(end) + dthresh;
            delete('VOI_V1_target_sizematched_mask.nii')
        end
    end
    
    thresh = thresh(end);
    savedthresh(sub) = thresh;
    
    matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.adjust = 0;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = 'V2_target_sizematched';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
    matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V2.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
    try    spm_jobman('run',matlabbatch)
    catch
    end
    clear matlabbatch
    matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.adjust = 0;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = 'V3_target_sizematched';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
    matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V3.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
    try    spm_jobman('run',matlabbatch)
    catch
    end
    clear matlabbatch
    matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.adjust = 0;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = 'V4_target_sizematched';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
    matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V4.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
    try    spm_jobman('run',matlabbatch)
    catch
    end
    clear matlabbatch
    matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.adjust = 0;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = 'LOC_target_sizematched';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
    matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
    matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\LOC.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
    matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
    matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
    matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
    matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
    matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
    try    spm_jobman('run',matlabbatch)
    catch
    end
    clear matlabbatch
    
    try
        movefile([targetROIdir '\VOI_V1_target_sizematched_mask.nii'],[ROIdir '\V1_target_sizematched.nii'])
        delete([targetROIdir '\VOI_V1_target_sizematched_1.mat'])
        delete([targetROIdir '\VOI_V1_target_sizematched_1_eigen.nii'])
    catch
    end
    try
        movefile([targetROIdir '\VOI_V2_target_sizematched_mask.nii'],[ROIdir '\V2_target_sizematched.nii'])
        delete([targetROIdir '\VOI_V2_target_sizematched_1.mat'])
        delete([targetROIdir '\VOI_V2_target_sizematched_1_eigen.nii'])
    catch
    end
    try
        movefile([targetROIdir '\VOI_V3_target_sizematched_mask.nii'],[ROIdir '\V3_target_sizematched.nii'])
        delete([targetROIdir '\VOI_V3_target_sizematched_1.mat'])
        delete([targetROIdir '\VOI_V3_target_sizematched_1_eigen.nii'])
    catch
    end
    try
    movefile([targetROIdir '\VOI_V4_target_sizematched_mask.nii'],[ROIdir '\V4_target_sizematched.nii'])
    delete([targetROIdir '\VOI_V4_target_sizematched_1.mat'])
    delete([targetROIdir '\VOI_V4_target_sizematched_1_eigen.nii'])
    catch
    end
    try
    movefile([targetROIdir '\VOI_LOC_target_sizematched_mask.nii'],[ROIdir '\LOC_target_sizematched.nii'])
    delete([targetROIdir '\VOI_LOC_target_sizematched_1.mat'])
    delete([targetROIdir '\VOI_LOC_target_sizematched_1_eigen.nii'])
    catch
    end
end
save([commondir filesep 'targetThresholds.mat'],'savedthresh')


% for sub = 5:6 % for subjects with ROIs with nvox<5
%     step = 0;
%     targetROIdir = [commondir patientdir(sub,:) filesep 'targetROI'];
%     ROIdir = [commondir patientdir(sub,:) filesep 'ROIs'];
%     gratingsdir = [commondir patientdir(sub,:) filesep 'gratings\DCM\'];
%     
%     
%     load([targetROIdir '\SPM.mat']);    
%     
%     cd(ROIdir)
%     
%     thresh = 0.05;
%     clear matlabbatch
%     matlabbatch{1}.spm.util.voi.spmmat = {[targetROIdir '\SPM.mat']};
%     matlabbatch{1}.spm.util.voi.adjust = 0;
%     matlabbatch{1}.spm.util.voi.session = 1;
%     matlabbatch{1}.spm.util.voi.name = 'V4_target_sizematched';
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = thresh;
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
%     matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
%     matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[ROIdir '\V4.nii,1']};
%     matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0.5;
%     matlabbatch{1}.spm.util.voi.roi{3}.mask.image = {[gratingsdir '\mask.nii,1']};
%     matlabbatch{1}.spm.util.voi.roi{3}.mask.threshold = 0.5;
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.spmmat = {[gratingsdir '\SPM.mat']};
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.contrast = 9;
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.conjunction = 1;
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.threshdesc = 'none';
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.thresh = 0.01;
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.extent = 10;
%     matlabbatch{1}.spm.util.voi.roi{4}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
%     matlabbatch{1}.spm.util.voi.expression = 'i1 & i2 & i3 & ~i4';
%     try    spm_jobman('run',matlabbatch)
%     catch
%     end
%     
%     try
%         movefile([targetROIdir '\VOI_V4_target_sizematched_mask.nii'],[ROIdir '\V4_target_sizematched.nii'])
%         delete([targetROIdir '\VOI_V4_target_sizematched_1.mat'])
%         delete([targetROIdir '\VOI_V4_target_sizematched_1_eigen.nii'])
%     catch
%     end
% end

end