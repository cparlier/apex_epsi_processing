function [fig, ax] = plot_allshear_filtercomp_target_depths(profile, bad_filter, targets)
    
    %UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here
    depths = nan(1, length(targets));
    idx = nan(1, length(targets));
    g = 9.81;
    Sv = profile.Meta_Data.AFE.s2.cal;
    h_freq = profile.Meta_Data.PROCESS.h_freq;
    % find bin at target depth
    for i = 1:length(targets)
        % shear spectra with wave# cutoff and panchev overlay
        [~, idx(i)] = min(abs(profile.z - targets(i)));
        depths(i) = profile.z(idx(i));
        [k_panchev, spec_panchev] = panchev(profile.epsilon(idx(i), 2), profile.kvis(idx(i)));
        fig(i) = figure;
        subplot(1, 2, 1)
        ax(i, 1) = loglog(profile.k(idx(i), :), profile.Ps_shear_k.s2(idx(i), :));
        hold on
%         loglog(profile.k(idx(i), :), profile.Ps_shear_co_k.s2(idx(i), :));
        color = get(ax(i, 1), 'Color');
        hold on
        loglog(k_panchev, spec_panchev, 'Color',color, 'LineStyle','--')
        kc_emp = profile.sh_fc(idx(i), 2)/abs(profile.w(idx(i)));
        [kc, kc_idx] = max(profile.k(idx(i), profile.k(idx(i), :) < kc_emp));
        plot(kc, profile.Ps_shear_k.s2(idx(i), kc_idx), 'g*');
        loglog(bad_filter.k(idx(i), :), bad_filter.Ps_shear_k.s2(idx(i), :), 'r');
        [k_panchev_bad, spec_panchev_bad] = panchev(bad_filter.epsilon(idx(i), 2), bad_filter.kvis(idx(i)));
        loglog(k_panchev_bad, spec_panchev_bad, 'r--')
        legend('shear spectrum', sprintf('\\epsilon = %.3g', profile.epsilon(idx(i), 2)),...
            '\epsilon wavenumber cutoff', 'bad filter',...
            sprintf('\\epsilon = %.3g', bad_filter.epsilon(idx(i), 2)));
        xlabel('wavenumber (cpm)')
        ylabel('\Phi_{shear} (s^{-2}/cpm)')
        title('spectra')
        ylim([10^-8 10^-2])
        xlim([.5 200])
        % raw shear data
        ax(i, 2) = subplot(1, 2, 2);
        idx_raw = profile.ind_range_epsi(idx(i), 1):profile.ind_range_epsi(idx(i), end);
        plot(profile.epsi.dnum(idx_raw), profile.epsi.s2_volt(idx_raw))
        datetick
        ylim([-.005 .005])
        xlim([min(profile.epsi.dnum(idx_raw)), max(profile.epsi.dnum(idx_raw))])
        xlabel('time')
        ylabel('shear (V)')
        title('raw shear data')
        % velocity spectrum
%         filter_TF = (h_freq.shear'.*haf_oakey(profile.f, profile.w(idx(i))));
%         Ps_velocity_f = ((2*g/(Sv*profile.w(idx(i))))^2).*profile.Ps_volt_f.s2(idx(i), :)./filter_TF;
%         subplot(2, 2, 3)
%         loglog(profile.f, Ps_velocity_f)
%         xlabel('frequency (Hz)')
%         ylabel('\Phi_{velocity} (m/s^{2}/Hz)')
        % noise floor from velocity spectrum

        % title
        sgtitle(sprintf('Profile %d, %.3g m depth', profile.profNum, depths(i)));
    end

end


% %% calculate and plot a number of noise floors for different rise rates
% w = [0.05, 0.075, 0.1, 0.15, 0.2, 0.5, 1];
% phi_v_f = 10^-10*ones(1, length(profile(1).f));
% k = linspace(1, 10^3, length(phi_v_f));
% phi_shear_k = nan(length(w), length(k));
% for i = 1:length(w)
%     phi_shear_k(i, :) = phi_v_f.*w(i).*k.^2;
% end
% loglog(k, phi_shear_k)
% legend('5', '7,5', '10', '15', '20', '50', '100')
% epsilon = [1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5];
% for i = 1:length(epsilon)
%     [k, Pxx] = panchev(epsilon(i), 1.5e-6);
%     hold on
%     loglog(k, Pxx)
% end
% hold off

% k = f./w;
% 
% 
% % Convert frequency spectrum of velocity timeseries in volts to the frequency spectrum
% % of shear in s^-1
% Ps_velocity_f = ((2*G/(Sv*w))^2).*Ps_volt_f./filter_TF;




