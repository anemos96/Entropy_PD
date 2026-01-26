%%% Step6: IC rejection and save indices of rejected components %%%

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step5_preICA_rej'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/Controls/Step6_postICA_rej'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'))

% Loop over files
for i = 1:length(file_list)

    file_name = file_list(i).name

    % Load dataset on EEGLAB
    EEG = pop_loadset('filename', file_name, 'filepath', input_folder)

    % Find flagged components indices
    rejected_components = find(EEG.reject.gcompreject)

    % Remove selected indices
    EEG = pop_subcomp(EEG, rejected_components, 0, 0)

    % Save rejected components' indices in a .txt file
    
    csvwrite(fullfile(output_folder, [file_name(1:end-16), '_manually_rejected_components.txt']), rejected_components);

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [file_name '_icarej'])

    % Save dataset
    EEG = pop_saveset(EEG, 'filename', [file_name(1:end-16) '_Post_Ica_Rej.set'], 'filepath', output_folder)

end




