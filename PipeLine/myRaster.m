function myRaster(ReachTimes, GraspTimes, OnsetProfData, all_recorded_data, varargin)

    fs = 20000;
    Channels = 16;
    if ~isempty(varargin)
        fs = varargin{1};
        if length(varargin) > 1
            Channels = varargin{2};
        end
    end

    % GraspTimes - ReachTimes = offSet to 0 when plotting where Grasp
    % occurs within window
    
    trial_starts = zeros(1,size(ReachTimes,1));
    
    log_spike_arr = zeros(1,Channels);
    trial_spikes = cell(13,1);
    
    
    for i = 1:Channels
        figure;
        sgtitle("Channel " + i);
        for j = 1:size(ReachTimes,1)
            trial_starts(1,j) = ReachTimes{j}(1);  
            onSet_Data = OnsetProfData(1,i);
            log_spike_arr(onSet_Data{1}) = 1;
    
            onSet_Data = onSet_Data{1};
            
            % onSet_Data_seconds = (seconds(onSet_Data/fs))';
            % trial_spikes = vertcat(trial_spikes,onSet_Data_seconds);
            % trials = vertcat(trials, ones(size(onSet_Data,1))*j);
    
            chan_data = all_recorded_data(i,:);
            chan_spikes = zeros(1,size(chan_data,2));
            chan_spikes(onSet_Data) = 1;
    
            mov_on = ReachTimes{j}(1);
            mov_on_conv = mov_on * 20000; % Convert to number of detections based on fs
    
            pre_mov = floor(mov_on_conv - 20000); % For one second prior to movement onset
            post_mov = floor(mov_on_conv + 30000)-1; % For one and half sec after movement onset
    
            trial_spikes{j} = chan_spikes(pre_mov:post_mov); % Get spike data between the time interval of trial
            
            
            subplot(size(ReachTimes,1),1,j);
           
            ylabel("Trial " + j);
            xlim([-1 ((50000/fs)-1)]);  %Put into time in seconds for graphing and set onset at 0
            
            ylim([0 1]);
            if j == size(ReachTimes,1)
                xlabel("Time (s)")
            else
                set(gca, 'XTick', [], 'XColor', 'none');
            end
            for p = 1:length(trial_spikes{j})
                
                if trial_spikes{j}(p) == 1
                    xline((p/fs)-1, 'r');
    
                end
    
            end
            
            for attempt = 1:length(ReachTimes{j})
                xline(ReachTimes{j}(attempt)-trial_starts, 'Color', [0,0,0], 'LineWidth',2); % Black Lines for Reach Onset
            
            end
            
            
            for attempt = 1:length(GraspTimes{j})
                xline(GraspTimes{j}(attempt)-trial_starts, 'Color',[0,0,1], 'LineWidth',2); % Blue for Grasp Onset
            
            end
            

        end
    

            
    end




end

