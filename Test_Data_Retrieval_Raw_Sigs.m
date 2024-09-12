function Test_Data_Retrieval_Raw_Sigs(RootPath)  
% Test_Data_Retrieval_Raw_Sigs function takes:
    % RootPath: Path through from Root to RawData folder of specific
    % subject on specific date (0 or 1)
        % 0 = pre task; 1 = during task

%Will want to add ability to:
    % input Path up to CorticalSubcorticalStudy
    % Need to clean up signal to get better representation of activity
        % within the channels


%RootPath = 'C:\Users\patce\Box\Bundy Lab\Processed_Data\CorticalSubcorticalStudy2\CorticalSubcorticalStudy\R20-37\R20-37_2020_06_07_0\RawData\';

freq= 0;  

% Want to check for if user put \ at end of path if not need to adjust

if contains(RootPath{1}(end), "\") == false
    RootPath = strcat(RootPath, "\");
end

% raw_Path = RootPath + "RawData\";

% Commented out to save outputs elsewhere for more secure and less risky
% testing

% filtered_Path = RootPath + "Filtered\";
% CAR_filtered_Path = RootPath + "FilteredCAR\";

chan_ARR = [[]];

Raw_Files = dir(RootPath);


tmp = struct2cell(Raw_Files);
file_names = tmp(1,:);


P1_worked = cell(1,16);       %Know for this that each contains 16 channels 
P2_worked = cell(1,16);       %If want to automate given unknown number of channels then can count total files given deliminator
P3_worked = cell(1,16);

pos_P1 = 1;
pos_P2 = 1;
pos_P3 = 1;

skipped_files = 0;

for i = 1:length(file_names)
    if contains(file_names(i), "P1")   %Check through all file_names to not accept those that do not contain relevant data
        
        file_name = file_names(i);
        output_file_name = "Filtered" + file_name{1}(4:end);
        Full_RootPath_name = append(RootPath, file_name{1});
        [Hd, bpFilt] = Rotation_BandPassFilt();
        filtered_data = filtfilt(bpFilt, load(Full_RootPath_name).data);
        % save(fullfile(filtered_Path, output_file_name), "filtered_data");

        chan_ARR(i-skipped_files,:) = filtered_data;

        


        % CalculateCAR_PT(RootPath +"Filtered", "Filtered_P1_Ch_000");


        %P1_worked{pos_P1} = load(Full_RootPath_name);
        %pos_P1 = pos_P1+ 1;

    % elseif contains(file_names(i), "P2")
    % 
    % 
    %     file_name = file_names(i);
    %     Full_RootPath_name = append(RootPath, file_name{1});
    %     data = load(Full_RootPath_name);
    % 
    %     P2_worked{pos_P2} = data;  
    %     pos_P2 = pos_P2+ 1;
    % 
    % 
    % elseif contains(file_names(i), "P3")
    % 
    %     file_name = file_names(i);
    %     Full_RootPath_name = append(RootPath, file_name{1});
    %     data = load(Full_RootPath_name);
    % 
    %     P3_worked{pos_P3} = data;
    %     pos_P3 = pos_P3+ 1;
    elseif contains(file_names(i), "Info")
        file_name = file_names(i);
        Full_RootPath_name = append(RootPath, file_name{1});
        info = load(Full_RootPath_name).info;
        

        freq = info(1).fs;
        skipped_files = skipped_files + 1;
    else
        skipped_files = skipped_files + 1;
    end

end


CAR_ARR = mean(chan_ARR, 1);

chan_ARR = chan_ARR - CAR_ARR;
% Want to then save new files that are filled with filtered_CAR

% tmp = struct2cell(dir(filtered_Path));
% file_names = tmp(1,:);

figure;

%Preallocate for speed 
rms_arr = NaN(1,length(chan_ARR(1,:)));
curr_thresh = NaN(1,length(chan_ARR(1,:)));
spikes = NaN(1,length(chan_ARR(1,:)));
skipped_files = 3;

% eegplot(chan_ARR(1,:));   For plotting with time series blocks 

for i = 10 % 1:size(chan_ARR, 1)
    % if contains(file_names(i), "P1")   %Check through all file_names to not accept those that do not contain relevant data
        Chan_num = i-skipped_files-1;
        
        arr = chan_ARR(Chan_num+1,:);
        % subplot(4,4,mod(Chan_num+1,17));
        file_name = file_names(i);
        output_file_name = "FilteredCAR" + file_name{1}(9:end);
        % Full_RootPath_name = append(filtered_Path, file_name{1});


       
        subtitle = "Channel " + Chan_num;



        time_points = 1:length(arr);
        time_points = time_points.*1/freq; % Time series over recordings

        % save(fullfile(CAR_filtered_Path, output_file_name), "arr");

        yyaxis left
        plot(time_points,arr);

        hold on

        title(subtitle);

        rms_arr(Chan_num+1) = rms(arr);
        curr_thresh(Chan_num + 1) = rms_arr(Chan_num+1)*3.5;  %rms is the way to get spike threshold 

        %generate a logical array of spikes

        spikes(Chan_num+1,:) = arr < curr_thresh(Chan_num+1);

        yyaxis right

        plot(time_points, spikes(Chan_num+1,:)) % Will want to examine how to change display of spikes

        hold off
    % else
    %     skipped_files = skipped_files + 1;
    % end
end

%Save data as array for easier use 
save(fullfile("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1", "FilteredCAR_arr1"), 'chan_ARR');
save(fullfile("C:\Users\patce\OneDrive\Desktop\LabWork\ResearchCode\Data_Processing\Programs_MATLAB\R20-37_2020_06_07_1", "spikes_arr1"), 'spikes');


% figure;
% 
% 
% 
% 
 %Plot all Channels on single graph
 %Next step preform some type of analysis of similarity and add to graph 
% for i=1:length(P1_worked)
%      % if(mod(i,4))
%      %    subplot(4,4,4); 
%      % else
%     subplot(4,4,mod(i,17));
%      % end
%      % 
%     data = P1_worked{i}.data;
%     time_points = 1:length(data);
% 
%     time_points = time_points.*freq; % Time series over recordings
% 
%     Chan_num = i-1;
%     subtitle = "Channel " + Chan_num;
%     [Hd, bpFilt] = Rotation_BandPassFilt();
%     filtered_data = filtfilt(bpFilt, data);
%     plot(time_points,filtered_data);
%     title(subtitle);
% end