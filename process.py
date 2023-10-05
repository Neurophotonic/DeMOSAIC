
import argparse

from utils.DIP import Image40_1
from utils.unmix import unmix
import numpy as np
import tifffile as tiff
import matplotlib.pyplot as plt


#argument parsing

parser = argparse.ArgumentParser(description='Original image, Dark image(for backgroound), Original ratios')
parser.add_argument('--src_path', required=True, type = str, help='path of image to be processed')
parser.add_argument('--dark_path', required=False, help='path of dark image to be processed')
parser.add_argument('--new_name', required=False, help='new file name ****.tif')
parser.add_argument('--ratio_path', required=False, type = str, help='path of ratio')
parser.add_argument('--tune', required=False, action="store_true")


args = parser.parse_args()



print("\nloading image!")

IMG = tiff.imread(args.src_path) #image
Frames = IMG.shape[0]

print("\nloaded image!")

if args.ratio_path == None:
    P = np.genfromtxt("ratio/MatP3.csv", dtype='float', delimiter=",")
else: 
    P = np.genfromtxt(args.ratio_path, dtype='float', delimiter=",")

print("\nloaded ratio!")

if args.new_name == None:
    new_name = args.src_path.rstrip(".tif")+ "_unmixed.tif"
else: 
    new_name = args.new_name

print("\nyour file will be saved as " + new_name)

if args.dark_path == None:
    bgn = np.min(IMG)
    Dark = np.ones((IMG.shape[1], IMG.shape[2]), dtype = 'int32') * bgn
else:
    Dark = tiff.imread(args.dark_path) # dark

print("\nDefined Dark")

if args.tune == True:
    img = Image40_1(IMG[int(Frames/2), :, :], P, Dark)
    print("\ninitial loss:", img.loss())
    img.Sfinetune()
    print("\nadjusted loss:", img.loss())

    np.savetxt(args.src_path.rstrip(".tif")+"ratio.csv", P, delimiter=',')

    adjP = img.P

else:
    adjP = P

print("\nDefined ratio!")
print("\nUNMIXING")
unmix(IMG, new_name, Dark, adjP)


