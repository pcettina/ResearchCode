function Build_spikeOnsetProfile_array(RootPath, numchans)

    allChan_Onset = cell(1,numchans);
    allChan_Profiles = cell(1,numchans);
    allChan_Data = cell(1,numchans);

    for i = 1:numchans
        allChan_Onset{i} = load(fullfile(RootPath + "\spikeOnset" + i)).spikeOnset;
        allChan_Profiles{i} = load(fullfile(RootPath + "\profiles" + i)).profiles;

        
    end


    allChan_Data = [allChan_Onset; allChan_Profiles];

    save(fullfile(RootPath + "\allChan_Data"), "allChan_Data");
end




