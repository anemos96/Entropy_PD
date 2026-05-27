%%% Step 5: ICA weights computation and ICLabel %%%

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/PD_OFF/Step4_ChRej'
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/PD_OFF/Step5_preICA_rej'

% Create output folder if it does not exist
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'))

% Loop over files
for i = 1:length(file_list)

    file_name = file_list(i).name

    % Load Dataset
    EEG = pop_loadset('filename', file_name, 'filepath', input_folder)

    % Resample
    EEG = pop_resample(EEG, 500)
    
    % Add channel location
    EEG = pop_chanedit(EEG, 'lookup','/mnt/raid/software/eeglab2024.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc');


    % ICA (compute ICA only on EEG-flagged channel)
    EEG = pop_runica(EEG, 'icatype', 'runica', 'chanind', {'EEG'}, 'extended', 1, 'interrupt', 'on')

    % IC Label and IC flag
    EEG = pop_iclabel(EEG, 'default')
    EEG = pop_icflag(EEG, [NaN NaN; 0.9 1; 0.8 1; 0.9 1; NaN NaN; 0.5 1; NaN NaN]) %Thresholds: Brain, Muscle, Eye, Heart, Line, Channel, Other
    
    % Save
    EEG = pop_saveset(EEG, 'filename', [file_name(1:end-4) '_Pre_ICA_Rej.set'], 'filepath', output_folder)

end


disp('All good, carry on :)')