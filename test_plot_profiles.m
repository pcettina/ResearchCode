close all;
clear all;
for chan = 6
    profiles = load("R20-37_2020_06_07_1\profiles"+ chan +".mat").profiles;
    
    figure;
    title("Channel " + chan + " Spikes")
    xline(10, 'r', 'LineWidth', 2);
    for i = 1:length(profiles)
        
        hold on;
    
        timeOffset_prev = find(profiles{max(i-1,1)} == max(profiles{max(i-1,1)}));
        timeOffset_cur = find(profiles{i} == max(profiles{i}));
    
        % Peak Alignment 
        profiles{i} = circshift(profiles{i}, timeOffset_prev-timeOffset_cur);
        
        % Baseline Correction
        profiles{i} = profiles{i} - profiles{i}(1,1);
        
        plot(profiles{i},'Color',[0,0,0,0.3]);
        hold off;
    end
    
    
    % compute correlatin of data to the first spike... 
    % say spike 1 == neuron 1
    spikey = [profiles{2}];
    noise = [profiles{1}];
    
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
    
    sig_val = 0.05;
    cor_val = 0.9;
    
    
    % Iterate over each profile and compute correlations
    for i = 1:length(profiles)
        if(length(profiles{i}) ~= 41)
            profiles{i} = [profiles{i} zeros(1,41-length(profiles{i}))];
        end
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
                    noise_profs{end+1,1} = profiles{i};
                    noise_profs{end,2} = rhoN; % Only noise high correlation
                else
                    spike_profs{end+1,1} = profiles{i};
                    spike_profs{end,2} = rhoS;  % Only spike high correlation
                end
            elseif pS < sig_val
                % High correlation for spike only (p significant)
                if rhoS > cor_val
                    spike_profs{end+1,1} = profiles{i};
                    spike_profs{end,2} = rhoS; 
                elseif rhoS < cor_val
                    % uncorS_profs = [uncorS_profs profiles{i}];
                    spike_profs{end+1,1} = profiles{i};
                    spike_profs{end,2} = rhoS; 
                end
            elseif pN < sig_val
                % High correlation for noise only (p significant)
                if rhoN > cor_val
                    noise_profs{end+1,1} = profiles{i};
                    noise_profs{end,2} = rhoN;
                elseif rhoN < cor_val
                    % uncorN_profs = [uncorN_profs profiles{i}];
                    noise_profs{end+1,1} = profiles{i};
                    noise_profs{end,2} = rhoN;
                end
            end
        else
            % Check conditions for uncorrelated but high p-values
            if rhoS < cor_val && pS < sig_val
                spike_profs{end+1,1} = profiles{i};
                spike_profs{end,2} = rhoS; 
            elseif rhoN < cor_val && pN < sig_val
                noise_profs{end+1,1} = profiles{i};
                noise_profs{end,2} = rhoN;
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
    
    
    [~, idx] = sort(cell2mat(spike_profs(:, 2)), 'descend');
    spike_profs = spike_profs(idx, :);
    
    % Seed is initial spike profile and here we want to further correct spike
    % profile by computing the sum/mean of delt. between points
    seed_diff_sums = zeros(1, length(spike_profs));
    seed_diff_means = zeros(1, length(spike_profs));
    
    for i = 1:length(spike_profs)
        seed_diff_sums = sum(abs(spike_profs{1,1} - spike_profs{i,1}));
        spike_profs{i, 3} = seed_diff_sums;
    end
    
    for i = 1:length(spike_profs)
        seed_diff_means = mean(abs(spike_profs{1,1} - spike_profs{i,1}));
        spike_profs{i, 4} = seed_diff_means;
    end
    
    
    
    % Graphing the correlation v. the delta between each data point of
    % seed-spikes & plotting the sum of those differences
    figure; 
    
    xlabel("rho");
    ylabel("delta");
    title("Correlation v. Sum o Difference Channel " + chan);
    hold on;
    for i = 1:length(spike_profs)
        
        plot(spike_profs{i,2}, spike_profs{i,3}, '-o');
    
    end
    ylim([0,10000]);
    set(gca, "XDir", "reverse");
    
    
    
    figure; 
    
    goodlookin_spikes = [[]];
    hold on;
    num_same_spike = 0;
    for i = 1:length(spike_profs)
        if(spike_profs{i,3} < 1200)
            num_same_spike = num_same_spike+1;
            plot(spike_profs{i,1}, 'Color', [.7,.7,.7,0.3]);
            goodlookin_spikes = [goodlookin_spikes; spike_profs{i,1}];
    
        end
     
    end

    plot(mean(goodlookin_spikes), 'Color', [0,0,0], 'LineWidth',2);
    title("SpikesClust1 <1200 Sum Channel " + chan);
    caption = "number of spikes " + num_same_spike;
    text(22, -200, caption);

end

%% 


% Graphing the correlation v. the delta between each data point of
% seed-spikes & plotting the mean of those differences
figure; 

xlabel("rho");
ylabel("delta");
title("Correlation v. Mean o Difference");
hold on;
for i = 1:length(spike_profs)
    
    plot(spike_profs{i,2}, spike_profs{i,4}, '-o');
  
end
ylim([0,200]);
set(gca, "XDir", "reverse");


% figure;
% for i = 1:length(spike_profs)
%     title("Spikes")
%     plot(spike_profs{i});
%     hold on;
% 
% end
% 
% figure;
% for i = 1:length(noise_profs)
%     title("Noise")
%     plot(noise_profs{i});
%     hold on;
% 
% end
% 
% figure;
% for i = 1:length(DHDH_profs)
%     title("High cor Sig p for Both")
%     plot(DHDH_profs{i});
%     hold on;
% 
% end
% 
% 
% figure;
% xline(10, 'r', 'LineWidth', 2);
% for i = 1:length(shared_profiles)
% 
%     hold on;
% 
%     % timeOffset_prev = find(shared_profiles{max(i-1,1)} == max(shared_profiles{max(i-1,1)}));
%     % timeOffset_cur = find(shared_profiles{i} == max(shared_profiles{i}));
%     % 
%     % 
%     % shared_profiles{i} = circshift(shared_profiles{i}, timeOffset_prev-timeOffset_cur);
% 
%     plot(shared_profiles{i});
%     hold off;
% end
% 
% 
% 
% 
% 
% corrMatrix = corr(profiles');
% 
% figure;
% imagesc(corrMatrix);
% colorbar;







