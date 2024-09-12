function Firing_Rate(RootPath, bool, chan)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here



    spikesIn = load(RootPath).spikes(chan,:);

    onOff = diff(spikesIn, 1,2);
    on = find(onOff(:) < 0); % this will also be your spike onsets. Turn this into a new logical array the same length as spikes
    off = find(onOff(:) > 0);

    

    durations = off-on;

    spikeOnset = on(durations <= 40)+1;

    %generate a boolean for new spikes

    spikes = zeros(1,length(spikesIn));
    spikes(spikeOnset) = 1;


    time_series = (length(spikes) / 20000) * 1E3;

    

    % Sep_bins = NaN(10,ceil(length(spikes)/200));    % Save values of all tests

    if lower(bool) == true
        figure;

        for i = 200:200:2000   % 200 recordings per 10ms window so 2000 in 100ms which is our range 
        
            %spike_set = NaN(i, ceil(length(spikes)/i)); % avoid losing leftover bin space
            
            temp_spikes = [spikes, NaN(1,i-mod(length(spikes), i))]; %reshape so that spikes has extra room to accomodate dividing by i 
            
            spike_set = reshape(temp_spikes, [], i);
    
            spike_sums = sum(spike_set, 2);
            spike_avgs = (spike_sums/(i/200)*10); %Gives in units spikes/ms
    
    
            % binIndices = discretize(spikes, i); % Indexes of all the bins
            % 
            % binAVGS = splitapply(@mean, spikes, binIndices);
            % 
            % Sep_bins(i/200) = binAVGS/20000;
    
           
            subplot(2,5,i/200);
    
            title("BIN size " + i);
    
            plot(1:length(spike_avgs), spike_avgs);  % Time in milliseconds is length of all channel data * init_time frame / init bin_size
    
            % Sep_bins(i/200,:) = spike_avgs;
        end

    elseif lower(bool) == false
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


    else
        print("Invalid Input to Function must be bool: true | false")
    end

   


   