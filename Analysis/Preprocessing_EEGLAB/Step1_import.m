%%% Step1: Import raw data on EEGLAB and save .set files %%%
clear all 
close all

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')

eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/missing/'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/missing/Step1_import'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list of all the resting state recordings
file_list = dir(fullfile(input_folder, '*.vhdr'))

for i = 1:length(file_list)

    % Get the file name
    file_name = file_list(i).name

    % Load EEG recording on EEGLAB
    EEG = pop_loadbv(input_folder, file_name);
    
    % Create full path for output files
    [~, baseName, ~] = fileparts(file_name)
    output_file = fullfile(output_folder, [baseName, '.set'])

    % Save recording with .set extension
    pop_saveset(EEG, output_file)
end

disp('All good, carry on :)')