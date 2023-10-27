# DeMOSAIC tools

# 1. Patterned Illumiation
This matlab code is designed for patterned illumition (updating)

# 2. Unmixing module
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

## Environment
The Python code was tested on Windows 10 using Anaconda3. The required libraries and packages are listed in requirements.txt.

# 3. Postprocessing tools
We provide Jupyter Notebooks for additional analyses after unmixing. These include 

1. DFF_and_Detrend.ipynb
extraction of DF/F0, detrending
2. STA.ipynb
and spike-triggered averaging (STA)
