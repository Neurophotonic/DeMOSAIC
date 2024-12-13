function varargout = BlueDMDTform
addpath(genpath('D:\Sean NAS\DemOSAIC Project\Matlab code\Pattern generation\images'));

% Load the reference image.
DMDinput_filename = uigetfile('*.*', 'Select DMD input(reference) pattern image.');
DMDinput = imread(DMDinput_filename);

if size(DMDinput,3)==3
    DMDinput = rgb2gray(DMDinput);
end

% Load the widefield image.
Widefield_filename = uigetfile('*.*', 'Select DMD pattern_image(tif) on direct port camera.');
Widefield = imread(Widefield_filename);

if size(Widefield,3)==3
    Widefield = rgb2gray(Widefield);
end


% Set parameters for image contrast-based registration.
[optimizer, metric] = imregconfig('multimodal');
optimizer.GrowthFactor = 1.01;
optimizer.Epsilon = 1.5e-4;
optimizer.InitialRadius = 1e-4;
optimizer.MaximumIterations = 300;

% point-to-point transform
% Repeat the registration until quality is okay.
while true
% GUI-based point selection and return reference point(fxp) and moved point(mvp).
    [mvp, fxp] = cpselect(Widefield, DMDinput, 'wait', true); 

    % Find transform matrix using point information
    tform_BlueDMD_Widefield = fitgeotrans(mvp, fxp, 'similarity');

    % Apply transform matrix
    Widefield_tr = imwarp(Widefield, tform_BlueDMD_Widefield, 'Outputview', imref2d(size(DMDinput)));

    DMDinput = int8(DMDinput);
    % 2nd registration for fine tuning.(Image contrast-based registration)
    tform_BlueDMD_Widefield2 = imregtform(Widefield_tr, DMDinput, 'affine', optimizer, metric);
    Widefield_tr2 = imwarp(Widefield_tr, tform_BlueDMD_Widefield2, 'Outputview', imref2d(size(DMDinput)));

    % Show merge images (recovered widefield image and reference image).
    f1= figure; imshowpair(Widefield_tr2, DMDinput);
% Check the registration quality is okay. If not, return to line 16.
    Check = questdlg('Retry?', 'Result', 'Yes', 'No', 'No');
    close(f1);
    if strcmpi(Check, 'No')
        break
    end
end
varargout{1} = tform_BlueDMD_Widefield;
varargout{2} = tform_BlueDMD_Widefield2;

save tform_BlueDMD_Widefield.mat tform_BlueDMD_Widefield tform_BlueDMD_Widefield2
close all;
end