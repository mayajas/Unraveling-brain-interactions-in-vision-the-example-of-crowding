function [] = PSC_DCMSPMs(commondir, subdir)
% percent BOLD signal change extraction
% Maya A. Jastrz?bowska

nROIs = 5;          % nr of ROIs
nEvents = 7;        % nr of conditions

pct_ev = zeros(size(subdir,1),nROIs,nEvents);
subjects = 1:size(subdir,1); 

for sub = subjects
    %% Make ROIs
    gratings_dir = [commondir subdir(sub,:) filesep 'gratings' filesep];

    spm_name = [gratings_dir filesep 'DCM\SPM.mat'];
    roi_dir = [commondir subdir(sub,:) filesep 'ROIs\'];
    cd(roi_dir)
    
    % V1
    v = spm_vol([roi_dir 'V1_target_sizematched.nii']);
    [img]=spm_read_vols(v); img(img~=0) = 1; 
    if sum(img(:)) == 0
        error
    end
    XYZ = mars_utils('e2xyz', find(img), v.dim(1:3));
    roi = maroi_pointlist(struct('XYZ',XYZ,'mat',v.mat),'vox');
    V1 = label(roi,'V1_target_sizematched');
    saveroi(V1,fullfile(roi_dir,'V1_target_sizematched_roi.mat'));

    % V2
    v = spm_vol([roi_dir 'V2_target_sizematched.nii']);
    [img]=spm_read_vols(v); img(img~=0) = 1; 
    if sum(img(:)) == 0
        error
    end
    XYZ = mars_utils('e2xyz', find(img), v.dim(1:3));
    roi = maroi_pointlist(struct('XYZ',XYZ,'mat',v.mat),'vox');
    V2 = label(roi,'V2_target_sizematched');
    saveroi(V2,fullfile(roi_dir,'V2_target_sizematched_roi.mat'));

    % V3
    v = spm_vol([roi_dir 'V3_target_sizematched.nii']);
    [img]=spm_read_vols(v); img(img~=0) = 1; 
    if sum(img(:)) == 0
        error
    end
    XYZ = mars_utils('e2xyz', find(img), v.dim(1:3));
    roi = maroi_pointlist(struct('XYZ',XYZ,'mat',v.mat),'vox');
    V3 = label(roi,'V3_target_sizematched');
    saveroi(V3,fullfile(roi_dir,'V3_target_sizematched_roi.mat'));

    % V4
    v = spm_vol([roi_dir 'V4_target_sizematched.nii']);
    [img]=spm_read_vols(v); img(img~=0) = 1; 
    if sum(img(:)) == 0
        error
    end
    XYZ = mars_utils('e2xyz', find(img), v.dim(1:3));
    roi = maroi_pointlist(struct('XYZ',XYZ,'mat',v.mat),'vox');
    V4 = label(roi,'V4_target_sizematched');
    saveroi(V4,fullfile(roi_dir,'V4_target_sizematched_roi.mat'));

    % LOC
    v = spm_vol([roi_dir 'LOC_sizematched.nii']);
    [img]=spm_read_vols(v); img(img~=0) = 1; 
    if sum(img(:)) == 0
        error
    end
    XYZ = mars_utils('e2xyz', find(img), v.dim(1:3));
    roi = maroi_pointlist(struct('XYZ',XYZ,'mat',v.mat),'vox');
    LOC = label(roi,'LOC_sizematched');
    saveroi(LOC,fullfile(roi_dir,'LOC_sizematched_roi.mat'));

    roi_fnames = cell(5,1);

    roi_fnames{1} = [roi_dir 'V1_target_sizematched_roi.mat'];
    roi_fnames{2} = [roi_dir 'V2_target_sizematched_roi.mat'];
    roi_fnames{3} = [roi_dir 'V3_target_sizematched_roi.mat'];
    roi_fnames{4} = [roi_dir 'V4_target_sizematched_roi.mat'];
    roi_fnames{5} = [roi_dir 'LOC_sizematched_roi.mat'];

    % Make marsbar design object
    D  = mardo(spm_name);
    
    % Make marsbar ROI object
    R  = maroi(roi_fnames(1:nROIs));
    for roi = 1:nROIs
        R{roi} = spm_hold(R{roi}, 0); % set NN resampling
        saveroi(R{roi}, roi_fnames{roi});
    end

    for roi = 1:nROIs
        % Fetch data into marsbar data object
        Y  = get_marsy(R{roi}, D, 'eigen1');
        % Get contrasts from original design
        xCon = get_contrasts(D);
        % Estimate design on ROI data
        E = estimate(D, Y);
        % Put contrasts from original design back into design object
        E = set_contrasts(E, xCon,0);
        % get design betas
        b = betas(E);
        % get stats and stuff for all contrasts into statistics structure
        marsS = compute_contrasts(E, 1:length(xCon));

        %% Percent signal change
        % Get definitions of all events in model
        [e_specs, e_names] = event_specs(E);
        % Get compound event types structure
        ets = event_types_named(E);
        n_event_types = length(ets);

        for sess = 1
            for e_s = 1:n_event_types
                dur = 0;
                pct_ev(sub,roi,e_s) = event_signal(E, [sess e_s]', dur, 'abs max');
            end
        end
    end
end
cd([commondir filesep 'PSC'])
save('PSC.mat','pct_ev')

