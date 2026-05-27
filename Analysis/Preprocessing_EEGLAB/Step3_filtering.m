%%%% Step2_filtering
% Apply 4th order Butterworth filter between 0.2Hz and 125Hz. Remove line
% noise by using both cleanline and notch filter (results will be saved in
% different folders. 

% Initialize EEGLAB
addpath('/mnt/raid/software/eeglab2024.1/')
eeglab
addpath('/mnt/raid/RU1/Analysis_scripts_code/Ettore/functions/')

% Set relevant folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/PD_OFF/Step1_Import'

% % Output folder for signals processe with Clean Line
% output_folder_cl = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Step2a_Filtering_CL/'
% 
% % Output fodler for signals processed with notch filter
% output_folder_notch = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Step2b_Notch/'

output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Studio_Rachi/Parkinson/Preprocessing_Output/PD_OFF/Step3_Filtering'

% Create output folders
% if ~exist(output_folder_cl, 'dir')
%     mkdir(output_folder_cl);
% end
% 
% if ~exist(output_folder_notch, 'dir')
%     mkdir(output_folder_notch);
% end

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get file list
file_list = dir(fullfile(input_folder, '*.set'))

% %% 4th order Butterworth filter and Cleanline
% for i = 1:length(file_list)
%     
%     % Get file names
%     file_name = file_list(i).name
% 
%     % Load .set files on EEGLAB
%     EEG = pop_loadset('filename', file_name,'filepath', input_folder)
% 
%     % Apply 4th order Butterworth filter between 0.2 and 125
%     EEG = pop_butterfilt(EEG, 4, [0.2 125], 'bandpass')
% 
%     % Clean line (clean 50Hz)
%     EEG = pop_cleanline(EEG, ...
%         'bandwidth',2, ...
%         'chanlist',[1:127] , ...
%         'computepower',1, ...
%         'linefreqs',[50 100] , ...
%         'newversion',0, ...
%         'normSpectrum',0, ...
%         'p',0.01, ...
%         'pad',2, ...
%         'plotfigures',0, ...
%         'scanforlines',0, ...
%         'sigtype','Channels', ...
%         'taperbandwidth',2, ...
%         'tau',100, ...
%         'verb',1, ...
%         'winsize',4, ...
%         'winstep',1);
% 
% 
%     % Save
%     EEG = pop_saveset(EEG, 'filename', [file_name(1 : end-4), '_cl.set'], 'filepath', output_folder_cl)
% 
% end

% %% 4th order Butterworth passband and notch filter
% 
% for i = 1:length(file_list)
% 
%     file_name = file_list(i).name
%     
%     % Load
%     EEG = pop_loadset('filename', file_name, 'filepath', input_folder)
%     
%     % Bandpass filter between 0.2 and 125
%     EEG = pop_butterfilt(EEG, 4, [0.2 125], 'bandpass')
% 
%     % notch filter with harmonics
%     EEG = pop_butterfilt(EEG, 4,  [50 100], 'notch', 2)
% 
%     EEG = pop_saveset(EEG, 'filename', [file_name(1 : end-4), '_notch.set'], 'filepath', output_folder_notch)
% 
% end

%% 4th Order passband Butterworth filter with FIR Notch

for i = 1:length(file_list)

    file_name = file_list(i).name

    EEG = pop_loadset('filename', file_name, 'filepath', input_folder)
    
    % Bandpass 4th Order ButterWorth filter between 0.2Hz and 125hZ
    EEG = pop_butterfilt(EEG, 4, [0.2 125], 'bandpass')
    
    % Notch FIR filter (bandwidth 2)
    EEG = pop_eegfiltnew(EEG, 48, 51, [],1)
    
    % Channel location and label EEG channels
    EEG = pop_chanedit(EEG, {'lookup','/mnt/raid/software/eeglab2024.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc'},'settype',{'[1:58]','EEG'});


    % Save dataset
    EEG = pop_saveset(EEG, 'filename', [file_name(1:end-4),'_filtered.set'], 'filepath', output_folder)
end



disp('All good, carry on :)')
    
 