%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ENTROPY ANALYIS - Discrete Bands %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%   Prepares EEG data for HCTSA by performing temporal averaging across epochs
%   (ERP generation) for EACH channel individually.
%   No spatial clustering is performed at this stage.
%
%   Processing Steps:
%   1. Data curation
%       - Load .set file.
%       - Filter data along frequency band of interest
%       - Average all epochs (mean across 3rd dimension) -> 1 signal per channel.
%       - Extract all 128 channels as separate time series.
%       - Generate HCTSA.mat database.
%
%   2. Calculation of Entropy Measures of Interest
%       - Approximate Entropy
%       - Sample Entropy
%       - Multi Scale Entropy
%
% DEPENDENCIES:
%   - EEGLAB Toolbox
%   - HCTSA Toolbox (Highly Comparative Time-Series Analysis)
%
% AUTHOR: Ettore Napoli - ONDA Lab - University of Bologna


%% 1 - Filter datasets along frequency bands

% Set folders
% Set Folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Preprocessing_Output/Step8_Epoch_Rej/';
file_extension = '*.set';
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Preprocessing_Output/Discrete_FreqBands/';

% Start EEGLAB
eeglab_folder = '/mnt/raid/software/eeglab2024.1/';
addpath(genpath(eeglab_folder));
eeglab;

% Create output folder
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Select and load datasets
input_files = dir(fullfile(input_folder, file_extension))

for i = 1:length(input_files)
    curr_file = input_files(i).name;
    
    EEG = pop_loadset('filename', char(curr_file), 'filepath', char(input_folder));

    clean_name = curr_file(1:end-14);

    % Pass band filter delta (1-4 Hz)
    EEG_delta = pop_eegfiltnew(EEG, 1, 4, [], 0);

    % Save
    EEG_delta = pop_saveset(EEG_delta, 'filename', [clean_name '_delta.set'], 'filepath', output_folder);

    % Pass band filter theta (4-8 HZ)
    EEG_theta = pop_eegfiltnew(EEG, 4, 8, [], 0);

    % Save
    EEG_theta = pop_saveset(EEG_theta, 'filename', [clean_name '_theta.set'], 'filepath', output_folder);

    % Pass band filter alpa (8-12 Hz)
    EEG_alpha = pop_eegfiltnew(EEG, 8, 12, [], 0);
    
    % Save
    EEG_alpha = pop_saveset(EEG_alpha, 'filename', [clean_name '_alpha.set'], 'filepath', output_folder);

    % Pass band filter beta (13-30 Hz)
    EEG_beta = pop_eegfiltnew(EEG, 13, 30, [], 0);

    % Save
    EEG_beta = pop_saveset(EEG_beta, 'filename', [clean_name '_beta.set'], 'filepath', output_folder);
end

%% 2 Data curation
clear all; close all; clc;

% Set Folders
input_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Preprocessing_Output/Discrete_FreqBands/';
file_extension = '*.set';
output_folder = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Entropy_Analysis/';

% Start EEGLAB
eeglab_folder = '/mnt/raid/software/eeglab2024.1/';
addpath(genpath(eeglab_folder));
eeglab;

% Start HCSTA
current_dir = pwd;
hctsa_folder = '/mnt/raid/software/hctsa/';
config_folder = '/mnt/raid/software/hctsa/FeatureSets/';
cd(hctsa_folder);
startup;
cd(current_dir);

% Pre-allocate
timeSeriesData = {};
labels = {};
keywords = {};

% Select and load EEG datasets
input_files = dir(fullfile(input_folder, file_extension));

for f = 1:length(input_files)
    file_name = input_files(f).name;

    EEG = pop_loadset('filename', char(file_name), 'filepath', char(input_folder));

    clean_file_name = file_name(1:end-4);

    % Average data over the epochs (One continous time series per channel)
    mean_data = mean(EEG.data, 3);
    
    % Channel Extraction
    [nChans, nFrame] = size(mean_data);

    for c = 1:nChans
        chan_label = EEG.chanlocs(c).labels;

        % Channel-specific time series
        chan_signal = double(mean_data(c, :))'; % Column vector because HCSTA only wants column vectors

        % Save
        timeSeriesData{end+1, 1} = chan_signal;
        labels{end+1, 1} = sprintf('%s_%s', clean_file_name, chan_label);
        keywords{end+1, 1} = sprintf('%s,%s', clean_file_name, chan_label);
    end
end

% Create .mat file with the timeseries data, labels and keywords
% for TS_Init
cd(output_folder)
inp_filename = 'INP_ts_FreqBand.mat';
save(inp_filename, 'timeSeriesData', 'labels', 'keywords');

% Define source file
source_mops = fullfile(config_folder, 'INP_mops_hctsa.txt'); 
source_ops  = fullfile(config_folder, 'INP_ops_hctsa.txt');

% Define destination files
dst_mops = fullfile(output_folder, 'INP_mops.txt');
dst_ops  = fullfile(output_folder, 'INP_ops.txt');

% Copy source files into destination files
try
    copyfile(source_mops, dst_mops);
    copyfile(source_ops, dst_ops);
    fprintf('File di configurazione copiati e rinominati correttamente.\n');
catch ME
    error('Errore nella copia dei file config. Controlla che "config_folder" sia giusto!\nErrore: %s', ME.message);
end

% Create HCTSA matrix
TS_Init(inp_filename, {dst_mops, dst_ops}, true, 'HCTSA_FreqBand.mat');


%% 3 - Compute Entropy measures of interest
clear all; close all; clc;

% Set folders
work_dir = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Entropy_Analysis';
cd(work_dir);

% Load operations from HCTSA.mat
[~, ~, Operations] = TS_LoadData('HCTSA_FreqBand.mat');

% Find indices of measures of interest among operations
idx_ApEn   = find(contains(Operations.Name, 'ApEn', 'IgnoreCase', true));
idx_SampEn = find(contains(Operations.Name, 'EN_SampEn', 'IgnoreCase', true));
idx_MSE    = find(contains(Operations.Name, 'EN_MSE', 'IgnoreCase', true));

% Create a list of all the indices without repetitions
target_ids = unique([idx_ApEn; idx_SampEn; idx_MSE]);

% Compute Entropy Measures
TS_Compute(false, [], target_ids, 'missing', 'HCTSA_FreqBand.mat', 'minimal');

% Extract matrix containing computed results
[TS_DataMat, TimeSeries, Operations] = TS_LoadData('HCTSA_FreqBand.mat'); 

% Filter the columns so that it selects only those of interest
cols_to_keep = ismember(Operations.ID, target_ids);

% Extract sub-matrix
dataMatrix_Entropy = TS_DataMat(:, cols_to_keep);
colInfo_Entropy    = Operations(cols_to_keep, :);
rowInfo_Entropy    = TimeSeries;

% Remove (if any) NaN values
valid_rows = sum(~isnan(dataMatrix_Entropy), 2) > 0;
if any(~valid_rows)
    fprintf('Attenzione: Rimossi %d canali per calcoli falliti (NaN).\n', sum(~valid_rows));
    dataMatrix_Entropy = dataMatrix_Entropy(valid_rows, :);
    rowInfo_Entropy = rowInfo_Entropy(valid_rows, :);
end

% Save result matrix
output_file = fullfile(work_dir, 'Results_Entropy_FreqBand.mat');
save(output_file, 'dataMatrix_Entropy', 'rowInfo_Entropy', 'colInfo_Entropy');

% Create readable table
headers = colInfo_Entropy.Name;
Readable_Table = array2table(dataMatrix_Entropy, 'VariableNames', headers);
Readable_Table.Subject_Channel = rowInfo_Entropy.Name;
Readable_Table = movevars(Readable_Table, 'Subject_Channel', 'Before', 1);

% Save Table
filename_excel = fullfile(work_dir, 'EntropyResults_FreqBands.xlsx');
filename_mat = fullfile(work_dir, 'EntropyResults_FreqBands.mat');
writetable(Readable_Table, filename_excel);
save(filename_mat, 'Readable_Table');

%% 3 - Clustering

clear all; close all; clc;

% Set folders
work_dir = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Entropy_Analysis/Results_FreqBands/';
cd(work_dir);

% Load result table
load EntropyResults_FreqBands.mat;
load Results_Entropy_FreqBand.mat

% Prepare ROI object
ROI = struct();

% Build clusters
ROI.Frontal_L = {'Fp1','F3', 'F7', 'FC5', 'FC1',... 
    'AF7', 'AF3', 'F1', 'F5','FC3','F9', 'AFF1h', 'FFC1h',...
    'FFC5h', 'FCC3h','AFp1', 'AFF5h', 'FFC3h', 'FCC1h', ...
    'FCC5h'};
ROI.Frontal_R = {'FC6', 'FC2', 'F4', 'F8', 'Fp2', ...
    'FC4', 'F6', 'AF8', 'AF4', 'F2', 'FCC4h', 'FFC6h', ...
    'FFC2h', 'AFF2h', 'F10', 'FCC6h', 'FCC2h', 'FFC4h', ...
    'AFF6h', 'AFp2'};
ROI.Central_L = {'C3','C1', 'C5','CCP1h', 'CCP5h','CCP3h'};
ROI.Central_R = {'C4','C6', 'C2','CCP6h', 'CCP2h', 'CCP4h'};
ROI.Parietal_L = {'CP5', 'CP1','P3', 'P7','CP3', 'P1',...
    'P5', 'P9', 'PPO9h', 'PPO1h', 'CPP3h',...
    'PPO5h', 'CPP1h', 'CPP5h'};
ROI.Parietal_R = {'P4', 'P8', 'CP6', 'CP2', ...
    'P6', 'P2','CP4' , 'CPP4h', 'PPO2h','PPO10h',...
    'P10', 'PPO6h','CPP6h', 'CPP2h'};
ROI.Temporal_L = {'FT9','T7', 'TP9','FT7', 'TP7','FTT7h',...
    'TPP7h','FFT9h', 'FFT7h','FTT9h', 'TTP7h', 'TPP9h'};
ROI.Temporal_R = {'TP10','T8', 'FT10', 'TP8', 'FT8','TPP8h',... 
    'FTT8h', 'TPP10h', 'TTP8h', 'FTT10h', 'FFT8h', 'FFT10h'};
ROI.Occipital_L = {'O1','PO9', 'O9', 'OI1h', 'POO9h', 'POO1', 'PO7', 'PO3'};
ROI.Occipital_R = {'O2','OI2h', 'O10','POO2','POO10h', 'PO4', 'PO8', 'PO10'};
ROI.Midline = {'Fz','Pz','Oz', 'Cz', 'POz', 'CPz', 'FCz'};
ROI.Anterior = [ROI.Frontal_L, ROI.Frontal_R, ...
                {'Fz', 'FCz'}, ...
                {'FT9', 'FT7', 'FTT7h', 'FFT9h', 'FFT7h', 'FTT9h'}, ... 
                {'FT10', 'FT8', 'FTT8h', 'FFT8h', 'FFT10h', 'FTT10h'}]; 

ROI.Posterior = [ROI.Parietal_L, ROI.Parietal_R, ...
                 ROI.Occipital_L, ROI.Occipital_R, ...
                 {'CPz', 'Pz', 'POz', 'Oz'}, ...
                 {'TP9', 'TP7', 'TPP7h', 'TTP7h', 'TPP9h'}, ...           
                 {'TP10', 'TP8', 'TPP8h', 'TPP10h', 'TTP8h'}, ...         
                 {'CCP1h', 'CCP3h', 'CCP5h'}, ...                         
                 {'CCP2h', 'CCP4h', 'CCP6h'}];                            


clusters = fieldnames(ROI);
% Parse Column name
full_names = Readable_Table.Subject_Channel;
subject_list = {};
chan_list = {};

for f = 1:length(full_names);
    name_parts = strsplit(full_names{f}, '_');
    chan = name_parts{end};
    subj = strjoin(name_parts(1:end-1), '_');

    % fill the lists
    subject_list{end+1, 1} = subj;
    chan_list{end+1, 1} = chan;
end

unique_subjects = unique(subject_list);
Results_ROI = struct();

% Extract entropy measures name
measures = colInfo_Entropy.Name;

% Loop over measures
for f = 1:length(measures)
    curr_measure = measures{f};
    clean_measure = matlab.lang.makeValidName(curr_measure);

    % Create table
    tbl = table('Size', [length(unique_subjects), length(clusters)], ...
                'VariableTypes', repmat({'double'}, 1, length(clusters)), ...
                'VariableNames', clusters, ...
                'RowNames', unique_subjects);
    % Loop over subj
    for s = 1:length(unique_subjects)
        subj = unique_subjects{s};
        
        % Loop ROI
        for c = 1:length(clusters)
            clust_name = clusters{c};
            target_chans = ROI.(clust_name);
            
            % Find indices relating to subj & chan
            idx_subj = strcmp(subject_list, subj);
            idx_chans = ismember(chan_list, target_chans);
            idx_final = idx_subj & idx_chans;

            vals = dataMatrix_Entropy(idx_final, f);
            
            % Mean
            if isempty(vals) || all(isnan(vals))
                val_mean = NaN;
            else
                val_mean = nanmean(vals);
            end
            
            tbl{subj, clust_name} = val_mean;
        end
    end
    
    Results_ROI.(clean_measure) = tbl;
end

% Select Measures of Interest and build a partial result struct
MoF = {'SY_SlidingWindow_sampen_sampen2_10', 'ApEn2_02', 'EN_mse_1_10_2_015_rescale_tau_meanSampEn'};
Results_ROI_partial = struct()

for m = 1:length(MoF)

    current_MoF = MoF{m};

    Results_ROI_partial.(current_MoF) = Results_ROI.(current_MoF)
end

% Save
output_file = fullfile(work_dir, 'Results_ROI_FreqBands.mat');
save(output_file, 'Results_ROI', 'unique_subjects', 'ROI', 'Results_ROI_partial');


%% Data export
clear all; close all; clc;
work_dir = '/mnt/raid/RU1/Raw_data/Ettore/Entropy/Healthy/Entropy_Analysis/Results_FreqBands';
cd(work_dir);
load('Results_ROI_FreqBands.mat')


% Righe = Soggetti
% Colonne = Tutte le possibili combinazioni Misura_ROI (es. "SampEn_Frontal_L")

% Create Table Total
Final_Table_tot = table(unique_subjects, 'VariableNames', {'SubjectID'});

% Find measure list
meas_names = fieldnames(Results_ROI);
meas_names_partial = fieldnames(Results_ROI_partial);

% Loop over measures
for m = 1:length(meas_names)
    curr_meas = meas_names{m};           
    curr_tbl  = Results_ROI.(curr_meas); 
    
    roi_names = curr_tbl.Properties.VariableNames; % es. {'Frontal_L', 'Frontal_R'...}
    
    % Loop over electrode cluster
    for r = 1:length(roi_names)
        curr_roi = roi_names{r};
        
        % Extract data column specif for current roi
        data_col = curr_tbl.(curr_roi);
        
        % Create name
        short_meas = curr_meas; 
        if length(short_meas) > 25
            % If too long cut the middle part (so that we can recognize it
            % from its start and end
            short_meas = [short_meas(1:15) '...' short_meas(end-5:end)];
        end
        
        new_col_name = sprintf('%s_%s', curr_meas, curr_roi);
        
        % Clean name
        new_col_name = matlab.lang.makeValidName(new_col_name);
        
        % Add to final table
        Final_Table_tot.(new_col_name) = data_col;
    end
end

% Create Table partial
Final_Table_par = table(unique_subjects, 'VariableNames', {'SubjectID'});

% Find measure list
meas_names = fieldnames(Results_ROI);
meas_names_partial = fieldnames(Results_ROI_partial);

% Loop over measures
for m = 1:length(meas_names_partial)
    curr_meas = meas_names_partial{m};           
    curr_tbl  = Results_ROI_partial.(curr_meas); 
    
    roi_names = curr_tbl.Properties.VariableNames; % es. {'Frontal_L', 'Frontal_R'...}
    
    % Loop over electrode cluster
    for r = 1:length(roi_names)
        curr_roi = roi_names{r};
        
        % Extract data column specif for current roi
        data_col = curr_tbl.(curr_roi);
        
        % Create name
        short_meas = curr_meas; 
        if length(short_meas) > 25
            % If too long cut the middle part (so that we can recognize it
            % from its start and end
            short_meas = [short_meas(1:15) '...' short_meas(end-5:end)];
        end
        
        new_col_name = sprintf('%s_%s', short_meas, curr_roi);
        
        % Clean name
        new_col_name = matlab.lang.makeValidName(new_col_name);
        
        % Add to final table
        Final_Table_par.(new_col_name) = data_col;
    end
end


% 4. Salvataggio
csv_filename_tot = fullfile(work_dir, 'Results_ROI_FreqBand_tot.csv');
csv_filename_par = fullfile(work_dir, 'Results_ROI_FreqBand_par.csv');
writetable(Final_Table_par, csv_filename_par);
writetable(Final_Table_tot, csv_filename_tot);