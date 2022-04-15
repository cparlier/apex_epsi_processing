function [fig, ax] = plot_accelcohere_target_depths(profile, targets)

    depths = nan(1, length(targets));
    idx = nan(1, length(targets));
    % find bin at target depth
    for i = 1:length(targets)
        % shear spectra with wave# cutoff and panchev overlay
        [~, idx(i)] = min(abs(profile.z - targets(i)));
        depths(i) = profile.z(idx(i));
        fig(i) = figure;
        ax(i) = semilogx(profile.k(idx(i), :), profile.Cs2a1_scan(idx(i), :));
        hold on
        semilogx(profile.k(idx(i), :), profile.Cs2a2_scan(idx(i), :))
        semilogx(profile.k(idx(i), :), profile.Cs2a3_scan(idx(i), :))
        legend('a1', 'a2', 'a3');
        xlabel('wavenumber (cpm)')
        ylabel('magnitude squared coherence')
        title({'shear - acceleration coherence', sprintf('Profile %d, %.3g m depth', profile.profNum, depths(i))})
    end

end