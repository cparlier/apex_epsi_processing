% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% April 2022

%% load appropriate data and change paths as needed
clear all
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
load('processed_data\downsampled\profiles_nfft2048.mat');

%% add standard deviation of shear to profiles
for i = 1:length(profile)
    profile(i).s2_stddev = nan(profile(i).nbscan, 1);
    for j = 1:profile(i).nbscan
        idx = profile(i).ind_range_epsi(j, 1):profile(i).ind_range_epsi(j, end);
        if ~isnan(idx)
            profile(i).s2_stddev(j) = std(profile(i).epsi.s2_volt(idx));
        end
    end
end

%% plot freq spectra to scope if buoyancy pump freq is clear
idx = 1315:1324;
figure
clf
hold on
for i = 1:length(idx)
    loglog(profile(1).f, profile(1).Ps_volt_f.s2(idx(i), :));
end
set(gca, 'YScale', 'log', 'XScale', 'log')
ylim([10^-12 10^-4])

%% plot stddev and shear
close all
targets = 665;
i = 1;
% for i = 1:length(profile)
    [~, idx(i)] = min(abs(profile(i).z - targets(i)));
    depths(i) = profile(i).z(idx(i));
    figure
    ax(1) = subplot(1, 3, 1);
    plot(profile(i).epsi.s2_volt, profile(i).epsi.dnum)
    ylabel('shear (V)')
    ax(2) = subplot(1, 3, 2);
    plot(profile(i).s2_stddev, profile(i).z)
    set(gca, 'YDir', 'reverse')
    ylim([650 665])
    ax(3) = subplot(1, 3, 3);
    semilogx(profile(i).epsilon(:, 2), profile(i).z);
    set(gca, 'YDir', 'reverse')
    ylim([650 665])
% end

%% compute acceleration coherence with raw shear for all scans
num_scans = 10;
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

%% show some plots
close all
targets = 625;
[fig, ax] = plot_allshear_target_depths(profile(1), targets);
[fig, ax] = plot_accelcohere_target_depths(profile(1), targets);
