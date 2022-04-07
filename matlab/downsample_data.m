% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% April 2022

%% load appropriate data and change paths as needed
clear all
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data = load('processed_data\nfft2048\Profile007.mat');
profile(1) = data.Profile;
data = load('processed_data\nfft2048\Profile008.mat');
profile(2) = data.Profile;
data = load('processed_data\nfft2048\Profile009.mat');
profile(3) = data.Profile;
data = load('processed_data\nfft2048\Profile010.mat');
profile(4) = data.Profile;
clear data
for i = 1:length(profile)
    profile(i).Meta_Data.paths.process_library = 'C:\Users\cappa\Documents\EPSILOMETER';
    profile(i).Meta_Data.paths.calibration = 'C:\Users\cappa\Documents\EPSILOMETER\CALIBRATION\ELECTRONICS';
    profile(i).Meta_Data.paths.profiles = 'C:\Users\cappa\Documents\local_code\apex_epsi_processing\processed_data\nfft4096';
end

%% remove every other data point to simulate 160 Hz sampling and change
% relevant Meta_Data fields and the like for 2048 nfft, etc.

for i = 1:length(profile)
    profile(i).Meta_Data.PROCESS.nfft = 2048;
    profile(i).Meta_Data.PROCESS.nfftc = floor(2048/3);
    profile(i).Meta_Data.AFE.FS = 160;
    profile(i).epsi.dnum = downsample(profile(i).epsi.dnum, 2);
    profile(i).epsi.time_s = downsample(profile(i).epsi.time_s, 2);
    profile(i).epsi.t1_volt = downsample(profile(i).epsi.t1_volt, 2);
    profile(i).epsi.t2_volt = downsample(profile(i).epsi.t2_volt, 2);
    profile(i).epsi.s1_volt = downsample(profile(i).epsi.s1_volt, 2);
    profile(i).epsi.s2_volt = downsample(profile(i).epsi.s2_volt, 2);
    profile(i).epsi.a1_g = downsample(profile(i).epsi.a1_g, 2);
    profile(i).epsi.a2_g = downsample(profile(i).epsi.a2_g, 2);
    profile(i).epsi.a3_g = downsample(profile(i).epsi.a3_g, 2);
    profile(i).epsi.t1_volt_raw = downsample(profile(i).epsi.t1_volt_raw, 2);
    profile(i).epsi.t2_volt_raw = downsample(profile(i).epsi.t2_volt_raw, 2);
    profile(i).epsi.s1_volt_raw = downsample(profile(i).epsi.s1_volt_raw, 2);
    profile(i).epsi.s2_volt_raw = downsample(profile(i).epsi.s2_volt_raw, 2);
    profile(i).epsi.a1_g_raw = downsample(profile(i).epsi.a1_g_raw, 2);
    profile(i).epsi.a2_g_raw = downsample(profile(i).epsi.a2_g_raw, 2);
    profile(i).epsi.a3_g_raw = downsample(profile(i).epsi.a3_g_raw, 2);
    profile(i) = mod_epsilometer_calc_turbulence_v2(profile(i).Meta_Data, profile(i), 0);
end
save('processed_data\downsampled\profiles_nfft2048', 'profile')