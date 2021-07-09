function [] = makeBrainMasks(commondir, subdir)
% make brain masks (used for first level analysis)
% Maya A. Jastrz?bowska

for sub = 1:size(subdir,1)
    cd([commondir subdir(sub,:)])
    T1dir = [commondir subdir(sub,:) filesep 't1_mprage_tra_p2_iso\'];
    T1img = ls(T1dir);
    T1img = T1img((~cellfun(@isempty,regexpi(cellstr(T1img),'^s\S+nii','match'))),:);
    ROIdir = [commondir subdir(sub,:) filesep 'ROIs\'];
    mkdir(ROIdir)
    gratingsdir = [commondir subdir(sub,:) filesep 'gratings\'];
    gratingssubdir = ls(gratingsdir);
    gratingsimg = ls([gratingsdir gratingssubdir(3,:)]);
    gratingsimg = gratingsimg((~cellfun(@isempty,regexpi(cellstr(gratingsimg),'^bauf\S+nii','match'))),:);
    gratingsimg = strtrim(gratingsimg(1,:));
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {strtrim([T1dir 'r' T1img])};
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,1'};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,2'};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,3'};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,4'};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,5'};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'E:\DATA\MJ\spm12_fil\tpm\TPM.nii,6'};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [1 0];
    matlabbatch{2}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Inverse Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','invdef', '()',{':'}));
    matlabbatch{2}.spm.util.defs.out{1}.pull.fnames = {'E:\DATA\MJ\spm12_fil\tpm\mask_ICV.nii'};
    matlabbatch{2}.spm.util.defs.out{1}.pull.savedir.saveusr = {ROIdir};
    matlabbatch{2}.spm.util.defs.out{1}.pull.interp = 0;
    matlabbatch{2}.spm.util.defs.out{1}.pull.mask = 0;
    matlabbatch{2}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
    matlabbatch{2}.spm.util.defs.out{1}.pull.prefix = 'brain_';
    matlabbatch{3}.spm.spatial.coreg.write.ref = {[gratingsdir gratingssubdir(3,:) filesep gratingsimg ',1']};
    matlabbatch{3}.spm.spatial.coreg.write.source(1) = cfg_dep('Deformations: Warped Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','warped'));
    matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 0;
    matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';
    
    spm_jobman('run',matlabbatch)
    delete([ROIdir 'brain_mask_ICV.nii'])
    movefile([ROIdir 'rbrain_mask_ICV.nii'],[ROIdir 'brain_mask.nii'])
end

end