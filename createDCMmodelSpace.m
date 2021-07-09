function Model = createDCMmodelSpace()
% create model space of 82 models, which vary according to 2 factors:
% processing direction and ROI involvement
% Maya A. Jastrz?bowska

nROIs = 5;
nmodels = 82;

Model = zeros(nROIs,nROIs,nmodels);
%% Full
% Model 1 (full)
Model(:,:,1) = [1 1 1 1 1;
                1 1 1 1 1;
                1 1 1 1 1;
                1 1 1 1 1;
                1 1 1 1 1];
   
%% Bottom-up
% Model 2 (bottom-up modulation, V1 full)
Model(:,:,2) = [0 0 0 0 0;
                1 0 0 0 0;
                1 1 0 0 0;
                1 1 1 0 0;
                1 1 1 1 0];
% Model 3 (bottom-up modulation, V2 full)
Model(:,:,3) = [0 0 0 0 0;
                0 0 0 0 0;
                0 1 0 0 0;
                0 1 1 0 0;
                0 1 1 1 0];
% Model 4 (bottom-up modulation, V3 full)
Model(:,:,4) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 1 0 0;
                0 0 1 1 0];            
% Model 5 (bottom-up modulation, V4 full)
Model(:,:,5) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 1 0];
% Model 6 (bottom-up modulation, V1 full)
Model(:,:,6) = [0 0 0 0 0;
                1 0 0 0 0;
                1 1 0 0 0;
                1 1 1 0 0;
                0 0 0 0 0];
% Model 7 (bottom-up modulation, V1 full)
Model(:,:,7) = [0 0 0 0 0;
                1 0 0 0 0;
                1 1 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
% Model 8 (bottom-up modulation, V1 full)
Model(:,:,8) = [0 0 0 0 0;
                1 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
% Model 9 (bottom-up modulation, V1)
Model(:,:,9) = [0 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0];
% Model 10 (bottom-up modulation, V2)
Model(:,:,10) = [0 0 0 0 0;
                0 0 0 0 0;
                0 1 0 0 0;
                0 1 0 0 0;
                0 1 0 0 0];
% Model 11 (bottom-up modulation, V3)
Model(:,:,11) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 1 0 0;
                0 0 1 0 0];            
% Model 12 (bottom-up modulation, V1)
Model(:,:,12) = [0 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0;
                0 0 0 0 0];
% Model 13 (bottom-up modulation, V1)
Model(:,:,13) = [0 0 0 0 0;
                1 0 0 0 0;
                1 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
%% Top-down
% Model 14 (top-down modulation, LOC)
Model(:,:,14) = [0 1 1 1 1;
                0 0 1 1 1;
                0 0 0 1 1;
                0 0 0 0 1;
                0 0 0 0 0];
% Model 15 (top-down modulation, LOC)
Model(:,:,15) = [0 0 0 0 0;
                 0 0 1 1 1;
                 0 0 0 1 1;
                 0 0 0 0 1;
                 0 0 0 0 0];
% Model 16 (top-down modulation, LOC)
Model(:,:,16) = [0 0 0 0 0;
                 0 0 0 0 0;
                 0 0 0 1 1;
                 0 0 0 0 1;
                 0 0 0 0 0];
% Model 17 (top-down modulation, LOC)
Model(:,:,17) = [0 0 0 0 0;
                 0 0 0 0 0;
                 0 0 0 0 0;
                 0 0 0 0 1;
                 0 0 0 0 0];
% Model 18 (top-down modulation, V4)
Model(:,:,18) = [0 1 1 1 0;
                 0 0 1 1 0;
                 0 0 0 1 0;
                 0 0 0 0 0;
                 0 0 0 0 0];            
% Model 19 (top-down modulation, V3)
Model(:,:,19) = [0 1 1 0 0;
                0 0 1 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];              
% Model 20 (top-down modulation, V2)
Model(:,:,20) = [0 1 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];  
% Model 21 (top-down modulation, LOC)
Model(:,:,21) = [0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 0];
% Model 22 (top-down modulation, LOC)
Model(:,:,22) = [0 0 0 0 0;
                0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 0];
% Model 23 (top-down modulation, LOC)
Model(:,:,23) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 1;
                0 0 0 0 1;
                0 0 0 0 0];
% Model 24 (top-down modulation, V4)
Model(:,:,24) = [0 0 0 1 0;
                0 0 0 1 0;
                0 0 0 1 0;
                0 0 0 0 0;
                0 0 0 0 0];            
% Model 25 (top-down modulation, V3)
Model(:,:,25) = [0 0 1 0 0;
                0 0 1 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];              
%% Recurrent
% Model 26 (recurrent: V1-LOC - same as V1 but without self-inhibitory connections)
Model(:,:,26) = Model(:,:,2) + Model(:,:,14);


% Model 27 (recurrent: V2-LOC)
Model(:,:,27) = Model(:,:,3) + Model(:,:,15);
% Model 28 (recurrent: V3-LOC)
Model(:,:,28) = Model(:,:,4) + Model(:,:,16);
% Model 29 (recurrent: V4-LOC)
Model(:,:,29) = Model(:,:,5) + Model(:,:,17);
% Model 30 (recurrent: V1-V4)
Model(:,:,30) = Model(:,:,6) + Model(:,:,18);
% Model 31 (recurrent: V1-V3)
Model(:,:,31) = Model(:,:,7) + Model(:,:,19);
% Model 32 (recurrent: V1-V2)
Model(:,:,32) = Model(:,:,8) + Model(:,:,20);
% Model 33 (recurrent: V1-LOC)
Model(:,:,33) = Model(:,:,9) + Model(:,:,21);
% Model 34 (recurrent: V2-LOC)
Model(:,:,34) = Model(:,:,10) + Model(:,:,22);
% Model 35 (recurrent: V3-LOC)
Model(:,:,35) = Model(:,:,11) + Model(:,:,23);
% Model 36 (recurrent: V1-V4)
Model(:,:,36) = Model(:,:,12) + Model(:,:,24);
% Model 37 (recurrent: V1-V3)
Model(:,:,37) = Model(:,:,13) + Model(:,:,25);

%% Self-inhibitory
% Model 38 (self-inhibitory, V1-LOC)
Model(:,:,38) = [1 0 0 0 0;
                0 1 0 0 0;
                0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1];            
% Model 39 (self-inhibitory, V2-LOC)
Model(:,:,39) = [0 0 0 0 0;
                0 1 0 0 0;
                0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1];              
% Model 40 (self-inhibitory, V3-LOC)
Model(:,:,40) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1];
% Model 41 (self-inhibitory, V4-LOC)
Model(:,:,41) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 1 0;
                0 0 0 0 1];
% Model 42 (self-inhibitory, LOC)
Model(:,:,42) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 1];  
% Model 43 (self-inhibitory, V1-V4)
Model(:,:,43) = [1 0 0 0 0;
                0 1 0 0 0;
                0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 0];  
% Model 44 (self-inhibitory, V1-V3)
Model(:,:,44) = [1 0 0 0 0;
                0 1 0 0 0;
                0 0 1 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
% Model 45 (self-inhibitory, V1-V2)
Model(:,:,45) = [1 0 0 0 0;
                0 1 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
% Model 46 (self-inhibitory, V1)
Model(:,:,46) = [1 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];
%% Bottom-up + self-inhibitory
% Model 47 (bottom-up and self-inhibitory, V1-LOC full)
Model(:,:,47) = Model(:,:,2) + Model(:,:,38);
% Model 48 (bottom-up and self-inhibitory, V2-LOC full)
Model(:,:,48) = Model(:,:,3) + Model(:,:,39);
% Model 49 (bottom-up and self-inhibitory, V3-LOC full)
Model(:,:,49) = Model(:,:,4) + Model(:,:,40);
% Model 50 (bottom-up and self-inhibitory, V4-LOC full)
Model(:,:,50) = Model(:,:,5) + Model(:,:,41);
% Model 51 (bottom-up and self-inhibitory, V1-V4 full)
Model(:,:,51) = Model(:,:,6) + Model(:,:,43);
% Model 52 (bottom-up and self-inhibitory, V1-V3 full)
Model(:,:,52) = Model(:,:,7) + Model(:,:,44);
% Model 53 (bottom-up and self-inhibitory, V1-V2 full)
Model(:,:,53) = Model(:,:,8) + Model(:,:,45);
% Model 54 (bottom-up and self-inhibitory, V1-LOC)
Model(:,:,54) = Model(:,:,9) + Model(:,:,38);
% Model 55 (bottom-up and self-inhibitory, V2-LOC)
Model(:,:,55) = Model(:,:,10) + Model(:,:,39);
% Model 56 (bottom-up and self-inhibitory, V3-LOC)
Model(:,:,56) = Model(:,:,11) + Model(:,:,40);
% Model 57 (bottom-up and self-inhibitory, V1-V4)
Model(:,:,57) = Model(:,:,12) + Model(:,:,43);
% Model 58 (bottom-up and self-inhibitory, V1-V3)
Model(:,:,58) = Model(:,:,13) + Model(:,:,44);

%% Top-down + self-inhibitory
% Model 59 (top-down and self-inhibitory, V1-LOC full)
Model(:,:,59) = Model(:,:,14) + Model(:,:,38);
% Model 60 (top-down and self-inhibitory, V2-LOC full)
Model(:,:,60) = Model(:,:,15) + Model(:,:,39);
% Model 61 (top-down and self-inhibitory, V3-LOC full)
Model(:,:,61) = Model(:,:,16) + Model(:,:,40);
% Model 62 (top-down and self-inhibitory, V4-LOC full)
Model(:,:,62) = Model(:,:,17) + Model(:,:,41);
% Model 63 (top-down and self-inhibitory, V1-V4 full)
Model(:,:,63) = Model(:,:,18) + Model(:,:,43);
% Model 64 (top-down and self-inhibitory, V1-V3 full)
Model(:,:,64) = Model(:,:,19) + Model(:,:,44);
% Model 65 (top-down and self-inhibitory, V1-V2 full)
Model(:,:,65) = Model(:,:,20) + Model(:,:,45);
% Model 66 (top-down and self-inhibitory, V1-LOC)
Model(:,:,66) = Model(:,:,21) + Model(:,:,38);
% Model 67 (top-down and self-inhibitory, V2-LOC)
Model(:,:,67) = Model(:,:,22) + Model(:,:,39);
% Model 68 (top-down and self-inhibitory, V3-LOC)
Model(:,:,68) = Model(:,:,23) + Model(:,:,40);
% Model 69 (top-down and self-inhibitory, V1-V4)
Model(:,:,69) = Model(:,:,24) + Model(:,:,43);
% Model 70 (top-down and self-inhibitory, V1-V3)
Model(:,:,70) = Model(:,:,25) + Model(:,:,44);
%% Recurrent + self-inhibitory
% Model 71 (recurrent and self-inhibitory, V2-LOC full)
Model(:,:,71) = Model(:,:,27) + Model(:,:,39);
% Model 72 (recurrent and self-inhibitory, V3-LOC full)
Model(:,:,72) = Model(:,:,28) + Model(:,:,40);
% Model 73 (recurrent and self-inhibitory, V4-LOC full)
Model(:,:,73) = Model(:,:,29) + Model(:,:,41);
% Model 74 (recurrent and self-inhibitory, V1-V4 full)
Model(:,:,74) = Model(:,:,30) + Model(:,:,43);
% Model 75 (recurrent and self-inhibitory, V1-V3 full)
Model(:,:,75) = Model(:,:,31) + Model(:,:,44);
% Model 76 (recurrent and self-inhibitory, V1-V2 full)
Model(:,:,76) = Model(:,:,32) + Model(:,:,45);
% Model 77 (recurrent and self-inhibitory, V1-LOC)
Model(:,:,77) = Model(:,:,33) + Model(:,:,38);
% Model 78 (recurrent and self-inhibitory, V2-LOC)
Model(:,:,78) = Model(:,:,34) + Model(:,:,39);
% Model 79 (recurrent and self-inhibitory, V3-LOC)
Model(:,:,79) = Model(:,:,35) + Model(:,:,40);
% Model 80 (recurrent and self-inhibitory, V1-V4)
Model(:,:,80) = Model(:,:,36) + Model(:,:,43);
% Model 81 (recurrent and self-inhibitory, V1-V3)
Model(:,:,81) = Model(:,:,37) + Model(:,:,44);
%% No modulations
% Model 82 (no modulation)            
Model(:,:,82) = [0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0;
                0 0 0 0 0];