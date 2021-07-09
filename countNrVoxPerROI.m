function [ROIvolumes, targetROIvolumes] = countNrVoxPerROI(commondir, subdir)
% count nr of voxels in ROIs: LOC, V1-V4, LOCtg, V1tg-V4tg
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    cd([commondir subdir(sub,:)])
    
    %% Entire ROIs
    ROI = 1;
    v = spm_vol([commondir subdir(sub,:) '\ROIs\V1.nii']);
    v = spm_read_vols(v);
    ROIvolumes(sub,ROI) = sum(sum(sum(v))); v=0;
    ROI = 2;
    v = spm_vol([commondir subdir(sub,:) '\ROIs\V2.nii']);
    v = spm_read_vols(v);
    ROIvolumes(sub,ROI) = sum(sum(sum(v)));v=0;
    ROI = 3;
    v = spm_vol([commondir subdir(sub,:) '\ROIs\V3.nii']);
    v = spm_read_vols(v);
    ROIvolumes(sub,ROI) = sum(sum(sum(v)));v=0;
    ROI = 4;
    v = spm_vol([commondir subdir(sub,:) '\ROIs\V4.nii']);
    v = spm_read_vols(v);
    ROIvolumes(sub,ROI) = sum(sum(sum(v)));v=0;
    ROI = 5;
    v = spm_vol([commondir subdir(sub,:) '\ROIs\LOC_sizematched.nii']);
    v = spm_read_vols(v);
    ROIvolumes(sub,ROI) = sum(sum(sum(v)));v=0;
    
    %% Target ROIs
    ROI = 1;
    try
        V1 = spm_vol([commondir subdir(sub,:) '\ROIs\V1_target_sizematched.nii']);
        V1 = spm_read_vols(V1);
        targetROIvolumes(sub,ROI) = sum(sum(sum(V1)));
    catch
    end
   
    ROI = 2;
    try
        V2 = spm_vol([commondir subdir(sub,:) '\ROIs\V2_target_sizematched.nii']);
        V2 = spm_read_vols(V2);
        targetROIvolumes(sub,ROI) = sum(sum(sum(V2)));
    catch
    end
    
    ROI = 3;
    try
        V3 = spm_vol([commondir subdir(sub,:) '\ROIs\V3_target_sizematched.nii']);
        V3 = spm_read_vols(V3);
        targetROIvolumes(sub,ROI) = sum(sum(sum(V3)));
    catch
    end
    
    ROI = 4;
    try
        V4 = spm_vol([commondir subdir(sub,:) '\ROIs\V4_target_sizematched.nii']);
        V4 = spm_read_vols(V4);
        targetROIvolumes(sub,ROI) = sum(sum(sum(V4)));
    catch
    end
    
    ROI = 5;
    try
        LOC = spm_vol([commondir subdir(sub,:) '\ROIs\LOC_sizematched.nii']);
        LOC = spm_read_vols(LOC);
        targetROIvolumes(sub,ROI) = sum(sum(sum(LOC)));
    catch
    end
        
end
end