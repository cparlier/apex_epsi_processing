function [figs, spec, idx] = plot_shear_panchev_target_epsilons(targets, profile)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    idx = NaN(length(targets), length(profile));
    val = NaN(size(idx));
    legend_array = cell(1, length(profile)*2);
    figs = gobjects(1, length(targets));
    spec = gobjects(length(targets), length(profile));
    % y_limits = [10^-8, 10^-1; 10^-8, 10^-1; 10^-8, 10^-1; 10^-8, 10^-1;...
    %     10^-7, 10^-0; 10^-7, 10^-0; 10^-6, 10^1; 10^-6, 10^1];
    for j = 1:length(targets)
        figs(j) = figure;
        clf
        for i = 1:length(profile)
            [val(j, i), idx(j, i)] = min(abs(profile(i).epsilon(:, 2) - targets(j)));
            spec(j, i) = loglog(profile(i).k(idx(j, i), :), profile(i).Ps_shear_k.s2(idx(j, i), :));
            color = get(spec(j, i), 'Color');
            [k_panchev, spec_panchev] = panchev(profile(i).epsilon(idx(j, i), 2), profile(i).kvis(idx(j, i)));
            hold on
            loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
            legend_array{2*i - 1} = sprintf('Profile %d', profile(i).profNum);
            legend_array{2*i} = sprintf('\\epsilon = %.3g', profile(i).epsilon(idx(j, i), 2));
        end
        legend(legend_array, 'Location', 'best', 'AutoUpdate', 'off');
        hold off
        ylim([10^-8 1])
        xlim([1 10^3])
        xlabel('wavenumber (cpm)')
        ylabel('\epsilon (W/kg)')
        title({'APEX-epsi standalone deployment', 'close epsilon comparisons across profiles',...
            sprintf('target epsilon = %.2g', targets(j))})
    end

end