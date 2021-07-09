function [] = LOCROIFunctionalLocalization(commondir, subdir)
% first level analysis of LOC localizer session
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    LOCROIdir = [commondir subdir(sub,:) filesep 'LOC'];
    cd(LOCROIdir)
    delete SPM.mat
    brain_mask = [commondir subdir(sub,:) '\ROIs\brain_mask.nii,1'];

    %% Model specification
    matlabbatch{1}.spm.stats.fmri_spec.dir = {LOCROIdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.98;
    nslices = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nslices;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    cd([commondir subdir(sub,:) filesep 'behav\fMRI'])
    [~,initials] = strread(subdir(sub,:),'%s %s', 'delimiter','_');
    initials = cell2mat(initials);
    initials = initials(1:2);
    sess = 1; 
    dvfiles = ls([initials '_LOC_*.dv']);
    dv = readDvFile(dvfiles(sess,:));
    
    scans = ls([LOCROIdir filesep 'sbauf*']);
    
    for img = 1:size(scans,1)
        matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans{img,1} = [LOCROIdir filesep strtrim(scans(img,:)) ',1'];
    end
    % 6 blocks of each type of images were presented in succession (intact,
    % scrambled, intact, etc). In each 16 s block, a series of 20 images 
    % appeared separated by an empty screen with a fixation dot (200 ms 
    % stimulus and 600 ms fixation per image).       
    con = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).name = 'Intact';
    onsets = dv.pool0.blocktime(dv.pool0.blocktype==con)-dv.pool0.blocktime(1);
    nblocks = length(onsets);
    add_trials = 0.8:0.8:(16-0.8);
    for i = 1:nblocks
        curr_onset = onsets(i);
        others = onsets(i+1:end);
        if i == 1
            onsets_expanded = [curr_onset; repmat(curr_onset,length(add_trials),1)+add_trials'];
        else
            onsets_expanded = [onsets_expanded; curr_onset; repmat(curr_onset,length(add_trials),1)+add_trials'];
        end
    end
    onsets = onsets_expanded;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).onset = onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).duration = 0.2;%
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).orth = 1;
    con=2;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).name = 'Scrambled';
    onsets = dv.pool0.blocktime(dv.pool0.blocktype==con)-dv.pool0.blocktime(1);
    nblocks = length(onsets);
    add_trials = 0.8:0.8:(16-0.8);
    for i = 1:nblocks
        curr_onset = onsets(i);
        others = onsets(i+1:end);
        if i == 1
            onsets_expanded = [curr_onset; repmat(curr_onset,length(add_trials),1)+add_trials'];
        else
            onsets_expanded = [onsets_expanded; curr_onset; repmat(curr_onset,length(add_trials),1)+add_trials'];
        end
    end
    onsets = onsets_expanded;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).onset = onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).duration = 0.2;%
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(con).orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {brain_mask};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
    
    %% Model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    %% Contrast definition
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'LOC';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
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
