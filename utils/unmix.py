import numpy as np
import tifffile as tiff
from utils.DIP import Image40

from utils.DIP import Image40_1


def unmix(image, filename, dark, P):
    frames = image.shape[0]

    a = np.zeros((frames, 3, 120), dtype='int32')

    for i in range(0, frames):

        k = Image40_1(image[i, :, :], P, dark)

        a[i, :, :] = k.processed()

        if i % 10000 == 0:
            print("processing", i, "th frame...")

    tiff.imsave(filename, a)
    print(a.dtype)

    print("=" * 50)
    print("done!")
