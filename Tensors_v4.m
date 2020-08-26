% isp_all EEG data

clc
clear all
addpath(genpath('/Users/tulsipatel/Desktop/chip/tensor_toolbox'))

% load data from csv
df = readtable('isp_all.csv');

% filter data for wavelets D1-D6
df = df(strcmp(df.Wavelet, 'D1') | strcmp(df.Wavelet, 'D2') | strcmp(df.Wavelet, 'D3') | ...
    strcmp(df.Wavelet, 'D4') | strcmp(df.Wavelet, 'D5') | strcmp(df.Wavelet, 'D6'), :)

% filter data by age
df = df(df.Age == 9, :)

% filter data by diagnosis
df = df(strcmp(df.DX, 'asd'), :)

% retrieve IDs for all patients
patients = unique(df.ID);

measures = ["Power", "SampE", "hurstrs", "RR", "DET", "LAM", "DIV", "Lentr", "Lmax", "Lmean", "TT"]

% cell array of tensors
Train_Tensor = {}

% iterate through patients
for i = 1 : length(patients)
    
    % get all data for one patient
    patient_data = df(df.ID == patients(i), :)
    
    % t_array is tensor array for one patient
    t_array = []
    
    % get all channels for one patient
    all_channels = unique(patient_data.Channel);
    
    % create new channels array
    channels = []
    
    % filter out channels that have NaN values for any non-linear measure
    for a = 1 : length(all_channels)
        
        % get data for each channel
        channel_data = patient_data(patient_data.Channel == all_channels(a), :)
        
        if ismember(1, isnan(channel_data.Value))
            continue
        else 
            channels = [channels, all_channels(a)]
        end
        
    end
    
    if length(channels) ~= 64
        continue 
    else 
        
        % iterate through measures 
        for m = 1 : length(measures)

            sub_measure = patient_data(strcmp(patient_data.Feature, measures(m)), :)
            m_array = []

            for c = 1 : length(channels)

                % get data for one channel
                sub_channel = sub_measure(sub_measure.Channel == channels(c), :)

                % concat "Value" column to previous channel arrays (m_array)
                row = sub_channel.Value;
                m_array(:,c) = row;

            end

            % once channel loop is over, concat 2d measure array to tensor array
            t_array(:,:,m) = m_array;

         end

         % t_array to tensor
         Train_Tensor{i,1}  = tensor(t_array);
         
    end
    
end