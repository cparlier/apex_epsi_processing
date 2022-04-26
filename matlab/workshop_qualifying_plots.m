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

%% set savefig params
save_flag = 1;

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

%% plot pressure vs time for entire deployment
% label yoyo profiles and standard ascent profiles
[fig_deployment, ax_deployment] = plot_standalone_deployment(profile, yoyo);
if save_flag
    savefig('figs/pressure_standalone');
end

%% flag bad data
% flag buoyancy pump periods
threshold = 2e-6;
profile = remove_bouyancy_pump(profile, threshold);
% flag scans with spikes in shear data
threshold = 6;
profile = remove_shearspikes(profile, threshold);

%% plot for each standard ascent profile of shear, temp or T', a3, epsilon,
% chi, rise rate
[fig_raw, ax_raw] = plot_raw_plus(profile);
if save_flag
    for i = 1:length(fig_raw)
        savefig(fig_raw(i), sprintf('figs/raw_data_standalone_profile%d', profile(i).profNum));
    end
end

%% plot epsilon and chi profiles
[fig_eps, ax_eps] = plot_epsilon_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'}, 'FontSize',20)
if save_flag
    savefig('figs/epsilon_standalone');
end
[fig_chi, ax_chi] = plot_chi_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\chi across all standard ascent profiles'}, 'FontSize',20)
if save_flag
    savefig('figs/chi_standalone');
end

%% compute acceleration coherence with raw shear for all scans
num_scans = 4;
for i = 1:length(profile)
    profile(i).Cs2a1_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    profile(i).Cs2a2_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    profile(i).Cs2a3_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    % loop through nbscan
    for j = 1:profile(i).nbscan
        left_scans = floor((num_scans - 1)/2);
        if j <= left_scans
            left_scans = j - 1;
        end
        right_scans = num_scans - left_scans - 1;
        if (profile(i).nbscan - j) < right_scans
            right_scans = profile(i).nbscan - j;
            left_scans = num_scans - right_scans - 1;
        end
        idx = profile(i).ind_range_epsi(j + right_scans, 1):profile(i).ind_range_epsi(j - left_scans, end);
        if ~isnan(idx) & (length(idx) > profile(i).nfft)
            profile(i).Cs2a1_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a1_g(idx), profile(i).nfft);
            profile(i).Cs2a2_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a2_g(idx), profile(i).nfft);
            profile(i).Cs2a3_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a3_g(idx), profile(i).nfft);
        end
    end
end

%% pick 3-4 epsilons and average spectra for all of them
% plot shear spectra with panchev overlay, acceleration coherence,
% acceleration overlay (see fig 12 for some examples)
targets10 = -9.5:.5:-6;
range10 = [targets10' - .25, targets10'];
targets = 10.^targets10;
range = 10.^range10;
[fig_shear_spectra, ax_shear_spectra] = plot_shear_panchev_binned_epsilons(profile, targets, range, 1);
ax_shear_spectra(1).FontSize = 14;
ax_shear_spectra(2).FontSize = 14;
ax_shear_spectra(3).FontSize = 14;
if save_flag
    savefig(fig_shear_spectra(1), 'figs/shear_standalone');
    savefig(fig_shear_spectra(2), 'figs/acceleration_standalone')
end

%% do the same with chi/temperature gradient
targets10 = [-9, -8.5, -7.5:.5:-6];
range10 = [targets10' - .25, targets10' + .25];
targets = 10.^targets10;
range = 10.^range10;
[fig_tg_spectra, ax_tg_spectra] = plot_temp_batchelor_binned_chis(profile, targets, range);
ax_tg_spectra.FontSize = 14;
if save_flag
    savefig(fig_tg_spectra, 'figs/tempgradient_standalone')
end







