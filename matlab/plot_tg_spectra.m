function [fig, ax] = plot_tg_spectra(profile, targets)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     idx = NaN(length(targets), length(profile));
%     legend_array = cell(1, length(targets)*2);

%     legend_array = cell(length(targets)*3, 1);
    fig = figure;
    styles = {'-', '--', '-.'};
    for j = 1:length(targets)
        chi = profile.chi(targets(j), 2);
        spectrum = loglog(profile.k(targets(j), :), profile.Pt_Tg_k.t2(targets(j), :),...
            'LineStyle','--');
        hold on
        loglog(profile.k(targets(j), :), smooth(profile.Pt_Tg_k.t2(targets(j), :)),...
            'Color',get(spectrum, 'Color'), 'LineWidth',2)
        kappa = kt(profile.s(targets(j)), profile.t(targets(j)), profile.pr(targets(j)));
        [k_batch, spec_batch] = batchelor(profile.epsilon(targets(j), 2), chi, profile.kvis(targets(j)), kappa);
        loglog(k_batch, spec_batch, 'k', 'LineStyle',styles(j))
        legend_array{3*j - 2} = '';
        legend_array{3*j - 1} = sprintf('Smoothed Observed Spectrum - %.3g m', profile.z(targets(j)));
        legend_array{3*j} = sprintf('Batchelor - \\chi = %.2g, \\epsilon = %.2g', chi, profile.epsilon(targets(j), 2));
    end
    legend(legend_array, 'Location', 'best', 'AutoUpdate', 'off');
    xlabel('wavenumber (cpm)')
    ylabel('\Phi_{Tg} (K^{2}m^{-2}/cpm)')
    title({sprintf('APEX-epsi standalone deployment profile %d', profile.profNum),...
        '\chi and temperature gradient wavenumber spectra'}, 'FontSize',14, 'FontWeight','bold')
    ax = gca;
end