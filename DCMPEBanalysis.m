function [] = DCMPEBanalysis(commondir, subdir)
% DCM and PEB analysis
% Maya A. Jastrz?bowska

subjects = 1:size(subdir,1); % all subjects

nslices = 30;
TR = 1.98;
ninputs = 4; % 4 target conditions

PEB_dir = [commondir filesep 'PEB\'];


%% Model definition
Model = createDCMmodelSpace();
nmodels = size(Model,3);

cd(DCMTemplateDir)
load('DCM_Template_5ROIs.mat')

temp = DCM;
for con1 = 1:nmodels
    
    DCM = temp;
    DCM.b(:,:,1) = Model(:,:,con1);
    DCM.b(:,:,2) = Model(:,:,con1);
    DCM.b(:,:,3) = Model(:,:,con1);
    DCM.b(:,:,4) = Model(:,:,con1);
    save([DCMTemplateDir 'DCM_Model' num2str(con1) '.mat'],'DCM')
end
   
                
%% Create all models for each subject
% but do not estimate (this will be done within the PEB framework)
AllModels = ls([DCMTemplateDir 'DCM_*']);
for sub = subjects
    
    ROIdir = [commondir subdir(sub,:) filesep 'ROIs\'];
    gratings_dir = [commondir subdir(sub,:) filesep 'gratings' filesep];
    t     = nslices;
        
    DCMdir = [gratings_dir 'DCM\'];
    cd(DCMdir)

    %% check slices for each ROI
    VOIs = {[DCMdir 'VOI_V1_1.mat'],...
            [DCMdir 'VOI_V2_1.mat'],...
            [DCMdir 'VOI_V3_1.mat'],...
            [DCMdir 'VOI_V4_1.mat'],...
            [DCMdir 'VOI_LOC_1.mat']};

    t0 = 1;
    T0     = TR * t0 / t;
    VOI_timings = repmat(T0,5,1);  

    for mod = 1:nmodels
        load([DCMTemplateDir AllModels(mod,:)])
        load([DCMdir 'SPM.mat'])

        inputs = {1 1 1 1};
        sess = 1;
        DCM.delays = VOI_timings;
        DCM = spm_dcm_voi(DCM,VOIs);
        DCM = spm_dcm_U(DCM,SPM,sess,inputs);

        save([DCMdir AllModels(mod,:)],'DCM');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parametric empirical Bayes (PEB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(PEB_dir)
    mkdir(PEB_dir)
end

%% Make GCM file
cd(commondir)
subdir = ls('PR*');
DCMmodel = ls(DCMTemplateDir);
DCMmodel = DCMmodel(3:end,:);
[~, reindex] = sort( str2double( regexp( cellstr(DCMmodel), '\d+', 'match', 'once' )));
DCMmodel = DCMmodel(reindex,:) ;
GCM = cell(length(subjects),nmodels);
for sub = subjects
    gratings_dir = [commondir subdir(sub,:) filesep 'gratings'];
    DCMdir = [gratings_dir filesep 'DCM\'];
    cd(DCMdir)
    for mod = 1:nmodels
        load([DCMdir strtrim(DCMmodel(mod,:))])
        GCM{sub,mod} = DCM;
        clear DCM
    end
end

cd(PEB_dir)
save('GCM.mat','GCM','GCM','-v7.3')

%% Estimate Model 1
% load GCM.mat
GCM(:,1) = spm_dcm_peb_fit(GCM(:,1)); 
save('GCM_model1estimated.mat','GCM','-v7.3');

%% BMR: estimate other models
GCM = spm_dcm_bmr(GCM);
cd(PEB_dir)
save('GCM_allmodelsestimated.mat','GCM','-v7.3')


%% From fully estimated GCM
cd(PEB_dir)
% load(['GCM_allmodelsestimated.mat'])
% GCMfull = GCM;
M = struct();
M.alpha = 1;
M.beta  = 16;
M.hE    = 0;
M.hC    = 1/16;
M.Q     = 'single';
N = size(GCM,1);
M.X = ones(N,1);        % group mean
M.Xnames = {'Mean'};

for i = 1:ninputs
    % Choose field
    field = {['B(:,:,' num2str(i) ')']};

    % Estimate model
    GCMtemp = GCMfull(:,1);
    [PEB, GCM_updated]  = spm_dcm_peb(GCMtemp,M,field);

    GCMtemp = GCM;
    GCM = GCM_updated;
    save(['B' num2str(i) 'full_GCM_updated.mat'],'GCM','-v7.3')
    save(['B' num2str(i) 'full_PEB.mat'],'PEB');
    GCM = GCMtemp;

    % Bayesian model comparison: Compare the full PEB model to nested PEB 
    % models to test specific hypotheses
    [BMA,BMR] = spm_dcm_peb_bmc(PEB, GCM(1,:));
    save(['B' num2str(i) 'full_BMA.mat'],'BMA','-v7.3');
    save(['B' num2str(i) 'full_BMR.mat'],'BMR','-v7.3');

    %% Bayesian family model averaging
    bma_option = 'ALL';
    
    % 'processing direction' factor 
    % 1 - bottom-up
    % 2 - top-down
    % 3 - recurrent
    % 4 - self-inhibitory
    % 5 - bottom-up + self-inhibitory
    % 6 - top-down + self-inhibitory
    % 7 - recurrent + self-inhibitory
    % 8 - no modulation
    families = [7 ones(1,12) 2*ones(1,12) 3*ones(1,12) 4*ones(1,9) ...
        5*ones(1,12) 6*ones(1,12) 7*ones(1,11) 8];
    [BMA,fam] = spm_dcm_peb_bmc_fam(BMA,BMR,families,bma_option);
    save(['B' num2str(i) 'full_StructFamBMA.mat'],'BMA','fam')
    
    % 'ROI involvement' factor
    load(['B' num2str(i) 'full_BMA.mat'])
    families = zeros(1,nmodels);                            
    families([1 2 9 14 21 26 33 38 47 54 59 66 77]) = 1;    % all rois
    families([3 10 15 22 27 34 39 48 55 60 67 71 78]) = 2;  % xV1
    families([4 11 16 23 28 35 40 49 56 61 68 72 79]) = 3;  % xV1V2
    families([5 17 29 41 50 62 73]) = 4;                    % xV1V2V3
    families(42) = 5;                                       % xV1V2V3V4
    families([6 12 18 24 30 36 43 51 57 63 69 74 80]) = 6;  % xLOC
    families([7 13 19 25 31 37 44 52 58 64 70 75 81]) = 7;  % xV4LOC
    families([8 20 32 45 53 65 76]) = 8;                    % xV3V4LOC
    families(46) = 9;                                       % xV2V3V4LOC
    families(82) = 10;                                      % no modulation
    [BMA,fam] = spm_dcm_peb_bmc_fam(BMA,BMR,families,bma_option);
    save(['B' num2str(i) 'full_ROIFamBMA.mat'],'BMA','fam')
end


%%
%spm_dcm_peb_review(PEB,GCM)
figure; 
load B1full_BMA.mat
FreeEnergy(1,:) = BMA.F;
subplot(5,1,1)
bar(BMA.F(1:end-1) - BMA.F(end))
load B2full_BMA.mat
FreeEnergy(2,:) = BMA.F;
subplot(5,1,2)
bar(BMA.F(1:end-1) - BMA.F(end))
load B3full_BMA.mat
FreeEnergy(3,:) = BMA.F;
subplot(5,1,3)
bar(BMA.F(1:end-1) - BMA.F(end))
load B4full_BMA.mat
FreeEnergy(4,:) = BMA.F;
subplot(5,1,4)
bar(BMA.F(1:end-1) - BMA.F(end))
load B3B4full_BMA.mat
FreeEnergy(5,:) = BMA.F;
subplot(5,1,5)
bar(BMA.F(1:end-1) - BMA.F(end))

% Plots, separating uncrowding conditions
load B1full_StructFamBMA.mat
F1=fam.model.post;
F1fam=fam.family.post;
load B2full_StructFamBMA.mat
F2=fam.model.post;
F2fam=fam.family.post;
load B3full_StructFamBMA.mat
F3=fam.model.post;
F3fam=fam.family.post;
load B4full_StructFamBMA.mat
F4=fam.model.post;
F4fam=fam.family.post;

figure; bar([F1'; F2'; F3'; F4']')
figure; bar([F1fam'; F2fam'; F3fam'; F4fam']')
PosteriorModels = [F1'; F2'; F3'; F4']';
PosteriorStructFam = [F1fam'; F2fam'; F3fam'; F4fam']';

load B1full_ROIFamBMA.mat
F1=fam.model.post;
F1fam=fam.family.post;
load B2full_ROIFamBMA.mat
F2=fam.model.post;
F2fam=fam.family.post;
load B3full_ROIFamBMA.mat
F3=fam.model.post;
F3fam=fam.family.post;
load B4full_ROIFamBMA.mat
F4=fam.model.post;
F4fam=fam.family.post;

figure; bar([F1fam'; F2fam'; F3fam'; F4fam']')
PosteriorROIFam = [F1fam'; F2fam'; F3fam'; F4fam']';

save('PEBresults.mat','FreeEnergy','PosteriorModels','PosteriorROIFam','PosteriorStructFam')

end