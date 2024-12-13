
clear all
addpath(genpath('D:\Sean NAS\DemOSAIC Project\Matlab code\Pattern generation\images'));

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

% Widefield to BlueDMD transform
roi_tr3 = imwarp(roi, tform_BlueDMD_Widefield, 'OutputView', imref2d(DMD_size));
roi_tr4 = imwarp(roi_tr3, tform_BlueDMD_Widefield2, 'OutputView', imref2d(DMD_size));

% Inverse BlueDMD and Save
roi_tr4_Inverse = BWReverse(roi_tr4);
roi_tr4_name = fullfile(uigetpath, gen_FileName('Optostim'));
imwrite(roi_tr4_Inverse,roi_tr4_name);



% Label the binary image
[L, num] = bwlabel(roi_tr2);  % For RedDMD
[L_blue, num_blue] = bwlabel(roi_tr4);  % For BlueDMD

% Loop through each RedDMD ROI and save as separate PNG
for i = 1:num
    % Create a binary mask for the current ROI
    roi_individual = (L == i);
    
    % Inverse the binary mask (if needed) and save
    roi_individual_inverse = BWReverse(roi_individual);
    
    % Generate the file name for each ROI
    roi_filename = fullfile(uigetpath, sprintf('RedDMD_ROI_%d.png', i));
    
    % Save the individual ROI pattern
    imwrite(roi_individual_inverse, roi_filename);
end

% Loop through each BlueDMD ROI and save as separate PNG
for i = 1:num_blue
    % Create a binary mask for the current ROI
    roi_individual_blue = (L_blue == i);
    
    % Inverse the binary mask (if needed) and save
    roi_individual_blue_inverse = BWReverse(roi_individual_blue);

    % Generate the file name for each BlueDMD ROI
    roi_blue_filename = fullfile(uigetpath, sprintf('BlueDMD_ROI_%d.png', i));
    
    % Save the individual BlueDMD ROI pattern
    imwrite(roi_individual_blue_inverse, roi_blue_filename);
end


