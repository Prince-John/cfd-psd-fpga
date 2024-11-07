# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Python script to analyze CFD walk characteristics
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

import sys
import os
import shutil

import numpy as np
import matplotlib.pyplot as plt
import scienceplots

from pathlib import Path
from pypdf import PdfWriter

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# Create class to hold misc parameters of the sim
#
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class globInfo :
    def __init__(self):
        self.filename = ''
        self.dataDir = ''
        self.pdfDir = ''
        self.mergedPDFname = ''
        self.minAmp = 0
        self.maxAmp = 999
        self.tau_r = 0
        self.tau_f = 0
        self.dac = 0
        self.plot_xloc = 0
        self.plot_yloc = 0

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Create class to hold results from a single
# simulation run
#
# Line format:
# index amp t0 t_zc tpd le_time zc_delay
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class cfdData :
    def __init__(self, run_num):
        self.run_num = run_num
        self.index = []
        self.amp = []
        self.t0 = []
        self.t_zc = []
        self.tpd = []
        self.le_time = []
        self.zc_delay = []
        self.walk = 999
        self.polarity = 1
        self.plotFilename = ''
    
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@               
# Method to compute average delay
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    def aveDelay(self) :
        average = sum(self.tpd) / len(self.tpd)
        return average
    
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Method to compute walk associated with a run
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    def calcWalk(self) :
        found_min_amp_index = False
        found_max_amp_index = False

# Create array of values for interested range

        for index, amp in enumerate(self.amp) :
            if ((not found_min_amp_index) & (amp >= info.min_amp)) :
                min_index = index
                found_min_amp_index = True
            if ((not found_max_amp_index) & (amp >= info.max_amp)) :
                max_index = index
                found_max_amp_index = True

# Compute walk over specified range in ps (1 digit to right of decimal point)

        tpd = self.tpd[min_index : max_index]
        self.walk = max(tpd) - min(tpd)
        self.walk = round(1e12 * self.walk, 1)

        return

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Method to produce walk plot
# Pass in a string to print on plot
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    def plotWalk(self, string) :
        x = []
        y = []
        
# Convert volts to mV

        for val in self.amp :
            val *= 1e3
            x.append(val)

# Compute average propagation delay for run
 
        tpd_ave = self.aveDelay()
        
# Want delay relative to average dealy in ps

        for val in self.tpd  :
            val = val - tpd_ave
            val *= 1e12
            y.append(val)
            
        fig, ax = plt.subplots()
        ax.plot(x, y, color='red', marker='o')

# Axes and titles

        ax.set_title("Delay As Function of Pulse Amplitude")
        ax.set_xlabel("Pulse Amplitude (mV)")
        ax.set_ylabel("Delay Relative to Average Delay (ps)")
        ax.set_xscale('log')
        ax.text(info.plot_xloc, info.plot_yloc, string)

# Save as a PDF

        plotFilename = Path(info.filename).stem + '_' + str(self.run_num) + '.pdf'
        plt.savefig(info.pdfDir + '/' + plotFilename)
        plt.close()

# Return the file name

        return plotFilename

# ==============================================================

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# 
# Function to print out simulation parameters
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def plotWalkSummary() :
    x = []
    y = []

# Plot run number on x-axis and walk on y

    for run in runs :
        x.append(run.run_num)
        y.append(run.walk)

    fig, ax = plt.subplots()
    ax.plot(x, y, color='blue', marker='o')

# Axes and titles

    ax.set_title("Walk as Function of Monte Carlo Run")
    ax.set_xlabel("Run Number")
    ax.set_ylabel("Walk (ps)")

# Save as a PDF

    plotFilename = Path(info.filename).stem + '_summary.pdf'
    plt.savefig(info.pdfDir + '/' + plotFilename)
    plt.close()
    return plotFilename
     
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# 
# Function to print out simulation parameters
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def getSimParms(line) :
    line_as_list = line.split("\t")
    info.tau_r = float(line_as_list[0])
#    print(info.tau_r)
    info.tau_f = float(line_as_list[1])
#    print(info.tau_f)
    if (len(line_as_list) == 7) :
        info.dac = int(line_as_list[6])
    return

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   Routine to read walk data from file
#   Returns a list of monte carlo runs
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def readDataFile() :
    
    firstLine = True 
    run_num = -1
    runs = []

# Similar to C 'defines to make code easier to understand

    INDEX = 0
    AMP = 1
    T0 = 2
    T_ZC = 3
    TPD = 4
    LE_TIME = 5
    ZC_DELAY = 6

# Prepend directory name to the user supplied filename

    readFile = info.dataDir + '/' + info.filename

# Open up the file for reading

    try:
        fid = open(readFile)
        print("Opened file named: ", readFile)
    except:
        print('File NOT found and cannot be opened:', readFile)
        exit()
    
# Start reading lines from the CFD data file

    for line in fid :
        
# First line of file is our record delimiter

        if (firstLine) :
            record_delimiter = line
            getSimParms(record_delimiter)
            firstLine = False

# Each time we encounter the record delimiter line we have
# a new Monte Carlo run starting and we need to add a run to our runs list!

        if (line == record_delimiter) :
            run_num += 1
            runs.append(cfdData(run_num))
        
# If not a record delimiter line then parse the line containing data

        if (line != record_delimiter) :
            line_as_list = line.split("\t")
            runs[run_num].index.append(int(line_as_list[INDEX]))
            amplitude = float(line_as_list[AMP])
            if (amplitude < 0) :
                runs[run_num].polarity = -1
                amplitude *= -1.0
            runs[run_num].amp.append(amplitude)
            runs[run_num].tpd.append(float(line_as_list[TPD]))
            runs[run_num].le_time.append(float(line_as_list[LE_TIME]))
            runs[run_num].zc_delay.append(float(line_as_list[ZC_DELAY]))

# Finished reading the entire file so close the file!

    fid.close()
       
    return runs

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Create a walk plot for each of the runs
# We can pass in a string of our chossing
# Merge all of the plots into single PDF
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

def createMergedWalkPDF() :

# Create a dirctory to store our pdf files
# If directory already exists delete it 

    info.pdfDir = info.dataDir +'/' + Path(info.filename).stem
    if (os.path.exists(info.pdfDir)) :
        shutil.rmtree(info.pdfDir)
    os.mkdir(info.pdfDir)

# Create a bunch of plots as PDFs
# Save them to the pdfDir directory

    pdf_list = []
    for run in runs :

# Create annotation for plot

        Str = 'Run Number: ' + str(run.run_num) + '\n'
        if (run.polarity == 1) :
            Str = Str + 'Polarity: pos\n'
        else :
            Str = Str + 'Polarity: neg\n'
        Str =  Str + 'Rise Tau: ' + str(info.tau_r) + '\n'
        Str = Str + 'Fall Tau: ' + str(info.tau_f) + '\n'
        Str = Str + 'Walk: ' + str(run.walk) + ' ps'

# Create the walk plot for the run and add pdf file name to list

        run.plotFilename = run.plotWalk(Str)       
        pdf_list.append(info.pdfDir + '/' + run.plotFilename)

# Create a summary walk plot

    filename = plotWalkSummary()
    pdf_list.append(info.pdfDir + '/' + filename)
    
# Merge walk PDFs into a single PDF

    merger = PdfWriter()
    for pdf in pdf_list :
        merger.append(pdf)
    mergedPdfFile = info.pdfDir + '/' + info.mergedPDFname
    merger.write(mergedPdfFile)
    merger.close()
    return

# ==============================================================

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  MAIN PROGRAM
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

if __name__ == '__main__':

# Define an object to hold global information

    info = globInfo()
    
# Directory where the .dat files can be found

    info.dataDir = './dat'
    
# Get filename for data from command line

    if (len(sys.argv) == 2) :
       info.filename = sys.argv[1]
    else:
        print("Usage: walk filename_to_process")
        exit(1)
    
# Read the data for all of the runs

    runs = readDataFile()
#    print("Number of runs: ", len(runs))

# Compute the walk for each run

    info.min_amp = 10e-3
    info.max_amp = 1.4
    
    for run in runs :
        run.calcWalk()

# Use 'scienceplots' to produce IEEE publishable quality figures

    plt.style.use(['science', 'no-latex', 'grid'])

# Specify where the annotation should be placed on the plots

    info.plot_xloc = 100
    info.plot_yloc = 200

# Create a pdf of walk plots and merge them into single PDF

    info.mergedPDFname = 'merged-walk-plots.pdf'
    createMergedWalkPDF()
