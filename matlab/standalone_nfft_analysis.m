% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% March 2022

%% load appropriate data, all profile 007
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data = load('processed_data\nfft1024\Profile007.mat');
profile(1) = data.Profile;
data = load('processed_data\nfft2048\Profile007.mat');
profile(2) = data.Profile;
data = load('processed_data\nfft4096\Profile007.mat');
profile(3) = data.Profile;
clear data

%% plot/diff profiles to make sure they're the same
figure(1)
clf
for i = 1:length(profile)
    yyaxis left
    plot(profile(i).dnum, profile(i).z)
    hold on
    set(gca, 'YDir', 'reverse')
    yyaxis right
    plot(profile(i).dnum, profile(i).w)
    hold on
end
legend(num2str(profile(1).nfft), num2str(profile(2).nfft), num2str(profile(3).nfft),...
    num2str(profile(1).nfft), num2str(profile(2).nfft), num2str(profile(3).nfft))
hold off

%% plot epsilon profiles over each other
figure(2)
clf
colors = [0, 0, 1; 0, .447, .741; .929, .694, .125];
for i = 2:length(profile)
    line(i) = semilogx(profile(i).epsilon(:, 2), profile(i).z, 'Color',colors(i, :));
    mask = profile(i).epsilon(:, 2) > 2.42e-11;
    min_eps = profile(i).epsilon(mask, 2);
    [profile(i).min_eps.val, profile(i).min_eps.idx] = min(min_eps);
    color = get(line(i), 'Color');
    xline(profile(i).min_eps.val, 'Color',color, 'LineStyle','--')
    hold on
end
hold off
set(gca, 'YDir', 'reverse')
legend(...%num2str(profile(1).nfft), 'lowest \epsilon measured',...
    num2str(profile(2).nfft), 'lowest \epsilon measured',...
    num2str(profile(3).nfft),'lowest \epsilon measured',...
    'Location', 'southeast')
xlabel('epsilon (W/kg)')
ylabel('depth (m)')
title({'APEX-epsi standalone deployment', 'epsilons for various nfft'})
ylim([208.4 213.5])

%% plot spectra for lowest epsilons
figure(3)
clf
for i = 1:length(profile)
    idx = profile(i).min_eps.idx;
    spec(i) = loglog(profile(i).k(idx, :), profile(i).Ps_shear_k.s2(idx, :));
    color = get(spec(i), 'Color');
    [k_panchev, spec_panchev] = panchev(profile(i).epsilon(idx, 2), profile(i).kvis(idx));
    hold on
    loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
end
legend(num2str(profile(1).nfft), sprintf('\\epsilon = %.3g', profile(1).min_eps.val),...
    num2str(profile(2).nfft), sprintf('\\epsilon = %.3g', profile(2).min_eps.val),...
    num2str(profile(3).nfft), sprintf('\\epsilon = %.3g', profile(3).min_eps.val), ...
    'Location', 'northwest');
hold off
xlim([2*10^-1, 10^3])
ylim([10^-8, 10^-1])
xlabel('wavenumber (cpm)')
ylabel('\epsilon (W/kg)')
title({'APEX-epsi standalone deployment', 'lowest measured epsilon for various nfft'})

%% pick some epsilons and compare 2048 to 4096 spectra
% start ignoring nfft = 1024
target_epsilons = [2e-10, 1e-9, 5e-9, 1e-8, 5e-8, 1e-7, 1e-6, 1e-5];
idx = NaN(length(target_epsilons), length(profile));
val = NaN(size(idx));
y_limits = [10^-8, 10^-1; 10^-8, 10^-1; 10^-8, 10^-1; 10^-8, 10^-1;...
    10^-7, 10^-0; 10^-7, 10^-0; 10^-6, 10^1; 10^-6, 10^1];
for j = 1:length(target_epsilons)
    [val(j, 2), idx(j, 2)] = min(abs(profile(2).epsilon(:, 2) - target_epsilons(j)));
    [val(j, 3), idx(j, 3)] = min(abs(profile(3).epsilon(:, 2) - target_epsilons(j)));
    figure(j)
    clf
    for i = 2:length(profile)
        spec(i) = loglog(profile(i).k(idx(j, i), :), profile(i).Ps_shear_k.s2(idx(j, i), :));
        color = get(spec(i), 'Color');
        [k_panchev, spec_panchev] = panchev(profile(i).epsilon(idx(j, i), 2), profile(i).kvis(idx(j, i)));
        hold on
        loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
    end
    legend(num2str(profile(2).nfft), sprintf('\\epsilon = %.3g', profile(2).epsilon(idx(j, 2), 2)),...
    num2str(profile(3).nfft), sprintf('\\epsilon = %.3g', profile(3).epsilon(idx(j, 3), 2)), ...
    'Location', 'northwest');
    hold off
    xlim([5*10^-1, 10^3])
    ylim(y_limits(j, :))
    xlabel('wavenumber (cpm)')
    ylabel('\epsilon (W/kg)')
    title({'APEX-epsi standalone deployment', 'close epsilon comparisons for various nfft',...
        sprintf('target epsilon = %.2g', target_epsilons(j))})
end

%% pick some bins where 4096 gets an epsilon but 2048 rails
% from examination, bins between 210 and 215 m depth look like a good
% region
depth_range = [208.4 213.5];
[~, first] = min(abs(profile(2).z - depth_range(1)));
[~, last] = min(abs(profile(2).z - depth_range(end)));
idx = first:last;
for j = 1:length(idx)
    figure(j)
    clf
    for i = 2:length(profile)
        spec(i) = loglog(profile(i).k(idx(j), :), profile(i).Ps_shear_k.s2(idx(j), :));
        color = get(spec(i), 'Color');
        [k_panchev, spec_panchev] = panchev(profile(i).epsilon(idx(j), 2), profile(i).kvis(idx(j)));
        hold on
        loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
    end
    legend(num2str(profile(2).nfft), sprintf('\\epsilon = %.3g', profile(2).epsilon(idx(j), 2)),...
        num2str(profile(3).nfft), sprintf('\\epsilon = %.3g', profile(3).epsilon(idx(j), 2)), ...
        'Location', 'northwest');
    hold off
    xlim([5*10^-1, 5*10^2])
    ylim([10^-9, 10^-3])
    xlabel('wavenumber (cpm)')
    ylabel('\epsilon (W/kg)')
    title({'APEX-epsi standalone deployment', 'spectra comparisons for low epsilons',...
        sprintf('%.4g m depth', profile(2).z(idx(j)))})
end
