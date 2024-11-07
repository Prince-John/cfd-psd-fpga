#!/usr/bin/octave -qf

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% This Octave script will analyze a file containing the results of a 
% monte carlo (MC) analysis.
%
% This script should be called with single argument.
%
% The script will produce a series of walk plots, one for each MC run
%
% example usage (where the single argument is the PID)
%
% walk 11313
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ################################
% Read in data from veriloga file
% Store in data matrix
% ################################
graphics_toolkit("gnuplot")

arg_list = argv () ;
pid_num = arg_list{1} ;

filename = ['./results/le_thresh_'  pid_num  '.dat'] ;
fid = fopen(filename, 'rt') ; 

% Read the file into the data matrix

data = fscanf(fid, "%f\n");

% Close the file up .. we are done with it

fclose(fid) ;

% Determine the length of the first column

n = length(data) ;

% ******************************************************


% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%
% Create a plot which summarizes performance
%
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

% Create the summary walk plot

    h_summary = figure('name', 'Summary Walk Plot', 'numbertitle', 'off', 'visible', 'off') ;

    plot(1:1:n, abs(1e3*data), 'r.', 'MarkerSize', 25) ;
	set(gca, "fontsize", 18);
    %axis([0 n+1 0 max(abs(amp))*1.25]) ;
	xlim([0 n+1]);
    hold on ;
    grid on ;
    xlabel('Monte Carlo Run Number', "fontsize", 16) ;
    ylabel('Threshold (mV)', "fontsize", 16) ;
    title("Positive Trigger thresholds for DAC code 0x00", "fontsize", 16) ;

% Save the plot as a PDF 

    warning("off") ;
    str = ["./pdf/le_threshold_" pid_num ".pdf"] ;
	disp(["Creating pdf file: " str]);
    print(h_summary, '-dpdf', '-color', str) ;

exit 
