function profile = add_wavenumber_cutoffs(profile)

    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    for i = 1:length(profile)
        profile(i).sh_kc = profile(i).sh_fc(:, 2)./abs(profile(i).w);
        profile(i).sh_kc_data = nan(profile(i).nbscan, 1);
        profile(i).sh_kc_data_idx = nan(profile(i).nbscan, 1);
        for j = 1:profile(i).nbscan
            if ~isnan(profile(i).k(j, 1))
                [profile(i).sh_kc_data(j), profile(i).sh_kc_data_idx(j)] = max(profile(i).k(j, (profile(i).k(j, :) < profile(i).sh_kc(j))));
            end
        end
    end

end