%%% Step8: Epoch Rejection. Reject epochs exceeding +/-100uV and save corresponding indices %%%

%%% Step8: Epoch Rejection. Reject epochs exceeding +/-100uV and save corresponding indices %%%

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step7_Epoching'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step8_Epoch_rej'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'));

for i = 1:length(file_list)
    file_name = file_list(i).name;

    % Load dataset
    EEG = pop_loadset('filename', file_name, 'filepath', input_folder);

    % Find epochs exceeding +/-100 uV
    EEG = pop_eegthresh(EEG, ...
        1, ... %Epoching on the raw data not the ICs
        [1:EEG.nbchan-4], ... %Channels to consider (exclude last 4 chans)
        -100, ... %low threshold
        100, ... %high threshold
        0, ... %epoch start time
        3.996, ... %epoch end time
        1, ... %superpose
        0); %do not automatically reject flagged components
    
    % Get indices of rejected epochs
    rejected_epochs = find(EEG.reject.rejthresh);
    
    if ~isempty(rejected_epochs)
        % Reject marked epochs
        EEG = pop_rejepoch(EEG, rejected_epochs, 0);

        % Save rejected epochs' indices in a subject-specific file
        csvwrite(fullfile(output_folder, [file_name(1:end-12) '_Rejected_epochs.txt']), rejected_epochs);
    else
        fprintf('No epochs rejected for %s\n', file_name);
    end

    % Check if dataset still has epochs
    if EEG.trials > 0
        EEG = pop_saveset(EEG, 'filename', [file_name(1:end-12) '_Epoch_Rej.set'], 'filepath', output_folder);
    else
        fprintf('All epochs rejected for %s - no dataset saved\n', file_name);
    end
end

disp('All good, carry on :)')
