import tifffile as tiff
import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations



import tifffile as tiff
import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


class Image40_1:
    
    def __init__(self, img, P, dark):
        #img : img to be processed
        #P : initial ratio table
        #dark : dark image(for background process)
        
        self.dark = dark
        self.img = img - dark
        self.P = P

        if (self.img.shape != (3,120)):
            print("invalid image!")
        
        k = np.zeros([9,1,40])
        k[0,:,:] = self.img[2,0:40]
        k[1,:,:] = self.img[2,40:80]
        k[2,:,:] = self.img[2,80:120]
        k[3,:,:] = self.img[1,0:40]
        k[4,:,:] = self.img[1,40:80]
        k[5,:,:] = self.img[1,80:120]
        k[6,:,:] = self.img[0,0:40]
        k[7,:,:] = self.img[0,40:80]
        k[8,:,:] = self.img[0,80:120]
        
        self.stack = k
        
        #split ROIs into stack and is self.stack
        
    def seedmat(self, par):
       
        Mat = np.array(
            [[1. , 1+par, 1+par],
             [1. , 1+par, 1. ],
             [1. , 1+par, 1-par],
             [1. , 1. , 1+par],
             [1. , 1. , 1-par],
             [1. , 1-par, 1+par],
             [1. , 1-par, 1. ],
             [1. , 1-par, 1-par]]
        )
        return Mat
        
        #seed matrix for fine-tune of ratios
    
        
    def p(self, i,j):  
        #i = channel #
        #j = 1(1), 2(0), 3(-1)  
        
        return (self.P[i-1,j-1])/(self.P[i-1,0]+self.P[i-1,1]+self.P[i-1,2])
        
    def uROI(self,i):
        
        #unprocessed ROI
        
        return (self.stack[i-1,:])
    
    def ROI(self, i):
        
        #processed ROI
        
        upper = self.uROI(i) - (self.p(10-i,3) / self.p(10-i, 1)) * self.uROI(10-i)
        lower = self.p(i,1) - self.p(10-i, 3) * self.p(i,3) / self.p(10-i, 1)
        return (upper / lower).astype('int32')
    
    def ROI5(self):
        
        #processed ROI5
        
        t = self.uROI(5)
        for i in ([1,2,3,4,6,7,8,9]):
            t = t - self.p(i,2) * self.ROI(i)
        return t.astype('int32')
        
    def processed(self):
        
        #integrate processed ROIs
        
        new = np.block([
            [self.ROI(7), self.ROI(8), self.ROI(9)],
            [self.ROI(4), self.ROI5(), self.ROI(6)],
            [self.ROI(1), self.ROI(2), self.ROI(3)]
        ])
        return new
    
        ###process messy image session
    def bROI(self, i):
        
        bROI = self.p(i,1) * self.uROI(i) + self.p(10-i,3) * self.uROI(10-i)
        return bROI
        
       
    def bROI5(self):       
        bROI = np.zeros((1,40))
        for s in ([1,2,3,4,6,7,8,9]):
            bROI = bROI + self.p(s,2) * self.uROI(s)
        return bROI
    
    def backprocessed(self):
        old = np.block([
            [self.bROI(7), self.bROI(8), self.bROI(9)],
            [self.bROI(4), self.bROI5(), self.bROI(6)],
            [self.bROI(1), self.bROI(2), self.bROI(3)]
        ])
        return old
    
    def loss(self):
        
        #MSE(ROI5) : lower the better
        
        standard = np.zeros((self.ROI5().shape))
        loss = (np.abs(self.ROI5() - standard)).mean(axis=None)
        return loss
    
    def finetune(self, par):
        
        #do fine tune by ratio. two output
        
        comb = list(permutations(range(0,8), 8))
        L = len(comb)
        minloss = self.loss()
        ori_P = self.P
        opt_par = self.P
        
        
        for k in range(len(comb)):
            coeffmat = np.array([
                        self.seedmat(par)[(comb[k][0]),:],
                        self.seedmat(par)[(comb[k][1]),:],
                        self.seedmat(par)[(comb[k][2]),:],
                        self.seedmat(par)[(comb[k][3]),:],
                        [0,0,0],
                        self.seedmat(par)[(comb[k][4]),:],
                        self.seedmat(par)[(comb[k][5]),:],
                        self.seedmat(par)[(comb[k][6]),:],
                        self.seedmat(par)[(comb[k][7]),:]
            ])

            newP = np.multiply(ori_P, coeffmat)
            
            self.P = newP

            sl = self.loss()
            
            if k%10000 == 0:
                print("tuning", int((k/L)*100), "%")

            if sl < minloss:
                minloss = sl
                opt_par = newP
            
        self.P = opt_par
          
            
        return minloss, opt_par
    
    def Sfinetune(self):
        for par in list([0.5,0.4,0.3,0.2,0.1]):
            print("fine tuning with par : ", par) 
            self.finetune(par)

class Image40:
    
    def __init__(self, img, P, dark):
        #img : img to be processed
        #P : initial ratio table
        #dark : dark image(for background process)
        
        self.dark = dark
        self.img = img - dark
        self.P = P
        
        k = np.zeros([9,40,40])
        k[0,:,:] = self.img[80:120,0:40]
        k[1,:,:] = self.img[80:120,41:81]
        k[2,:,:] = self.img[80:120,80:120]
        k[3,:,:] = self.img[40:80,0:40]
        k[4,:,:] = self.img[40:80,40:80]
        k[5,:,:] = self.img[40:80,80:120]
        k[6,:,:] = self.img[0:40,0:40]
        k[7,:,:] = self.img[0:40,40:80]
        k[8,:,:] = self.img[0:40,80:120]
        
        self.stack = k
        
        #split ROIs into stack and is self.stack
        
    def seedmat(self, par):
       
        Mat = np.array(
            [[1. , 1+par, 1+par],
             [1. , 1+par, 1. ],
             [1. , 1+par, 1-par],
             [1. , 1. , 1+par],
             [1. , 1. , 1-par],
             [1. , 1-par, 1+par],
             [1. , 1-par, 1. ],
             [1. , 1-par, 1-par]]
        )
        return Mat
        
        #seed matrix for fine-tune of ratios
    
        
    def p(self, i,j):  
        #i = channel #
        #j = 1(1), 2(0), 3(-1)  
        
        return (self.P[i-1,j-1])/(self.P[i-1,0]+self.P[i-1,1]+self.P[i-1,2])
        
    def uROI(self,i):
        
        #unprocessed ROI
        
        return (self.stack[i-1,:])
    
    def ROI(self, i):
        
        #processed ROI
        
        upper = self.uROI(i) - (self.p(10-i,3) / self.p(10-i, 1)) * self.uROI(10-i)
        lower = self.p(i,1) - self.p(10-i, 3) * self.p(i,3) / self.p(10-i, 1)
        return (upper / lower).astype('int32')
    
    def ROI5(self):
        
        #processed ROI5
        
        t = self.uROI(5)
        for i in ([1,2,3,4,6,7,8,9]):
            t = t - self.p(i,2) * self.ROI(i)
        return t.astype('int32')
        
    def processed(self):
        
        #integrate processed ROIs
        
        new = np.block([
            [self.ROI(7), self.ROI(8), self.ROI(9)],
            [self.ROI(4), self.ROI5(), self.ROI(6)],
            [self.ROI(1), self.ROI(2), self.ROI(3)]
        ])
        return new
    
    def bROI(self, i):
        
        bROI = self.p(i,1) * self.uROI(i) + self.p(10-i,3) * self.uROI(10-i)
        return bROI
        
       
    def bROI5(self):       
        bROI = np.zeros((40,40))
        for s in ([1,2,3,4,6,7,8,9]):
            bROI = bROI + self.p(s,2) * self.uROI(s)
        return bROI
    
    def backprocessed(self):
        old = np.block([
            [self.bROI(7), self.bROI(8), self.bROI(9)],
            [self.bROI(4), self.bROI5(), self.bROI(6)],
            [self.bROI(1), self.bROI(2), self.bROI(3)]
        ])
        return old
    
    def loss(self):
        
        #MSE(ROI5) : lower the better
        
        standard = np.zeros((self.ROI5().shape))
        loss = ((self.ROI5() - standard)**2).mean(axis=None)
        return loss
    
    def finetune(self, par):
        
        #do fine tune by ratio. two output
        
        comb = list(permutations(range(0,8), 8))
        L = len(comb)
        minloss = self.loss()
        ori_P = self.P
        opt_par = self.P
        
        
        for k in range(len(comb)):
            coeffmat = np.array([
                        self.seedmat(par)[(comb[k][0]),:],
                        self.seedmat(par)[(comb[k][1]),:],
                        self.seedmat(par)[(comb[k][2]),:],
                        self.seedmat(par)[(comb[k][3]),:],
                        [0,0,0],
                        self.seedmat(par)[(comb[k][4]),:],
                        self.seedmat(par)[(comb[k][5]),:],
                        self.seedmat(par)[(comb[k][6]),:],
                        self.seedmat(par)[(comb[k][7]),:]
            ])

            newP = np.multiply(ori_P, coeffmat)
            
            self.P = newP

            sl = self.loss()
            
            if k%10000 == 0:
                print("tuning", int((k/L)*100), "%")

            if sl < minloss:
                minloss = sl
                opt_par = newP
            
        self.P = opt_par
          
            
        return minloss, opt_par
    
    def Sfinetune(self):
        for par in list([0.5,0.4,0.3,0.2,0.1]):
            print("fine tuning with par : ", par) 
            self.finetune(par)
