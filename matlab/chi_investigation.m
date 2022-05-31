% Andrew Parlier
% APEX-epsi plots
% chi investigations
% standalone deployment
% May/June 2022

%% load data and set paths
clear all
close all
clc
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
load('processed_data\downsampled\profiles_nfft2048.mat');

%% flag buoyancy pump periods
threshold = 2e-6;
profile = remove_bouyancy_pump(profile, threshold);

%% plot chi profiles
[fig, ax] = plot_chi_profiles(profile);

%% plot tg spectra from bad chi values
prof_num = 1;
for targets = 1:profile(prof_num).nbscan
    if profile(prof_num).chi(targets, 2) == 0
        [fig, ax] = plot_tg_spectra(profile(prof_num), targets);
        pause;
        close(fig);
    end
end

%% plot tg spectra for binned chi (binned on epsilon as well)
targets10 = -9:.5:-7;
range10 = [targets10' - .25, targets10' + .25];
targets = 10.^targets10;
range = 10.^range10;
[fig, ax] = plot_temp_batchelor_binned_chis(profile, targets, range);
