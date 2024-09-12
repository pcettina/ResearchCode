function Stacked_Channel_Plots(pre_RootPath,dur_RootPath)  
% Stacked_Channel_Plots function takes:
    % pre_RootPath: Path through from Root to RawData folder of specific
        % subject on specific date 1 = during task
    % pre_RootPath: Path through from Root to RawData folder of specific
        % subject on specific date 0 = pre task

%Will want to add ability to:
    %input Path up to CorticalSubcorticalStudy


%RootPath = 'C:\Users\patce\Box\Bundy Lab\Processed_Data\CorticalSubcorticalStudy2\CorticalSubcorticalStudy\R20-37\R20-37_2020_06_07_0\RawData\';

freq= 0;  

% Want to check for if user put \ at end of path if not need to adjust

if contains(pre_RootPath{1}(end), "\") == false
    pre_RootPath = strcat(pre_RootPath, "\");
end
if contains(dur_RootPath{1}(end), "\") == false
    dur_RootPath = strcat(dur_RootPath, "\");
end

dur_files = dir(dur_RootPath);
dur_tmp = struct2cell(dur_files);
dur_file_names = dur_tmp(1,:);


dur_P1_worked = cell(1,16);       %Know for this that each contains 16 channels 

pre_files = dir(pre_RootPath);
pre_tmp = struct2cell(pre_files);
pre_file_names = pre_tmp(1,:);


pre_P1_worked = cell(1,16);       %Know for this that each contains 16 channels 


pos_P1 = 1;

for i = 1:length(pre_file_names)
    if contains(pre_file_names(i), "P1")   %Check through all file_names to not accept those that do not contain relevant data
        
        file_name = pre_file_names(i);
        Full_RootPath_name = append(pre_RootPath, file_name{1});
        
        pre_P1_worked{pos_P1} = load(Full_RootPath_name);
        pos_P1 = pos_P1+ 1;

    elseif contains(pre_file_names(i), "Info")
        file_name = pre_file_names(i);
        Full_RootPath_name = append(pre_RootPath, file_name{1});
        info = load(Full_RootPath_name).info;
        

        freq = info(1).fs;

    end

end

pos_P1 = 1;

for i = 1:length(dur_file_names)
    if contains(dur_file_names(i), "P1")   %Check through all file_names to not accept those that do not contain relevant data
        
        file_name = dur_file_names(i);
        Full_RootPath_name = append(dur_RootPath, file_name{1});
        
        dur_P1_worked{pos_P1} = load(Full_RootPath_name);
        pos_P1 = pos_P1+ 1;

    elseif contains(dur_file_names(i), "Info")
        file_name = dur_file_names(i);
        Full_RootPath_name = append(dur_RootPath, file_name{1});
        info = load(Full_RootPath_name).info;
        

        freq = info(1).fs;

    end

end

%Plot all Channels on single graph
%Next step preform some type of analysis of similarity and add to graph 
% More points during recording than pre recording is this an issue???
for i=1:length(pre_P1_worked)
    figure;
    pre_data = pre_P1_worked{i}.data;
    dur_data = dur_P1_worked{i}.data;

    pre_all_points = 1:length(pre_data);
    pre_all_points = pre_all_points.*freq;

    dur_all_points = 1:length(dur_data);
    
    dur_all_points = dur_all_points.*freq;
    plot(pre_all_points,pre_data);
    hold on;
    plot(dur_all_points, dur_data);
    hold off;
end
