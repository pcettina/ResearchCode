function myAvgFiringRate(ReachTimes, GraspTimes, OnsetProfData, all_recorded_data, varargin)

    fs = 20000;
    Channels = 16;

    chan_avgs = zeros(Channels,241); % 241 points because that is number of bins the data is reduced to
    chan_avgs_Gsmoothed = zeros(Channels,241); 

    if ~isempty(varargin)
        fs = varargin{1};
        if length(varargin) > 1
            Channels = varargin{2};
        end
    end

    trials = length(ReachTimes);
    trial_starts = zeros(1,size(ReachTimes,1));
    
    log_spike_arr = zeros(1,Channels);
    trial_spikes = cell(13,1);
    
    Gsmoothed_yvals = zeros(trials,241);

    % Create a Gaussian kernel for smoothing
    sigma = 2; % Standard deviation for Gaussian (controls smoothness)
    kernel_size = 50; % Kernel size (make sure this is large enough to cover smoothing)
    x = linspace(-kernel_size/2, kernel_size/2, kernel_size);
    gaussian_kernel = exp(-x.^2 / (2*sigma^2)); % Gaussian formula
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel); % Normalize the kernel
    
    figure;
    sgtitle("Firing Rates Across Channels");
    ylabel("Firing Rate (Spikes/sec)");
    xlabel("Time(ms)");
    xline(0, 'Color', [0,0,0], 'LineWidth',2);
    hold on;

    
    for i = 1:Channels
        % figure;
        % sgtitle("Channel " + i);
        xvals = zeros(trials,241);
        yvals = zeros(trials,241);
        for j = 1:size(ReachTimes,1)
            trial_starts(1,j) = ReachTimes{j}(1); 
            onSet_Data = OnsetProfData(1,i);
            log_spike_arr(onSet_Data{1}) = 1;
    
            onSet_Data = onSet_Data{1};
            
            
            chan_data = all_recorded_data(i,:);
            chan_spikes = zeros(1,size(chan_data,2));
            chan_spikes(onSet_Data) = 1;
    
            mov_on = ReachTimes{j}(1);
            mov_on_conv = mov_on * 20000; % Convert to number of detections based on fs
    
            pre_mov = floor(mov_on_conv - 20000); % For one second prior to movement onset
            post_mov = floor(mov_on_conv + 30000)-1; % For one and half sec after movement onset
    
            trial_spikes{j} = chan_spikes(pre_mov:post_mov); % Get spike data between the time interval of trial
            
            for bin = 0:1:240 % 240 is calculated number of bins given a 100ms sampling window & 10s lag w/in 2.5s trial window
                front = (bin*2*100)+1;
                back = front+2000-1;

                samp_window = trial_spikes{j}(front:back);
                samp_sum = sum(samp_window); % tot num of spikes in sample_window
                samp_avg = samp_sum*10; % in readings not seconds so mult by 10 for seconds
                xvals(j,bin+1) = front/20; % convert to ms
                yvals(j,bin+1) = samp_avg; 

                
            end

            
            Gsmoothed_yvals(j,:) = conv(yvals(j,:), gaussian_kernel, 'same');


            %%% For wanting to plot each trial of a channel 
            
            % subplot(size(ReachTimes,1),1,j);
            % 
            % ylabel("Trial " + j);
            % xlim([-1 ((50000/fs)-1)]);  %Put into time in seconds for graphing and set onset at 0
            % 
            % if j == size(ReachTimes,1)
            %     xlabel("time (ms)")
            % else
            %     set(gca, 'XTick', [], 'XColor', 'none');
            % end

            % plot(xvals(j,:)-1000, yvals(j,:), 'r-');
            % hold on;
            % xline(0, 'Color', [0,0,0], 'LineWidth',2);
            % 
            % for attempt = 1:length(ReachTimes{j})
            %     xline(ReachTimes{j}(attempt)-trial_starts(j), 'Color', [0,0,0], 'LineWidth',2); % Black Lines for Reach Onset
            % 
            % end
            % 
            % 
            % for attempt = 1:length(GraspTimes{j})
            %     xline(GraspTimes{j}(attempt)-trial_starts(j), 'Color',[0,0.5,1], 'LineWidth',2); % Blue for Grasp Onset
            % 
            % end
    
        end
        

        chan_avgs(i,:) = mean(yvals);
        chan_avgs_Gsmoothed(i,:) = mean(Gsmoothed_yvals);
        % Plot each channel individually 
        % figure;
        % xlim([-1000 (((50000/fs)*1000)-1000)]);
        % sgtitle("Average Firing Rate Across Channel " + i);
        % plot(mean(xvals)-1000, chan_avgs(i,:), 'r-');
        % hold on;
        % plot(mean(xvals)-1000, chan_avgs_Gsmoothed(i,:), 'Color', [0 0.5 1], LineStyle='-');



        % Plot each channels average on top of eachother
        % yyaxis right;
        plot(mean(xvals)-1000,chan_avgs_Gsmoothed(i,:));
        % yyaxis left;
        % plot(mean(xvals)-1000,chan_avgs(i,:));
        % legend;
        % ylabel("Firing Rate (Spikes/sec)");
        % xlabel("Time(ms)");
        % xline(0, 'Color', [0,0,0], 'LineWidth',2);
        hold on;
        

    
    end


    legend("Initial Grasp Onset", "Channel 1","Channel 2", "Channel 3","Channel 4", "Channel 5", "Channel 6", "Channel 7", "Channel 8", "Channel 9", "Channel 10", "Channel 11", "Channel 12", "Channel 13", "Channel 14", "Channel 15","Channel 16");

    

    % Apply PCA to the data matrix
    [coeff, score, latent, tsquared, explained, mu] = pca(chan_avgs_Gsmoothed');
    
    % 'coeff' contains the principal components (eigenvectors)
    % 'score' contains the projected data onto these components
    % 'explained' tells you how much variance each principal component explains
    
    % Plot variance explained by each component
    figure;
    plot(cumsum(explained), 'o-', 'LineWidth', 2);
    xlabel('Principal Component');
    ylabel('Cumulative Variance Explained (%)');
    title('Variance Explained by Principal Components');

    % Plot the data projected onto the first two principal components
    figure;
    plot(score(:,1), score(:,2), '.-');
    xlabel('PC1');
    ylabel('PC2');
    title('PCA Projection of Neural Data');



end