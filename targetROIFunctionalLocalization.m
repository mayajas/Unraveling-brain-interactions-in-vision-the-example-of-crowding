function [] = targetROIFunctionalLocalization(commondir, subdir)
% first level analysis of target localizer session
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    targetROIdir = [commondir subdir(sub,:) filesep 'targetROI'];
    cd(targetROIdir)
    delete SPM.mat
    brain_mask = [commondir subdir(sub,:) '\ROIs\brain_mask.nii,1'];

    %% Model specification
    matlabbatch{1}.spm.stats.fmri_spec.dir = {targetROIdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.98;
    nslices = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nslices;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    cd([commondir subdir(sub,:) filesep 'behav\fMRI'])
    [~,initials] = strread(subdir(sub,:),'%s %s', 'delimiter','_');
    initials = cell2mat(initials);
    initials = initials(1:2);
    sess = 1; con = 1;
    dvfiles = ls([initials '_targetROI_*.dv']);
    dv = readDvFile(dvfiles(sess,:));
    
    scans = ls([targetROIdir filesep 'sbauf*']);
    
    for img = 1:size(scans,1)
        matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans{img,1} = [targetROIdir filesep strtrim(scans(img,:)) ',1'];
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).name = 'Targets';
    onsets = dv.pool1.blocktime(dv.pool1.blocktype==con)-dv.pool1.blocktime(1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).onset = onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).duration = 16;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {brain_mask};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';%
    
    %% Model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    %% Contrast definition
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Targets';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.delete = 0;
    try
        spm_jobman('run',matlabbatch)
    catch
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        spm_jobman('run',matlabbatch)
    end
    clear matlabbatch
end
end
