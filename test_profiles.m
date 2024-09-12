clear all
close all

RootPath = "C:\Users\patce\Box\Bundy Lab\Processed_Data\Pat_Processed_CorticalSubcortical2\R20-37";
addpath('C:\Users\patce\Box\Bundy Lab\Processed_Data\Pat_Processed_CorticalSubcortical2\R20-37');

Build_spike_profiles('spikes_arr.mat', 'FilteredCAR_arr.mat', 1);