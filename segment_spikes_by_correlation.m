function segment_spikes_by_correlation(spikeProfiles, bestProfSpike, bestProfNoise)
    
    profiles = load(spikeProfiles).profiles;
        
    
    % compute correlation of spikes to the most noisy and best looking
    % spike 

    
    spikey = [bestProfSpike];
    noise = [bestProfNoise];
    
    % pS = NaN(1,length(profiles));
    % pN = NaN(1,length(profiles));
    
    % Initialize empty cell arrays for each category
    spike_profs = {}; % High corr. & p-val to only spike
    noise_profs = {}; % High corr. & p-val to only noise
    DHDH_profs = {};  % High corr. & p-val to both 
    
    uncorS_profs = {}; % corr < 0.6 but high p for spike
    uncorN_profs = {}; % corr < 0.6 but high p for noise
    
    highcorlowpS_profs = {}; % corr > 0.6 but p > 0.05 spike
    highcorlowpN_profs = {}; % corr > 0.6 but p > 0.05 noise
    
    unchar_profs = {}; % Fit no group above
    
    sig_val = 0.025;
    cor_val = 0.9;
    
    % Iterate over each profile and compute correlations
    for i = 1:length(profiles)
        % Calculate correlation and p-values for spike and noise
        [rhoS, pS]  = corrcoef(spikey, profiles{i});
        rhoS = rhoS(1, 2); % Extract correlation coefficient
        pS = pS(1, 2);     % Extract p-value
        
        [rhoN, pN] = corrcoef(noise, profiles{i});
        rhoN = rhoN(1, 2); % Extract correlation coefficient
        pN = pN(1, 2);     % Extract p-value
        
        % Conditions for high correlation and significant p-values
        if rhoS > cor_val || rhoN > cor_val
            if pS < sig_val && pN < sig_val
                if rhoS > cor_val && rhoN > cor_val
                    DHDH_profs = [DHDH_profs profiles{i}];  % Both high correlation
                elseif rhoN > cor_val
                    noise_profs = [noise_profs profiles{i}]; % Only noise high correlation
                else
                    spike_profs = [spike_profs profiles{i}]; % Only spike high correlation
                end
            elseif pS < sig_val
                % High correlation for spike only (p significant)
                if rhoS > cor_val
                    spike_profs = [spike_profs profiles{i}];
                elseif rhoS < cor_val
                    uncorS_profs = [uncorS_profs profiles{i}];
                end
            elseif pN < sig_val
                % High correlation for noise only (p significant)
                if rhoN > cor_val
                    noise_profs = [noise_profs profiles{i}];
                elseif rhoN < cor_val
                    uncorN_profs = [uncorN_profs profiles{i}];
                end
            end
        else
            % Check conditions for uncorrelated but high p-values
            if rhoS < cor_val && pS < sig_val
                uncorS_profs = [uncorS_profs profiles{i}];
            elseif rhoN < cor_val && pN < sig_val
                uncorN_profs = [uncorN_profs profiles{i}];
            elseif rhoS > cor_val && pS > sig_val
                highcorlowpS_profs = [highcorlowpS_profs profiles{i}];
            elseif rhoN > cor_val && pN > sig_val
                highcorlowpN_profs = [highcorlowpN_profs profiles{i}];
            else
                % Fits no other group
                unchar_profs = [unchar_profs profiles{i}];
            end
        end
    end

