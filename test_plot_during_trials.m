% Get spikes for channels within the trial group & plot spike rate
% build spike profiles around the onset 
% Compare spike profiles by connecting peak putting the spikes in phase
%   with eachother and then doing simple correlations



close all;
clear all;


figure;

chan_ARR = load("FilteredCAR_arr1.mat").chan_ARR;

%Preallocate for speed 
rms_arr = NaN(16,1);
curr_thresh = NaN(16,1);
spikes = NaN(1,length(chan_ARR(1,:)));

for i = 1:size(chan_ARR,1)
    % if contains(file_names(i), "P1")   %Check through all file_names to not accept those that do not contain relevant data
        Chan_num = i-1;
        
        arr = chan_ARR(Chan_num+1,:);
        % subplot(4,4,mod(Chan_num+1,17));
        % Full_RootPath_name = append(filtered_Path, file_name{1});


       
        subtitle = "Channel " + Chan_num;



        time_points = 1:length(arr);
        % time_points = time_points.*1/freq; % Time series over recordings

        % save(fullfile(CAR_filtered_Path, output_file_name), "arr");

        yyaxis left
        plot(time_points,arr);

        hold on

        title(subtitle);

        rms_arr(Chan_num+1) = rms(arr);
        disp(rms_arr(Chan_num+1));
        
        curr_thresh(Chan_num + 1) = rms_arr(Chan_num+1)*3.5; 
        disp(curr_thresh(Chan_num+1));
        %rms is the way to get spike threshold 
        %generate a logical array of spikes
        
        spikes(Chan_num+1,:) = arr < curr_thresh(Chan_num+1);

        yyaxis right

        plot(time_points, spikes(Chan_num+1,:)) % Will want to examine how to change display of spikes

        hold off
    % else
    %     skipped_files = skipped_files + 1;
    % end
end


% save(fullfile("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1", "spikes_arr1"), 'spikes', '-v7.3');

%% 
for chan = 4:16
    
    spikesIn = load("spikes_arr1.mat").spikes(chan,:);
    filteredData = chan_ARR(chan,:);
    
    onOff = diff(spikesIn);
    on = find(onOff < 0); % this will also be your spike onsets. Turn this into a new logical array the same length as spikes
    off = find(onOff > 0);
    
    durations = off-on;
    
    spikeOnset = on(durations <= 40)+1; % We are checking for durations of 2ms
    
    %generate a boolean for new spikes
    
    spikes = zeros(1,length(spikeOnset));
    spikes(spikeOnset) = 1;
    
    profiles = cell(length(spikeOnset),1); %40 is the duration of entire spike profile
    
    
    %Gather profiles by taking data 0.5ms prior and 1.5ms post onset
    for i = 1:length(spikeOnset)
        
        %ensure we do not go out of indice bounds with the max and min functions
        startIndex = max(spikeOnset(i)-10, 1);
        endIndex = min(spikeOnset(i)+30, length(filteredData));
    
        profiles{i} = filteredData(startIndex:endIndex);
    
        
    end
    
    save("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1" + "\spikeOnset" + chan, "spikeOnset")
    
    save("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1" + "\profiles" + chan, "profiles")
end
    %% 
    

figure;

    % Stepwise averaging for smoother curve of average
count = 1;
for i = 20000   % 200 recordings per 10ms window so 2000 in 100ms which is our range 
    
   
    temp_spikes = [spikes, NaN(1,i-mod(length(spikes), i))];
    spike_avgs = NaN(1,(length(temp_spikes)/i) - i); 


    for j = 1:length(temp_spikes)-i
        
        %spike_avgs(j) = sum(temp_spikes(j:j+i))/((i/200)*10);


        %Phils version 1

        %tempWindow = temp_spikes(j:j+i);
        %tempWindow(isnan(tempWindow)) = [];
        %spike_avgs(j) = sum(temp_spikes(j:j+i))/((i/200)*10);

        %Alt version
        spike_avgs(count,j) = sum(temp_spikes(j:j+i), "omitnan");
        
    
    end
   
    % subplot(2,5,i/200);
    % 
    % subtitle("Spike Avg. Across " + (i/200)*10 + "ms");
    % hold on 
    plot(1:length(spike_avgs), spike_avgs);  % Right now just graphing across number of points but could convert to time 
    hold off
    % Sep_bins(i/200,:) = spike_avgs;

end