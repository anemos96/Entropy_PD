%%% Step9: Channel Interpolation %%%

clear all; close all;

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Preprocessing_Output/Step8_Epoch_Rej/'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Preprocessing_Output/Step9_Interpolation/'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'));

% We know that M03 has no rejected channel. We gonna use his chanlocs as a
% refence
EEG_M03 = pop_loadset('filename', 'M03_Epoch_Rej.set', 'filepath', input_folder)
ref_chan_locs = EEG_M03.chanlocs;
n_ref_chan = length(ref_chan_locs);

% Loop over file list
for i = 1:length(file_list)
    file_name = file_list(i).name;

    % Load dataset
    EEG = pop_loadset('filename', file_name, 'filepath', input_folder);

    EEG = pop_interp(EEG, ref_chan_locs, 'spherical');

    % Check that the final channel number is right
    if EEG.nbchan == n_ref_chan
        disp('All good');
    else
        disp('CAUTION')
    end

    % Save
    EEG = pop_saveset(EEG, 'filename', [file_name(1:3) '.set'], 'filepath', output_folder);
end
