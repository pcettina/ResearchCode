function [profiles] = Build_spike_profiles(RootPathLogical, RootPathData, chan)

    spikesIn = load(RootPathLogical).spikes(chan,:);
    filteredData = load(RootPathData).chan_ARR(chan,:);

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

    save("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB" + "\profiles" + chan, "profiles")
        


           