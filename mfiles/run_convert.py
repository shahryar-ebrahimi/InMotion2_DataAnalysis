#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 15:43:28 2021

@author: shahryar
"""

import scipy.io
import pickle
import os

cwd = os.getcwd()
rootdir = cwd + '/../data' 

for rootdir, dirs, files in os.walk(rootdir):
    for subdir in dirs:
        directory = os.path.join(rootdir, subdir)
        for file in os.listdir(directory):
            if file.endswith(".pickle"):
                source = os.path.join(directory, file)
                dest   = source.replace(".pickle", ".mat")
                a = pickle.load(open(source, "rb" ) )
                scipy.io.savemat(dest, mdict={'pickle_data': a})
                
                
                
print("Data successfully converted to .mat files with variables ending \".pickle\"")
     
        