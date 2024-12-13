clear all
addpath(genpath('D:\Sean NAS\DemOSAIC Project\Matlab code\Pattern generation\images'));
addpath(genpath('D:\DeMOSAIC share\Grid\Patterns'))
load('tform_RedDMD_Widefield.mat');
load('tform_BlueDMD_Widefield.mat');
load('tform_SLM.mat');

DMD_size = [1600 2560];
SLM_size = [1152 1920];

% Load ROI tiff image
[filename, folder] = uigetfile('*.tif;*.png;*.bmp', 'Select ROI image','~/images');
uigetpath=folder;

roi = imread(filename);
% roi = rgb2gray(roi);
% roi = imbinarize(roi);

% Widefield to RedDMD transform
roi_tr1 = imwarp(roi, tform_RedDMD_Widefield, 'OutputView', imref2d(DMD_size));
roi_tr2 = imwarp(roi_tr1, tform_RedDMD_Widefield2, 'OutputView', imref2d(DMD_size));

% Inverse RedDMD and Save
roi_tr2_Inverse = BWReverse(roi_tr2);
roi_tr2_name = fullfile(uigetpath, gen_FileName('RedDMD_ROI_pattern'));
imwrite(roi_tr2_Inverse,roi_tr2_name);

% DMD to SLM transform
SLM = imwarp(roi_tr2, tform_SLM, 'OutputView', imref2d(SLM_size));

% Watershed ROI option
% SLM_pat = SLMpatGen_Sean(SLM, uigetpath);
SLM_pat = SLMpatGen_Watershed(SLM, uigetpath);

SLM_pat_flip = flipud(SLM_pat);
SLM_pattern_filename = fullfile(uigetpath, gen_FileName('SLM.png'));
SLM_pattern_flip_filename = fullfile(uigetpath, gen_FileName('Flip_SLM.png'));
imwrite(SLM_pat, SLM_pattern_filename);
imwrite(SLM_pat_flip, SLM_pattern_flip_filename);


% Widefield to BlueDMD transform
while true
    selection = BlueDMD_Selection(roi);
    roi_tr3 = imwarp(selection, tform_BlueDMD_Widefield, 'OutputView', imref2d(DMD_size));
    roi_tr4 = imwarp(roi_tr3, tform_BlueDMD_Widefield2, 'OutputView', imref2d(DMD_size));
    roi_tr4_name = fullfile(uigetpath, gen_FileName('Optostim'));
    imwrite(roi_tr4,roi_tr4_name);
    
promptMessage = sprintf('Continue to select stim? Finish?');
button = questdlg(promptMessage, 'Continue', 'Continue', 'Finish', 'Continue'); 
if strcmp(button, 'Finish')
  break % return or break or whatever...
end
end

