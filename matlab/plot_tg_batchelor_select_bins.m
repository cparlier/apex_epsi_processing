function [fig, ax] = plot_tg_batchelor_select_bins(profile, targets)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     idx = NaN(length(targets), length(profile));
%     legend_array = cell(1, length(targets)*2);
    legend_array = cell(length(targets)*2, 1);
    fig = figure;
    t = tiledlayout(3, 4, 'TileSpacing','compact');
    nexttile(1, [3, 1]);
    mask = profile.chi(:, 2) > 1e-12;
    chi_plot = profile.chi(:, 2);
    chi_plot(~mask) = NaN;
    semilogx(chi_plot, profile.z);
    ax(1) = gca;
    hold on
    set(ax(1), 'YDir', 'reverse');
    xlabel('\chi (K^2/s)')
    ylabel('Depth (m)')
    grid on
    nexttile(2, [3, 3]);
    ax(2) = gca;
    for j = 1:length(targets)
        chi = profile.chi(targets(j), 2);
        axes(ax(1));
        star = plot(chi, profile.z(targets(j)), 'Marker','o');
        set(star, 'MarkerFaceColor', get(star, 'Color'));
        axes(ax(2));
        loglog(profile.k(targets(j), :), profile.Pt_Tg_k.t2(targets(j), :), 'Color',get(star, 'Color'))
        hold on
        kappa = kt(profile.s(targets(j)), profile.t(targets(j)), profile.pr(targets(j)));
        [k_batch, spec_batch] = batchelor(profile.epsilon(targets(j), 2), chi, profile.kvis(targets(j)), kappa);
        loglog(k_batch, spec_batch, 'Color',get(star, 'Color'), 'LineStyle','--')
        legend_array{2*j - 1} = sprintf('Observed Spectrum - %.3g m', profile.z(targets(j)));
        legend_array{2*j} = sprintf('Batchelor - \\chi = %.2g, \\epsilon = %.2g', chi, profile.epsilon(targets(j), 2));
    end
    legend(legend_array, 'Location', 'best', 'AutoUpdate', 'off');
    xlabel('wavenumber (cpm)')
    ylabel('\Phi_{Tg} (K^{2}m^{-2}/cpm)')
    title(t, {sprintf('APEX-epsi standalone deployment profile %d', profile.profNum),...
        '\chi and temperature gradient wavenumber spectra'}, 'FontSize',14)
end