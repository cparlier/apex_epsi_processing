% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% March 2022

%% load appropriate data and change paths as needed
clear all
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data = load('processed_data\nfft4096\Profile007.mat');
profile(1) = data.Profile;
data = load('processed_data\nfft4096\Profile008.mat');
profile(2) = data.Profile;
data = load('processed_data\nfft4096\Profile009.mat');
profile(3) = data.Profile;
data = load('processed_data\nfft4096\Profile010.mat');
profile(4) = data.Profile;
clear data

%%
for i = 1:length(profile)
    profile(i).Meta_Data.paths.process_library = 'C:\Users\cappa\Documents\EPSILOMETER';
    profile(i).Meta_Data.paths.calibration = 'C:\Users\cappa\Documents\EPSILOMETER\CALIBRATION\ELECTRONICS';
    profile(i).Meta_Data.paths.profiles = 'C:\Users\cappa\Documents\local_code\apex_epsi_processing\processed_data\nfft4096';
end
%% calculate turbulence