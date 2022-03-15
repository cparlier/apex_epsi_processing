% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% March 2022

%% load appropriate data
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
% ylim([208.4 213.5])

%% plot spectra for lowest epsilons
figure(3)
clf
for i = 2:length(profile)
    idx = profile(i).min_eps.idx;
    spec(i) = loglog(profile(i).k(idx, :), profile(i).Ps_shear_k.s2(idx, :));
    color = get(spec(i), 'Color');
    [k_panchev, spec_panchev] = panchev(profile(i).epsilon(idx, 2), profile(i).kvis(idx));
    hold on
    loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
end
legend(...%num2str(profile(1).nfft), sprintf('\\epsilon = %.3g', profile(1).min_eps.val),...
    num2str(profile(2).nfft), sprintf('\\epsilon = %.3g', profile(2).min_eps.val),...
    num2str(profile(3).nfft), sprintf('\\epsilon = %.3g', profile(3).min_eps.val), ...
    'Location', 'northwest');
hold off
xlim([2*10^-1, 10^3])
ylim([10^-8, 10^-1])
xlabel('wavenumber (cpm)')
ylabel('\Phi_{shear} (s^{-2}/cpm)')
title({'APEX-epsi standalone deployment', 'lowest measured epsilon for various nfft'})

%% pick some epsilons and compare 2048 to 4096 spectra
% start ignoring nfft = 1024
target_epsilons = [2e-10, 1e-9, 5e-9, 1e-8, 5e-8, 1e-7, 1e-6, 1e-5];
spec = plot_shear_panchev_target_epsilons(target_epsilons, profile);

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
    ylabel('\Phi_{shear} (s^{-2}/cpm)')
    title({'APEX-epsi standalone deployment', 'spectra comparisons for low epsilons',...
        sprintf('%.4g m depth', profile(2).z(idx(j)))})
end

%%


% %% nix this section
% % find minimum epsilon for a given fall rate and nfft combination
% % initial integration happens between 2 and 10cpm, need a critical number
% % of point lower than 10cpm in order to get an epsilon
% % let's empirically determine that
% avg_pts_bad = size(1, length(profile));
% avg_pts_good = size(avg_pts_bad);
% ratio_bad = size(1, length(profile));
% ratio_good = size(ratio_bad);
% k_fundamental_good = size(ratio_bad);
% k_fundamental_bad = size(ratio_bad);
% product_good = size(ratio_good);
% product_bad = size(product_good);
% w_good = size(product_bad);
% w_bad = size(w_good);
% k_ratio_bad = size(w_bad);
% k_ratio_good = size(k_ratio_bad);
% integral_mean_good = size(k_ratio_good);
% integral_mean_bad = size(integral_mean_good);
% for i = 1:length(profile)
%     profile(i).eps_mask = profile(i).epsilon(:, 2) > 1e-11; 
%     profile(i).num_good_epsilon = sum(profile(i).eps_mask);
%     profile(i).num_bad_epsilon = sum(~profile(i).eps_mask);
%     profile(i).num_under10 = zeros(1, profile(i).nbscan);
%     for j = 1:profile(i).nbscan
%         profile(i).num_under10(j) = sum(profile(i).k(j, 2:end) < 10);
%         profile(i).integral(j) = sum(profile(i).k(j, 2)*profile(i).Ps_shear_k.s2(j, 2:(profile(i).num_under10(j) + 1)));
%     end
%     % looking for different metrcis to quantify what makes a good vs. bad
%     % epsilon
%     % try avg number of samples below 10cpm
%     avg_pts_bad(i) = mean(profile(i).num_under10(~profile(i).eps_mask));
%     avg_pts_good(i) = mean(profile(i).num_under10(profile(i).eps_mask));
%     % try ratio of nfft to avg num of samples below 10cpm for bad
%     ratio_bad(i) = profile(i).nfft/avg_pts_bad(i);
%     ratio_good(i) = profile(i).nfft/avg_pts_good(i);
%     % try average fundamental wavenumber?
%     k_fundamental_good(i) = mean(profile(i).k(profile(i).eps_mask, 2));
%     k_fundamental_bad(i) = mean(profile(i).k(~profile(i).eps_mask & ~isnan(profile(i).k(:, 1)), 2));
%     % multiply average fundamental wavenumber by Nfft seems good?
%     product_good(i) = profile(i).nfft*k_fundamental_good(i);
%     product_bad(i) = profile(i).nfft*k_fundamental_bad(i);
%     % let's just test rise rate itself
%     w_good(i) = profile(i).nfft/mean(abs(profile(i).w(profile(i).eps_mask)));
%     w_bad(i) = profile(i).nfft/mean(abs(profile(i).w(~profile(i).eps_mask & ~isnan(profile(i).w))));
%     % maybe ratio of avg_pts to fundamental wavenumber?
%     k_ratio_bad(i) = avg_pts_bad(i)/k_fundamental_bad(i);
%     k_ratio_good(i) = avg_pts_good(i)/k_fundamental_good(i);
%     % perhaps actually do the integral as the check?
%     integral_mean_good(i) = profile(i).nfft/mean(profile(i).integral(profile(i).eps_mask));
%     integral_mean_bad(i) = profile(i).nfft/mean(profile(i).integral(~profile(i).eps_mask));
% end
% % plot(profile(2).epsilon(:, 2), profile(2).)