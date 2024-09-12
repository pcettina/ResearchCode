function segment_spikes_by_correlation(spikeProfiles)
    
    profiles = load(spikeProfiles).profiles;
    
    figure;
    xline(10, 'r', 'LineWidth', 2);
    for i = 1:length(profiles)
        
        hold on;
    
        timeOffset_prev = find(profiles{max(i-1,1)} == max(profiles{max(i-1,1)}));
        timeOffset_cur = find(profiles{i} == max(profiles{i}));
    
        
        profiles{i} = circshift(profiles{i}, timeOffset_prev-timeOffset_cur);
        
        plot(profiles{i});
        hold off;
    end
    
    
    % compute correlatin of data to the first spike... 
    % say spike 1 == neuron 1
    spikey = [profiles{2}];
    noise = [profiles{1}];
    
    % pS = NaN(1,length(profiles));
    % pN = NaN(1,length(profiles));
    
    spike_profs = [];
    noise_profs = [];
    
    
    for i = 1:length(profiles)
        
        pS = corrcoef(spikey, profiles{i});
        pN = corrcoef(noise, profiles{i});
    
        if pS(1,2) > pN(1,2)
            spike_profs = [spike_profs profiles(i)];
        else
            noise_profs = [noise_profs profiles(i)];
    
        end
    
    end
