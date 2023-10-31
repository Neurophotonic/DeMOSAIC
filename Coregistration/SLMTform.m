function varargout = SLMTform
addpath(genpath('D:\Sean NAS\DemOSAIC Project\Matlab code\Pattern generation\images'));

% Load the DMD input pattern (*.png, 32-bit) image and SLM surface image.
DMDinput_filename = uigetfile('*.*', 'Select DMD input(reference) image(*.png).');
SLM_filename = uigetfile('*.*', 'Select SLM surface image.');
DMDinput = imread(DMDinput_filename);
SLM = imread(SLM_filename);

if size(DMDinput,3)==3
    DMDinput = rgb2gray(DMDinput);
end


if size(SLM,3)==3
    SLM = rgb2gray(SLM);
end



% Registration for checking SLM active area.
% Repeat the registration until quality is okay.
while true
    % GUI-based point selection and return fixed point(fxp) and moving point(mvp).
    [mvp, fxp] = cpselect(SLM, DMDinput, 'Wait', true);
    
    % Find transform matrix using point information
    tform1 = fitgeotrans(mvp, fxp, 'similarity');
    
    % Apply transform matrix
    SLM_tr = imwarp(SLM, tform1, 'OutputView', imref2d(size(DMDinput)));

    % Set parameters for image contrast-based registration
    [optimizer, metric] = imregconfig('multimodal');
    optimizer.GrowthFactor = 1.01;
    optimizer.Epsilon = 1.5e-4;
    optimizer.InitialRadius = 1e-4;
    optimizer.MaximumIterations = 300;

    % 2nd registration for fine tuning. (image contrast-based registration)
    tform2 = imregtform(SLM_tr, DMDinput, 'affine', optimizer, metric);
    SLM_tr2 = imwarp(SLM_tr, tform2, 'OutputView', imref2d(size(DMDinput)));
    f1 = figure; imshowpair(SLM_tr2, DMDinput);

    % Check the registration quality is okay. If not, return to line 16.
    Check = questdlg('Retry?', 'Result', 'Yes', 'No', 'No');
    close(f1);
    if strcmpi(Check, 'No')
        break
    end
end
close all;


%% Find transform matrix to make correspond DMD input to SLM
% Repeat the process until transform quality is okay.
while true
    % Set initial parameter for GUI-based point selection.
    initial_mvp = fix(bsxfun(@rdivide, [2560 1600], [3 3; 3 1.5; 1.5 3; 1.5 1.5]));
    initial_fxp = [1 1; 1 1600; 2560 1; 2560 1600];
    
    % GUI-based point selection and return the four edge of SLM boundary.
    [mvp2, ~] = cpselect(SLM_tr2, DMDinput, initial_mvp, initial_fxp, 'Wait', true);
    fxp2 = [1 1; 1 1152; 1920 1; 1920 1152];

    % Find transform matrix and apply.
    tform_SLM = fitgeotrans(mvp2, fxp2, 'similarity');
    SLM_final = imwarp(SLM_tr2, tform_SLM, 'Outputview', imref2d([1152 1920]));
    f2 = figure; imshow(SLM_final);
    
    % Check the registration quality is okay. If not, return to line 50.
    Check2 = questdlg('Retry?', 'Result', 'Yes', 'No', 'No');
    close(f2);
    if strcmpi(Check2, 'No')
        break
    end
end

varargout{1} = tform1;
varargout{2} = tform2;
varargout{3} = tform_SLM;

save tform_SLM.mat tform_SLM
end