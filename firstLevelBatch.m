function [] = firstLevelBatch(commondir, subdir)
% first level analysis of main experiment
% Maya A. Jastrz?bowska

nslices = 30;
TR = 1.98;

for sub = 1:size(subdir,1)
    cd([commondir subdir(sub,:)])

    gratings_dir = [commondir subdir(sub,:) filesep 'gratings' filesep];
    cd(gratings_dir)

    delete SPM.mat

    EPIsessions = dir([gratings_dir]);
    EPIsessions = EPIsessions([EPIsessions.isdir]);
    EPIsessions = EPIsessions(3:end);
    if size(EPIsessions,1)~=5
        error
    end

    brain_mask = [commondir subdir(sub,:) '\ROIs\brain_mask.nii,1'];

    %% Model specification
    step = 1;
    matlabbatch{step}.spm.stats.fmri_spec.dir = {gratings_dir};%{gratings_dir};
    matlabbatch{step}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{step}.spm.stats.fmri_spec.timing.RT = TR;

    matlabbatch{step}.spm.stats.fmri_spec.timing.fmri_t = nslices;
    matlabbatch{step}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    cd([commondir subdir(sub,:) filesep 'behav\fMRI'])
    [~,initials] = strread(subdir(sub,:),'%s %s', 'delimiter','_');
    initials = cell2mat(initials);
    initials = initials(1:2);
    dvfiles = ls([initials '_1*.dv']);
    for sess = 1:5
        scans = ls([gratings_dir EPIsessions(sess,:).name filesep 'bauf*']);
        
        for img = 1:size(scans,1)
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).scans{img,1} = [gratings_dir EPIsessions(sess,:).name filesep strtrim(scans(img,:)) ',1'];
        end
        dv = readDvFile(dvfiles(sess,:));
        for con = 1:7
            if con == 1
                conname = 'Single target';
            elseif con == 2
                conname = '2-flanker target';
            elseif con == 3
                conname = 'Annulus-flanker target';
            elseif con == 4
                conname = '4-flanker target';
            elseif con == 5
                conname = '2-flanker control';
            elseif con == 6
                conname = 'Annulus-flanker control';
            elseif con == 7
                conname = '4-flanker control';
            end
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).name = conname;
            onsets = dv.pool0.stimonset(dv.pool0.context_no==con & dv.pool0.valid==1)-dv.pool0.stimonset(1);
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).onset = onsets;
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).duration = 0;
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).tmod = 0;
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).orth = 1;
        end
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).multi_reg = {''};
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).hpf = 128;
    end
    matlabbatch{step}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{step}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{step}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{step}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{step}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{step}.spm.stats.fmri_spec.mask = {brain_mask};
    matlabbatch{step}.spm.stats.fmri_spec.cvi = 'FAST';

    %% Model estimation
    step = 2;
    matlabbatch{step}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{step}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{step}.spm.stats.fmri_est.method.Classical = 1;

    %% Contrast definition
    step = 3;
    matlabbatch{step}.spm.stats.con.spmmat(1) = {[gratings_dir '\SPM.mat']};
    con = 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = 'Single target';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = '2-flanker target';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = 'Annulus-flanker target';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = '4-flanker target';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = '2-flanker control';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = 'Annulus-flanker control';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 0 0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.name = '4-flanker control';
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.weights = [0 0 0 0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.tcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.name = 'Target conditions';
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.weights = [1 0 0 0
                                                                 0 1 0 0
                                                                 0 0 1 0
                                                                 0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.sessrep = 'repl';
    con = con + 1;
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.name = 'Control conditions';
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.weights = [0 0 0 0 1 0 0
                                                                 0 0 0 0 0 1 0
                                                                 0 0 0 0 0 0 1];
    matlabbatch{step}.spm.stats.con.consess{con}.fcon.sessrep = 'repl';
    matlabbatch{step}.spm.stats.con.delete = 1;

    try
        spm_jobman('run',matlabbatch)
    catch
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        spm_jobman('run',matlabbatch)
    end
    clear matlabbatch
end