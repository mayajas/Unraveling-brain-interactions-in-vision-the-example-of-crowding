function [] = concatenateSessions4DCM(commondir, subdir)
% concatenate sessions for DCM analysis, estimate first level model
% Maya A. Jastrz?bowska

scan_prefix = 'bauf*';
nslices = 30;
TR = 1.98;
nsess = 5; 

for sub = 1:size(subdir,1)
    step = 0;
    EPIdir = [commondir subdir(sub,:) filesep 'gratings\'];
    EPIsessions = dir([EPIdir]);
    EPIsessions = EPIsessions([EPIsessions.isdir]);
    EPIsessions = EPIsessions(3:end);
    for i = 1:length(EPIsessions)
        if strcmp(EPIsessions(i).name,'DCM')
            idx = i;
        end
    end
    idx = setdiff(1:length(EPIsessions),idx);
    EPIsessions = EPIsessions(idx);
    if size(EPIsessions,1)~=nsess % 5 sessions
        error('Nr of sessions different from 5')
    end

    % Move files
    DCMdir = [EPIdir filesep 'DCM\'];
    if ~exist(DCMdir)
        mkdir(DCMdir)
    end
    cd(DCMdir)
    delete SPM.mat

    brain_mask = [commondir subdir(sub,:) '\ROIs\brain_mask.nii,1'];

    % Count nr of scans per session
    nscans = zeros(1,5);
    for sess = 1:5
        scans = ls([EPIdir EPIsessions(sess,:).name filesep scan_prefix]);
        nscans(sess) = size(scans,1);
    end

    % Model specification - all scans as one session
    step = step +1;
    matlabbatch{step}.spm.stats.fmri_spec.dir = {DCMdir};
    matlabbatch{step}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{step}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{step}.spm.stats.fmri_spec.timing.fmri_t = nslices;
    matlabbatch{step}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    cd([commondir subdir(sub,:) filesep 'behav\fMRI'])
    [~,initials] = strread(subdir(sub,:),'%s %s', 'delimiter','_');
    initials = cell2mat(initials);
    initials = initials(1:2);
    dvfiles = ls([initials '_1*.dv']);

    % Get scans and onsets/RTs for all sessions together
    for sess = 1:5
        dv = readDvFile(dvfiles(sess,:));
        if sess == 1
            temp = ls([EPIdir EPIsessions(sess,:).name filesep scan_prefix]);
            scans = fullfile([EPIdir EPIsessions(sess,:).name filesep],...
                mat2cell(temp,ones(nscans(sess),1),size(temp,2)));
            time2add = 0;
            for con = 1:7
                onsets{con} = dv.pool0.stimonset(dv.pool0.context_no==con & dv.pool0.valid==1)-...
                    dv.pool0.stimonset(1) + time2add;
                rts{con} = dv.pool0.react_ti(dv.pool0.context_no==con & dv.pool0.valid==1) ./ 1000;
            end
        else
            temp = ls([EPIdir EPIsessions(sess,:).name filesep scan_prefix]);
            scans = [scans; fullfile([EPIdir EPIsessions(sess,:).name filesep],...
                mat2cell(temp,ones(nscans(sess),1),size(temp,2)))];
            time2add = time2add + nscans(sess-1)*TR;
            for con = 1:7
                onsets{con} = [onsets{con}; dv.pool0.stimonset(dv.pool0.context_no==con & dv.pool0.valid==1)-...
                    dv.pool0.stimonset(1) + time2add];
                rts{con} = [rts{con}; dv.pool0.react_ti(dv.pool0.context_no==con & dv.pool0.valid==1)...
                    ./ 1000];
            end
        end
    end

    % Enter all into design as one session
    sess = 1;
    matlabbatch{step}.spm.stats.fmri_spec.sess(sess).scans = scans;

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
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).onset = onsets{con};
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).duration = 0;
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).tmod = 0;
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{step}.spm.stats.fmri_spec.sess(sess).cond(con).orth = 1;
    end
    matlabbatch{step}.spm.stats.fmri_spec.sess(sess).multi_reg = {''};
    matlabbatch{step}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
    matlabbatch{step}.spm.stats.fmri_spec.sess(sess).hpf = 128;

    matlabbatch{step}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{step}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{step}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{step}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{step}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{step}.spm.stats.fmri_spec.mask = {brain_mask};
    matlabbatch{step}.spm.stats.fmri_spec.cvi = 'AR(1)';

    spm_jobman('run',matlabbatch)
    clear matlabbatch

    % Concatenate
    cd(DCMdir)
    spm_fmri_concatenate('SPM.mat',nscans)

    % Model estimation
    step = 0;
    step = step + 1;
    matlabbatch{step}.spm.stats.fmri_est.spmmat(1) = {[DCMdir '\SPM.mat']};
    matlabbatch{step}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{step}.spm.stats.fmri_est.method.Classical = 1;

    % Contrast definition
    step = step + 1;
    matlabbatch{step}.spm.stats.con.spmmat(1) = {[DCMdir '\SPM.mat']};
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
    spm_jobman('run',matlabbatch)
    clear matlabbatch

end
