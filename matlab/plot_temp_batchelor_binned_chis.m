function [fig, ax] = plot_temp_batchelor_binned_chis(profile, targets, range)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     idx = NaN(length(targets), length(profile));
%     legend_array = cell(1, length(targets)*2);
    fig = figure;
    target_range = range;
    tg_spec = zeros(length(targets), profile(1).nfft/2 + 1);
    k_spec = zeros(size(tg_spec));
    kvis_spec = zeros(length(targets));
    kappa_spec = zeros(length(targets));
    epsilon_spec = zeros(length(targets));
    num_inrange = nan(length(profile), 1);
    for j = 1:length(targets)
        for i = 1:length(profile)
            mask = profile(i).chi(:, 2) > 1e-10;
            mask = mask & (profile(i).chi(:, 2) > target_range(j, 1)) & (profile(i).chi(:, 2) < target_range(j, end));
            temp_spec = profile(i).Pt_Tg_k.t2(mask, :);
            temp_k = profile(i).k(mask, :);
            temp_kvis = profile(i).kvis(mask);
            temp_kappa = kt(profile(i).s(mask), profile(i).t(mask), profile(i).pr(mask));
            temp_epsilon = profile(i).epsilon(mask, 2);
            num_inrange(i) = size(temp_spec, 1);
            tg_spec(j, :) = tg_spec(j, :) + sum(temp_spec, 1);
            k_spec(j, :) = k_spec(j, :) + sum(temp_k, 1);
            kvis_spec(j) = kvis_spec(j) + sum(temp_kvis);
            kappa_spec(j) = kappa_spec(j) + sum(temp_kappa);
            epsilon_spec(j) = epsilon_spec(j) + sum(temp_epsilon);
        end
        tg_spec(j, :) = tg_spec(j, :)/sum(num_inrange);
        k_spec(j, :) = k_spec(j, :)/sum(num_inrange);
        kvis_spec(j) = kvis_spec(j)/sum(num_inrange);
        kappa_spec(j) = kappa_spec(j)/sum(num_inrange);
        epsilon_spec(j) = epsilon_spec(j)/sum(num_inrange);
        spec(j) = loglog(k_spec(j, 2:end), tg_spec(j, 2:end));
        hold on
        ax = gca;
        color = get(spec(j), 'Color');
        [k_batch, spec_batch] = batchelor(epsilon_spec(j), targets(j), kvis_spec(j), kappa_spec(j));
        loglog(k_batch, spec_batch, 'k--')
        buffer = 3;
        x_start = 0.8;
        if ~isnan(k_batch)
            [val, idx] = min(abs((x_start + x_start*buffer) - k_batch));
            text(x_start + x_start*buffer, spec_batch(idx), sprintf('\\chi = 10^{%.2g}', log10(targets(j))), 'VerticalAlignment','bottom')
        end
        legend_array{2*j - 1} = sprintf('%.3g < log_{10}\\chi < %.2g', log10(range(j, 1)), log10(range(j, end)));
        legend_array{2*j} = '';
    
    end
    ylim([5e-6 .05])
    xlim([x_start 500])
    legend(legend_array, 'Location', 'best', 'AutoUpdate', 'off');
    hold off
    xlabel('wavenumber (cpm)')
    ylabel('\Phi_{Tg} (K^{2}m^{-2}/cpm)')
    title({'APEX-epsi standalone deployment', 'binned temperature gradient wavenumber spectra'})
end