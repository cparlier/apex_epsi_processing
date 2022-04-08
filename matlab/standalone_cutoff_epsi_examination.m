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

%% plot all epsilon profiles
[fig, ax] = plot_epsilon_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'})
[fig, ax] = plot_fom_profiles(profile);
sgtitle({'Standalone APEX-epsi', 'FOM across all standard ascent profiles'})

%% pick a single vertical bin from a single profile
% close all
targets = 555; %[95, 650, 660, 670];
[fig, ax] = plot_allshear_target_depths(profile(3), targets);



% load('processed_data\nfft4096\Profile009.mat')
% hold on
% [fig, ax] = plot_allshear_target_depths(Profile, targets);



%% add wavenumber cutoffs to profile structs and plot wavenumber cutoffs
profile = add_wavenumber_cutoffs(profile);

for i = 1:length(profile)
    fig(i) = figure;
    ax(i, 1) = subplot(1, 2, 1);
    mask = profile(i).epsilon(:, 2) > 1e-11;
    eps_plot = profile(i).epsilon(:, 2);
    eps_plot(~mask) = NaN;
    semilogx(eps_plot, profile(i).z(:));
    set(gca, 'YDir', 'reverse')
%     ax(i).XTick = [10^-10 10^-6];
    xlabel('\epsilon (W/kg)')
    ax(i, 2) = subplot(1, 2, 2);
    semilogx(profile(i).sh_kc, profile(i).z, profile(i).sh_kc_data, profile(i).z);
    set(gca, 'YDir', 'reverse')
    linkaxes(ax(i, :), 'y');
    legend('k_c', 'k_{c-data}', 'Location', 'southeast')
    xlabel('wavenumber cutoff (cpm)')
    set(gca, 'YTick', [])
    max_depth = 0;
    if max_depth < max(abs(profile(i).z))
        max_depth = max(abs(profile(i).z));
    end
    ax(i, 1).YLim = [0 max_depth];
%     ax(i, 1).XLim = [10^-10 10^-5];
    sgtitle({sprintf('Profile %d', profile(i).profNum), '\epsilon and wavenumber cutoff'})
end

%% pseudo-code
% load data and change paths
% pick a single vertical bin from a single profile
% plot shear spectrum with panchev overlay
% add clear point with wavenumber cutoff for integration
% plot raw shear data for same vertical bin

% obj = f_computeTurbulence(obj,Profile_or_profNum,saveData)