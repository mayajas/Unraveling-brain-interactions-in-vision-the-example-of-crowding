%% Unraveling brain interactions in vision: the example of crowding
%  Maya A. Jastrz?bowska

%% requirements/dependencies
% SPM (https://www.fil.ion.ucl.ac.uk/spm/software/download/)
% Vistasoft (https://github.com/vistalab/vistasoft)
% SamSrf toolbox (https://github.com/samsrf/samsrf)
% Freesurfer (https://surfer.nmr.mgh.harvard.edu/)


%% initialize paths
SPMdir = 'C:\DATA\MJ\spm12_fil';                % path to SPM
addpath(SPMdir)
vsdir = 'C:\DATA\MJ\vistasoft';                 % path to Vistasoft
addpath(genpath(vsdir))
commondir = 'C:\DATA\MJ\crowding\data\';        % path to directory containing subject folders
cd(commondir)
subdir = ls('sub-*');
pmdefaults_file = ...                           % path to fieldmap toolbox defaults file
    'C:\DATA\MJ\pm_defaults_Prisma_3mm.m';   
serverdir = ...                                 % path to directory containing subject folders on linux server
    '\\filerch\data\mjastrze\crowding\retinotopy';                                 

%% preprocessing
preprocessing(commondir, subdir, pmdefaults_file)

% copy retinotopy files to Linux server, do retinotopic mapping with SamSrf 
% toolbox, do manual delineations of areas V1-V4
copyRetinotopyFiles(commondir, subdir, serverdir, 'to-linux')

%% retinotopic mapping
% on Linux: run FS recon-all, pRF mapping w/ SamSrf toolbox manual 
% delineations of areas V1 - V4

% copy V1-V4 binary masks back to local subject directories
copyRetinotopyFiles(commondir, subdir, serverdir, 'from-linux')

%% first level analysis
% make brain masks
makeBrainMasks(commondir, subdir)

% first level
firstLevelBatch(commondir, subdir)

%% localizers
% LOC ROI functional localization
LOCROIFunctionalLocalization(commondir, subdir)

% Make LOC ROI 
makeLOCROI_sizematched(commondir, subdir)

% Target ROI functional localization
targetROIFunctionalLocalization(commondir, subdir)

% Make target ROIs
makeTargetROIs_sizematched(commondir, subdir)

% Count nr voxels per target ROI
[ROIvolumes, targetROIvolumes] = countNrVoxPerROI(commondir, subdir);

%% concatenate gratings sessions
concatenateSessions4DCM(commondir, subdir)

%% percent BOLD signal change (PSC) analysis
PSC_DCMSPMs(commondir, subdir)

%% dynamic causal modeling analysis
% Extract VOIs for DCM
extractVOIs4DCM(commondir, subdir)

% Run DCM Analysis
DCMTemplateDir = [commondir filesep 'DCM_Templates']; 
mkdir(DCMTemplateDir)
DCMPEBanalysis(commondir, subdir, DCMTemplateDir)



