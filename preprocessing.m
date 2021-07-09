function [] = preprocessing(commondir, subdir, pmdefaults_file)
% realing & unwarp, slice timing correction, bias correction,
% coregistration, smoothing (localizers)
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    step = 0;
    gre_field_dirs = ls([commondir subdir(sub,:) filesep 'gre_field_mapping_1acq_rl_64ch\']);
    gre_field_dirs = gre_field_dirs(3:end,:);
    gre_field_mapping_magnitude_dir = [commondir subdir(sub,:) filesep 'gre_field_mapping_1acq_rl_64ch\' gre_field_dirs(1,:) filesep];
    gre_field_magn_img = ls(gre_field_mapping_magnitude_dir);
    gre_field_magn_img = gre_field_magn_img(strncmpi(cellstr(gre_field_magn_img),'sPR',3),:);
    gre_field_mapping_magnitude_img1 = gre_field_magn_img(1,:);
    %gre_field_mapping_magnitude_img2 = gre_field_magn_img(2,:);
    gre_field_mapping_phase_dir = [commondir subdir(sub,:) filesep 'gre_field_mapping_1acq_rl_64ch\' gre_field_dirs(2,:) filesep];
    gre_field_phase_img = ls(gre_field_mapping_phase_dir);
    gre_field_phase_img = gre_field_phase_img(strncmpi(cellstr(gre_field_phase_img),'sPR',3),:);
    EPIdir = [commondir subdir(sub,:) filesep 'gratings\'];
    T1dir = [commondir subdir(sub,:) filesep 't1_mprage_tra_p2_iso\'];
    T1img = ls(T1dir);
    T1img = T1img((~cellfun(@isempty,regexpi(cellstr(T1img),'^s\S+nii','match'))),:);
    LOCdir = [commondir subdir(sub,:) filesep 'LOC\'];
    retinotopydir = [commondir subdir(sub,:) filesep 'retinotopy\'];
    targetROIdir = [commondir subdir(sub,:) filesep 'targetROI\'];
    wholeBraindir = [commondir subdir(sub,:) filesep 'wholeBrain\'];

    %% Calculate VDM
    step=step+1;
    cd([EPIdir])
    nSess = size(ls,1)-2;
    EPIsessions = dir([EPIdir]);
    EPIsessions = EPIsessions([EPIsessions.isdir]);
    EPIsessions = EPIsessions(3:end);
    
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[gre_field_mapping_phase_dir strtrim(gre_field_phase_img) ',1']};
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[gre_field_mapping_magnitude_dir strtrim(gre_field_mapping_magnitude_img1) ',1']};
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {pmdefaults_file};
    %gratings sessions
    for sess = 1:length(EPIsessions)
        cd([EPIdir EPIsessions(sess,:).name])
        img = ls('f*.nii');
        img = img(6:end,:); % discarding "dummy" scans
        images{sess} = cellstr([repmat([EPIdir EPIsessions(sess,:).name filesep],size(img,1),1) img]);
        
        matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.session(sess).epi(1) = cellstr(images{1,sess}{1,1});
    end
    %LOC session
    sess = sess + 1; 
    cd(LOCdir)
    img = ls('f*.nii');
    img = img(6:end,:);
    images{sess} = cellstr([repmat(LOCdir,size(img,1),1) img]);
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.session(sess).epi(1) = cellstr(images{1,sess}{1,1});
    % retinotopy session
    sess = sess + 1; 
    cd(retinotopydir)
    img = ls('f*.nii');
    img = img(6:end,:);
    images{sess} = cellstr([repmat(retinotopydir,size(img,1),1) img]);
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.session(sess).epi(1) = cellstr(images{1,sess}{1,1});
    % targetROI session
    sess = sess + 1; 
    cd(targetROIdir)
    img = ls('f*.nii');
    img = img(6:end,:);
    images{sess} = cellstr([repmat(targetROIdir,size(img,1),1) img]);
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.session(sess).epi(1) = cellstr(images{1,sess}{1,1});
    
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    
    %% Realign & unwarp
    step=step+1;
    for sess = 1:length(images)
        matlabbatch{step}.spm.spatial.realignunwarp.data(sess).scans = images{sess};
        matlabbatch{step}.spm.spatial.realignunwarp.data(sess).pmscan(1) = cfg_dep(['Presubtracted Phase and Magnitude Data: Voxel displacement map (Subj 1, Session ' num2str(sess) ')'], substruct('.','val', '{}',{step-1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{sess}));
    end
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.quality = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.rtm = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
    
    %% Slice timing correction
    step = step + 1;
    nslices = 30;
    TR = 1.98; 
    for sess = 1:length(images) 
        matlabbatch{step}.spm.temporal.st.scans{sess}(1) = cfg_dep(['Realign & Unwarp: Unwarped Images (Sess ' num2str(sess) ')'], substruct('.','val', '{}',{step-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{sess}, '.','uwrfiles'));
    end
    matlabbatch{step}.spm.temporal.st.nslices = nslices;
    matlabbatch{step}.spm.temporal.st.tr = TR;
    matlabbatch{step}.spm.temporal.st.ta = TR-TR/nslices;
    matlabbatch{step}.spm.temporal.st.so = 1:nslices;
    matlabbatch{step}.spm.temporal.st.refslice = 1;
    matlabbatch{step}.spm.temporal.st.prefix = 'a';
    
    %% Bias correction
    step=step+1;
    for sess = 1:length(images)
        matlabbatch{step}.spm.tools.biasCorrect.data{1}(sess) = cfg_dep(['Slice Timing: Slice Timing Corr. Images (Sess ' num2str(sess) ')'], substruct('.','val', '{}',{step-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{sess}, '.','files'));
    end

    %% Calculate VDM for whole brain EPI
    step = step + 1;
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[gre_field_mapping_phase_dir strtrim(gre_field_phase_img) ',1']};
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[gre_field_mapping_magnitude_dir strtrim(gre_field_mapping_magnitude_img1) ',1']};
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {[pipelinedir pmdefaults_m]};
    sess = sess + 1; 
    cd(wholeBraindir)
    img = ls;
    img = img(img(:,1)=='f',:);
    clear images
    sess = 1;
    images{sess} = cellstr([repmat(wholeBraindir,size(img,1),1) img]);
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.session(sess).epi(1) = cellstr(images{1,sess}{1,1});
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
    matlabbatch{step}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    
    %% Realign & unwarp whole brain EPI
    step = step + 1;
    for sess = 1:length(images)
        matlabbatch{step}.spm.spatial.realignunwarp.data(sess).scans = images{sess};
        matlabbatch{step}.spm.spatial.realignunwarp.data(sess).pmscan(1) = cfg_dep(['Presubtracted Phase and Magnitude Data: Voxel displacement map (Subj 1, Session ' num2str(sess) ')'], substruct('.','val', '{}',{step-1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{sess}));
    end
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.quality = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.rtm = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{step}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{step}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{step}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
    
    %% Coregister: estimate (structural image to whole brain EPI)
    step = step + 1;
    matlabbatch{step}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
    matlabbatch{step}.spm.spatial.coreg.estimate.source = {strtrim([T1dir T1img])};
    matlabbatch{step}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    %% Coregister: estimate (whole brain and structural to mean partial EPI)
    step = step + 1;
    matlabbatch{step}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
    matlabbatch{step}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
    matlabbatch{step}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{step}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    
    %% Coregister: write (apply structural image transformation)
    step = step + 1;
    matlabbatch{step}.spm.spatial.coreg.write.ref = {strtrim([T1dir T1img])};
    matlabbatch{step}.spm.spatial.coreg.write.source = {strtrim([T1dir T1img])};
    matlabbatch{step}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{step}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{step}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{step}.spm.spatial.coreg.write.roptions.prefix = 'r';
    
    %% Smoothing 
    % run for all sessions, but outputs only used for localizer sessions
    step = step + 1;
    matlabbatch{step}.spm.spatial.smooth.data(1) = cfg_dep('Bias correction: Bias corrected images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{step}.spm.spatial.smooth.fwhm = [4 4 4];
    matlabbatch{step}.spm.spatial.smooth.dtype = 0;
    matlabbatch{step}.spm.spatial.smooth.im = 0;
    matlabbatch{step}.spm.spatial.smooth.prefix = 's';

    spm_jobman('run',matlabbatch)
    clear matlabbatch
end
end