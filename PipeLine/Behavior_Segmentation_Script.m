

RawPath = "C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1";
BehaviorTimes = load("C:\Users\patce\Box\Bundy Lab\Processed_Data\CorticalSubcorticalStudy2\CorticalSubcorticalStudy\R20-37\R20-37_2020_06_07_1\BehaviorTimes.mat");

spikeOnset_6 = load(fullfile(RawPath + "\spikeOnset6")).spikeOnset;
profiles_6 = load(fullfile(RawPath + "\profiles6")).profiles;


ReachTimes = BehaviorTimes.ReachTimes;
GraspTimes = BehaviorTimes.GraspTimes;


% Want to check 1sec before movement onset and 1.5sec after and gather all
% profiles in that window 

% For ReachTimes

% spike_indices = cell(1,length(ReachTimes));  %indices of where the spikes are at within each reach range
% rel_profiles = cell(1,length(ReachTimes)); %profiles that correspond to those spikes for each duration range


for i = 1:length(ReachTimes)
    mov_on = ReachTimes{i}(1);
    mov_on_conv = mov_on * 20000; % Convert to number of detections based on fs

    pre_mov = floor(mov_on_conv - 20000); % For one second prior to movement onset
    post_mov = ceil(mov_on_conv + 30000); % For one and half sec after movement onset

    spike_indices{i} = find(spikeOnset_6 >= pre_mov & spikeOnset_6 <= post_mov);
    % disp(profiles_6{spike_indices{i}});
    for j = 1:length(spike_indices{i})
        
        rel_profiles{i,j} = profiles_6{spike_indices{i}(j)};
    
    end
   


end

%% 
%Need to figure out how to index into column spots inside this cell matrix
figure; 

for i = 1:size(rel_profiles, 1)

    
    ind_prof_data = [];
    for j = 1:size(rel_profiles,2)

            subplot(4,4,i);
            title("Profiles During Trial " + i)
            ind_prof_data = rel_profiles{i,j};
            plot(rel_profiles{i,j},'Color', [.7,.7,.7,0.3]);
          
            hold on

    end

end


%% Plot Ind. Channel & Spike data for trials

%When put into own function for this activity will want to take RootPath as
%load argument for data 
allChan_Data = load("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1\allChan_Data.mat").allChan_Data;
all_recorded_data = load("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1\FilteredCAR_arr1.mat").chan_ARR;
all_recorded_spikes = load("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1\spikes_arr1.mat").spikes;
close all;
% for i = 1:length(ReachTimes)  %Gather all data within the necessary Reach Time frame 
    % figure;
    % title("Trial " + i);

    %Plot all of the data w/ spikes
    % for p = 1:size(allChan_Data, 2)
    % 
    %     subplot(8,2,mod(p,17));
    %     onSet_Data = allChan_Data(1,p);
    %     onSet_Data = onSet_Data{1};
    %     profiles_Data = allChan_Data(2,p);
    %     profiles_Data = profiles_Data{1};
    % 
    % 
    %     chan_data = all_recorded_data(p,:);
    %     chan_spikes = zeros(1,size(chan_data,2));
    %     chan_spikes(onSet_Data) = 1;
    % 
    % 
    %     mov_on = ReachTimes{i}(1);
    %     mov_on_conv = mov_on * 20000; % Convert to number of detections based on fs
    % 
    %     pre_mov = floor(mov_on_conv - 20000); % For one second prior to movement onset
    %     post_mov = floor(mov_on_conv + 30000); % For one and half sec after movement onset
    % 
    %     % spike_indices{i} = find(onSet_Data >= pre_mov & onSet_Data <= post_mov);
    % 
    %     subtitle = "Channel " + p;
    % 
    %     trial_data = chan_data(pre_mov:post_mov); % Get the data between the time interval of the trial
    %     trial_spikes = chan_spikes(pre_mov:post_mov); % Get spike data between the time interval of trial
    % 
    % 
    %     yyaxis left;
    %     plot(pre_mov:post_mov,trial_data);
    %     xline(mov_on_conv, 'Color',[0,0,0], LineWidth=2);
    % 
    %     hold on;
    % 
    %     title(subtitle);
    % 
    %     yyaxis right;
    % 
    %     plot(pre_mov:post_mov, trial_spikes);
    %     axis tight;
    % 
    %     hold off;
    % 
    %     % for j = 1:length(spike_indices{i})
    %     % 
    %     %     profiles_Data{i,j} = profiles_Data{spike_indices{i}(j)};
    %     % 
    %     % end
    % 
    % 
    % end

    % figure;
    % sgtitle("Trial " + i);
  

    % Raster Plots 
    % for p = 1:size(allChan_Data, 2)
    % 
    %     subplot(16,1,p);
    %     onSet_Data = allChan_Data(1,p);
    %     onSet_Data = onSet_Data{1};
    %     profiles_Data = allChan_Data(2,p);
    %     profiles_Data = profiles_Data{1};
    % 
    % 
    %     chan_data = all_recorded_data(p,:);
    %     chan_spikes = zeros(1,size(chan_data,2));
    %     chan_spikes(onSet_Data) = 1;
    % 
    % 
    %     mov_on = ReachTimes{i}(1);
    %     mov_on_conv = mov_on * 20000; % Convert to number of detections based on fs
    % 
    %     pre_mov = floor(mov_on_conv - 20000); % For one second prior to movement onset
    %     post_mov = floor(mov_on_conv + 30000); % For one and half sec after movement onset
    % 
    %     % spike_indices{i} = find(onSet_Data >= pre_mov & onSet_Data <= post_mov);
    % 
    % 
    % 
    %     trial_data = chan_data(pre_mov:post_mov); % Get the data between the time interval of the trial
    %     trial_spikes = chan_spikes(pre_mov:post_mov); % Get spike data between the time interval of trial
    % 
    % 
    % 
    %     ylabel("Channel " + p)
    % 
    %     plot(pre_mov:post_mov, trial_spikes);
    %     hold on;
    % 
    %     xline(mov_on_conv, 'Color',[0,0,0], LineWidth=2);
    %     if p == size(allChan_Data,2)
    %         xlabel('Duration (in points colleceted)')
    %     end
    %     axis tight;
    %     hold off;
    % 
    % 
    % 
    % end


    % figure;
    % 
    % %Stepwise averaging for smoother curve of average
    % count = 1;
    % for wind = 20000   % 200 recordings per 10ms window so 2000 in 100ms which is our range 
    % 
    % 
    %     temp_spikes = [spikes, NaN(1,wind-mod(length(spikes), wind))]; %Make spikes array divisible by window size
    %     spike_avgs = NaN(1,(length(temp_spikes)/wind) - wind); 
    % 
    % 
    %     for j = 1:length(temp_spikes)-wind
    % 
    %         spike_avgs(j) = sum(temp_spikes(j:j+wind))/((wind/200)*10);
    % 
    % 
    %         % Phils version 1
    %         % 
    %         % tempWindow = temp_spikes(j:j+i);
    %         % tempWindow(isnan(tempWindow)) = [];
    %         % spike_avgs(j) = sum(temp_spikes(j:j+i))/((i/200)*10);
    % 
    %         % Alt version
    %         spike_avgs(count,j) = sum(temp_spikes(j:j+wind), "omitnan");
    % 
    % 
    %     end
    % 
    %     subplot(2,5,wind/200);
    % 
    %     subtitle("Spike Avg. Across " + (wind/200)*10 + "ms");
    %     hold on 
    %     plot(1:length(spike_avgs), spike_avgs);  % Right now just graphing across number of points but could convert to time 
    %     hold off
    %     Sep_bins(wind/200,:) = spike_avgs;
    % end
        
% end


%% Plot Raster for each Channel Across Trials & Firing Rate for Activity Window
close all;
fs = 20000;
trial_starts = zeros(1,size(ReachTimes,1));

log_spike_arr = zeros(1,size(all_recorded_data,2));


for i = 1:size(all_recorded_data,1)
    figure;
    sgtitle("Channel " + i);
    for j = 1:size(ReachTimes,1)
        trial_starts(1,j) = ReachTimes{j}(1);  
        onSet_Data = allChan_Data(1,i);
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
        xlim([-1 ((50000/20000)-1)]);  %Put into time in seconds for graphing and set onset at 0
        
        ylim([0 1]);
        if j == size(ReachTimes,1)
            xlabel("Recording")
        else
            set(gca, 'XTick', [], 'XColor', 'none');
        end
        for p = 1:length(trial_spikes{j})
            
            if trial_spikes{j}(p) == 1
                xline((p/20000)-1, 'r');

            end

        end

    end

    % trial_starts = seconds(trial_starts);
    % s = spikeRasterPlot(trial_spikes(2:end), trials(2:end));
    % s.AlignmentTimes = trial_starts;

    % plot(xPoints, yPoints);

end

%% Test myRaster

close all;
myRaster(ReachTimes, GraspTimes, allChan_Data, all_recorded_data);


%% Firing Rate across trials for a channel

% close all;
myAvgFiringRate(ReachTimes, GraspTimes, allChan_Data, all_recorded_data);