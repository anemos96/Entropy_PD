%%% Step7: Epoching. Epoching (4s non everlapping windows) and CAR %%%

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step6_postICA_rej'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step7_Epoching'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'))

% Define chans to be excluded from CAR
excl_chans = {'Ref', 'RM', 'VEOGR-', 'HEOG'}

% Loop over files
for i = 1:length(file_list)
    file_name = file_list(i).name

    % Load dataset
    EEG = pop_loadset('filename', file_name, 'filepath', input_folder)

    % Define all channels' labels
    allLabels = {EEG.chanlocs.labels}

    % Find indices of chans to be excluded from CAR
    [found, idx] = ismember(excl_chans, allLabels)
    excl_idx = idx(found)

    % Common average reference
    EEG = pop_reref(EEG, [], 'interpchan', 'off', 'exclude', excl_idx)

    % Epoching
    EEG = eeg_regepochs(EEG, 'recurrence', 10, 'limits', [0 4], 'eventtype', 'event') % 4s non overlapping epochs.
                                                                                         % use this func for RS data (where there are no
                                                                                         % events to lock epochs at
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', 're-ref_epoched')
    
    % Save
    EEG = pop_saveset(EEG, 'filename', [file_name(1:end-16) 'epoched.set'], 'filepath', output_folder)

end

disp('All good, carry on :)')
