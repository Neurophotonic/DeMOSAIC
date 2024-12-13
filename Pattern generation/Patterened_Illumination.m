clear all
addpath(genpath('D:\DeMOSAIC share\Grid\Patterns'))
load('tform_RedDMD_Widefield.mat');
load('tform_BlueDMD_Widefield.mat');

DMD_size = [1600 2560];

% Load ROI tiff image
[filename, folder] = uigetfile('*.tif;*.png;*.bmp', 'Select ROI image','~/images');
uigetpath=folder;

roi = imread(filename);
% roi = rgb2gray(roi);
% roi = imbinarize(roi);

% ROI to RedDMD transform
roi_tr1 = imwarp(roi, tform_RedDMD_Widefield, 'OutputView', imref2d(DMD_size));
roi_tr2 = imwarp(roi_tr1, tform_RedDMD_Widefield2, 'OutputView', imref2d(DMD_size));

% Inverse RedDMD and Save
roi_tr2_Inverse = BWReverse(roi_tr2);
roi_tr2_name = fullfile(uigetpath, gen_FileName('RedDMD_ROI_pattern'));
imwrite(roi_tr2_Inverse,roi_tr2_name);


% ROI to BlueDMD transform
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

