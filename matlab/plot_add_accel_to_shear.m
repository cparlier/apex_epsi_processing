function [figs, accel_spec_lines, profile] = plot_add_accel_to_shear(figs, idx, profile)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    g = 9.81;
    acc_spec_lines = gobjects(length(idx), length(profile), 3);
    for i = 1:length(profile)
        for m = 1:profile(i).nbscan
            profile(i).Ps_a1_k(m, :) = profile(i).Pa_g_f.a1(m, :)./(abs(profile(i).w(m))*g^2);
            profile(i).Ps_a2_k(m, :) = profile(i).Pa_g_f.a2(m, :)./(abs(profile(i).w(m))*g^2);
            profile(i).Ps_a3_k(m, :) = profile(i).Pa_g_f.a3(m, :)./(abs(profile(i).w(m))*g^2);
        end
    end
    for j = 1:length(idx)
        set(figs(j), 'defaultLegendAutoUpdate', 'off')
        figure(figs(j));
        hold on
        for i = 1:length(profile)
            accel_spec_lines(j, i, :) = loglog(profile(i).k(idx(j, i), :), profile(i).Ps_a1_k(idx(j, i), :),...
                profile(i).k(idx(j, i), :), profile(i).Ps_a2_k(idx(j, i), :),...
                profile(i).k(idx(j, i), :), profile(i).Ps_a3_k(idx(j, i), :));
        end
        set(legend, 'visible', 'off')
        ylim([10^-11, 10^-3])
        hold off
        title({'APEX-epsi standalone deployment', 'close epsilon comparisons across profiles',...
            'with acceleration spectra for all 3 axes'})
    end
end