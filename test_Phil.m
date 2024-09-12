clear all
close all

RootPath = "C:\Users\patce\Box\Bundy Lab\Processed_Data\Pat_Processed_CorticalSubcortical2\R20-37";
addpath('C:\Users\patce\OneDrive\Desktop\ResearchCode\Data_Processing\Programs_MATLAB');
addpath('C:\Users\patce\Box\Bundy Lab\Code\Data Processing');

Average_spikes_profiles_Updated('spikes_arr.mat', false,6);