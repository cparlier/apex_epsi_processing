% Andrew Parlier
% APEX-epsi plots
% May workshop and Qualifying prospectus
% standalone deployment
% April 2022

%% load data and set paths
clear all
close all
clc
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
load('processed_data\downsampled\profiles_nfft2048.mat');
for i = 1:6
    load(sprintf('processed_data\\nfft4096\\Profile00%d.mat', i));
    yoyo(i) = Profile;
    clear Profile;
end

%% flag bad data
% flag buoyancy pump periods
threshold = 2e-6;
profile = remove_bouyancy_pump(profile, threshold);
% flag scans with spikes in shear data
threshold = 6;
profile = remove_shearspikes(profile, threshold);

%% plot pressure vs time for entire deployment
% label yoyo profiles and standard ascent profiles
[fig_deployment, ax_deployment] = plot_standalone_deployment(profile, yoyo);


%% plot for each standard ascent profile of shear, temp or T', a3, epsilon,
% chi, rise rate
[fig_raw, ax_raw] = plot_raw_plus(profile);

%% plot epsilon and chi profiles
[fig_eps, ax_eps] = plot_epsilon_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'}, 'FontSize',20)
[fig_chi, ax_chi] = plot_chi_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\chi across all standard ascent profiles'}, 'FontSize',20)
%% pick 3-4 epsilons and average spectra for all of them
% plot shear spectra with panchev overlay, acceleration coherence,
% acceleration overlay

%% do the same with chi/temperature gradient

% 








%% fix timestamps for profiles (profile.dnum only)
for i = 1:length(profile)
    temp = datevec(profile(i).dnum);
    temp(:, 2) = temp(:, 2) + 1;
    profile(i).dnum = datenum(temp);
end
for i = 1:length(yoyo)
    temp = datevec(yoyo(i).dnum);
    temp(:, 2) = temp(:, 2) + 1;
    yoyo(i).dnum = datenum(temp);
end
