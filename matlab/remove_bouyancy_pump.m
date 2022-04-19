function profile = remove_bouyancy_pump(profile, threshold)

    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    for i = 1:length(profile)
        profile(i).pump.check = nan(profile(i).nbscan, 1);
        profile(i).pump.flag = zeros(profile(i).nbscan, 1);
        mask = (profile(i).f > 40 & profile(i).f < 65);
        for j = 1:profile(i).nbscan
            profile(i).pump.check(j) = sum(profile(i).f(2)*profile(i).Pa_g_f.a3(j, mask));
            if profile(i).pump.check(j) > threshold
                profile(i).pump.flag(j) = 1;
            end
        end
    end
    
end