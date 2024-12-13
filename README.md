# DeMOSAIC tools

# System Requirements
## Hardware requirements
A standard computer with enough RAM to support the in-memory operations is needed.
## Software requirements
The Python code was tested on Windows 11 and MacOS(Sequoia 15.1.1) using Anaconda3 with python 3.12.2. The required libraries and packages are listed in requirements.txt.
The Matlab code was tested on Windows 11 using Matlab R2023a.
## Installation Guide
Simply download Anaconda3 and Matlab, and you are good to go. This would take 10-15 minutes in total.

# 1. Optical segmentation and patterned illumination
## 1.1 Coregistration
Matlab codes for coregistration between image plane and DMD, SLM plane. Run each Transform code, and you will need to select two images. First select the DMD input image, and next select the output image (The image you took). Coregistrate the two by selecting corresponding points of the two image. Retry if coregistration is unsatisfactory.

## 1.2. Pattern_generation
Matlab codes for making SLM optical segmentation pattern from user-selected ROIs. The input is always a binary tiff file of the user-selected ROIs. Patterned_illumination.m only generates the image for DMD input. ROI_pattern.m generates both the DMD input, SLM input, and an optional image for the optostimulation DMD if necessary. ROI_Pattern_watershed.m generates a watershed pattern of the input ROIs. ROI_Pattern_multiple.m generates the DMD images containing individual ROIs one by one. ROI_expand.m returns an expanded ROI.

# 2. Unmixing module (python)
This module is designed for unmixing images detected by DeMOSAIC (Diffractive Multisite Optical Segmentation Assisted Image Compression). It accomplishes the following tasks:

1. Splits the image of the detection channel.
2. Unmixes the signal with its complementary channel.
3. Re-stitches the image to form the final output.

<Example with colored, 128x128 image>

![befor process](/img/TEST_MIXED_uint8.png) to ![after process](/img/TEST_DEMIXED_uint8.png)

## To run
  
  ```
  python unmixing.py --src_path C:/.../raw_image.tiff --ratio_path C:/.../ratio.csv --dark_path(optional) C:/.../dark.tiff 
  --new_name newfilename.tiff --tune(optional)
  ```
Running the code might require additional libraries. The libaries are stated in the requirements.txt

All files for demonstartion are in the demo folder.

# 3. Postprocessing tools
We provide Jupyter Notebooks for additional analyses after unmixing. These include 

1. DFF_and_Detrend.ipynb
extraction of DF/F0, detrending
2. STA.ipynb
and spike-triggered averaging (STA)
