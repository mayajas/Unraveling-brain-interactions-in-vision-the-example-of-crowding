function [] = copyRetinotopyFiles(commondir, subdir, serverdir, direction)
% copy files for retinotopic mapping
% Maya A. Jastrz?bowska

if strcmp(direction,'to-linux')
    for sub = 1:size(subdir,1)
        retinotopydir = [commondir subdir(sub,:) filesep 'retinotopy\'];
        T1dir = [commondir subdir(sub,:) filesep 't1_mprage_tra_p2_iso\'];
        T1img = ls(T1dir);
        T1img = T1img((~cellfun(@isempty,regexpi(cellstr(T1img),'^s\S+nii','match'))),:);

        % Find fMRI reference paths and make 4D image of preprocessed
        % retinotopy files
        cd(retinotopydir)
        ret_files = cellstr(pickfiles(retinotopydir,{'.nii','bauf'},'.',{'mean.nii','4D.nii','sbauf'}));
        retBase = fileparts(ret_files{1});
        ret_4Dpath = [retBase filesep 'Retinotopy_4D.nii'];

        if ~exist(ret_4Dpath)
            nii = niftiRead(ret_files{1});
            RefData = nii.data;
            nretfiles = 119;

            for i=1:nretfiles
                nii = niftiRead(ret_files{i+1});
                RefData = cat(4, RefData, nii.data);
            end
            dtiWriteNiftiWrapper(RefData, nii.qto_xyz, ret_4Dpath, 1, '', [],[],[],[], 1);
            gunzip([retBase filesep '*.gz'])
        end

        if ~exist([commondir '_Retinotopy' filesep subdir(sub,:)])
            mkdir([commondir '_Retinotopy' filesep subdir(sub,:)])
        end

        % Copy files needed to run retinotopy (on linux)
        if ~exist([commondir '_Retinotopy' filesep subdir(sub,:) filesep 'anat.nii'])
            copyfile(ret_4Dpath,[commondir '_Retinotopy' filesep subdir(sub,:)])
            copyfile([T1dir 'r' T1img], [commondir '_Retinotopy' filesep subdir(sub,:) filesep 'anat.nii'])
        end
    end
    
else ifstrcmp(direction,'from-linux')
    for sub = 1:size(subdir,1)
        % Copy ROI files (post retinotopy & manual delineation on linux)
        ROIdir = [commondir subdir(sub,:) filesep 'ROIs\'];

        if ~exist(ROIdir)
            mkdir(ROIdir)
        end
        cd(ROIdir)
        rois = {'V1','V2','V3','V4'};
        for r = 1:length(rois)
            copyfile([serverdir filesep subdir(sub,:) filesep rois{r} '.nii'],ROIdir)
        end
    end
end

end











