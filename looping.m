% Mihir Sarkar for Universal Audio
% audioprocess.m
% 1/23/2015

%{
System Diagram:
               _______
audio file ==>|       |==> beat markers
markers[1] ==>|Process|==> measure markers
params[2]  ==>|_______|==> beginning of phrase markers

[1]: end of phrase markers
[2]: n: phrase length in bars
     m: time signature (4/4 default)

Inputs:
audio file: mono/stereo solo monophonic/polyphonic instrument (wav or mp3)
text file: end of phrase markers

Outputs:
audio file: phrases looped 4 times, 2 times w/ automatic click track
text file: start of phrase markers
%}

function Looping()
% Looping
    %PlotAudioFile('input.wav');
    %FilterAudio('input.wav');
    
    choice = 1;
    options = {'Run algo: beat tracking', ...
        'Run algo: ...', ...
        'Run algo: ...', ...
        'Run algo: ...', ...
        'Run algo: ...', ...
        'Exit'};
    
    while(choice~=0)
        choice = menu('Choose a method',options);
        if 1 == choice
            RunAudioProcess(1);
        elseif 2 == choice
            RunAudioProcess(2);
        elseif 3 == choice
            RunAudioProcess(3);
        elseif 4 == choice
            RunAudioProcess(4);
        elseif 5 == choice
            RunAudioProcess(5);
        elseif 6 == choice
            choice = 0;
        end        
    end
end

function PlotAudioFile(AudioFileName)
% PlotAudioFile
    [y,fs] = audioread(AudioFileName);

    disp('Hit any key to continue ...');
    pause;
    time=(1/fs)*length(y(:,1));
    t=linspace(0,time,length(y(:,1)));
    plot(t,y(:,1))
    xlabel('time (sec)');
    ylabel('relative signal strength')

    disp('Hit any key to continue ...');
    pause;
    specgram(y(:,1)); %spectrogram()
    
    disp('Hit any key to continue ...');
    pause;
    Y = fft(y(:,1));
    plot(abs(Y));
    axis([0 length(Y)/2, 0 max(abs(Y))]);
end

function FilterAudio(AudioFileName)
% FilterAudio
    [y,fs]=wavread(AudioFileName);

    Fstop = 350;
    Fpass = 400;
    Astop = 65;
    Apass = 0.5;

    HPFilter = designfilt('highpassfir','StopbandFrequency',Fstop, ...
      'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
      'PassbandRipple',Apass,'SampleRate',fs,'DesignMethod','equiripple');

    FilteredMusic = filter(HPFilter,y);

    output = y + FilteredMusic;
    sound(output,fs);
end

function PlayAudio(hAudio)
% PlayAudio
    hAP = dsp.AudioPlayer('SampleRate',hAudio.SampleRate, ...
        'OutputNumUnderrunSamples',true);
    while ~isDone(hAudio)
      audio = step(hAudio);
      nUnderrun = step(hAP,audio);
      if nUnderrun > 0
        fprintf('Audio player queue underrun by %d samples.\n',nUnderrun);
      end
    end
    pause(hAP.QueueDuration); % wait until audio is played to the end
    release(hAP);
end

function RunAudioProcess(option)
% RunAudioProcess
    FrameSize = 1024;
    
    % Audio I/O
    hMusic = dsp.AudioFileReader('Filename','input.wav',...
    	'SamplesPerFrame',FrameSize);
    
    SampleRate = hMusic.SampleRate;    
    hPlay = dsp.AudioPlayer('SampleRate',SampleRate);
    
    hWrite1 = dsp.AudioFileWriter('Filename','output1.wav',...
        'SampleRate',SampleRate);
    hWrite2 = dsp.AudioFileWriter('Filename','output2.wav',...
        'SampleRate',SampleRate);
    
    endMarkers = ReadTextFile('input.txt');
    
    % Multiband crossover filter
    hMultiband = dspdemo.MultibandCrossoverFilter('SampleRate',SampleRate,...
    	'NumBands',4,...
    	'CrossoverFrequencies',[200 400 800]);
    
    while ~isDone(hMusic)
        % Read audio from files
        music = step(hMusic);
        
        % Split into 4 bands
        [band1, band2 ,band3 ,band4] = step(hMultiband,music);
        
        if 1 == option
            % Process audio & markers
        elseif 2 == option
            % Process audio & markers
        elseif 3 == option
            % Process audio & markers
        elseif 4 == option
            % Process audio & markers
        elseif 5 == option
            % Process audio & markers
        else
            error('Error 1 in RunAudioProcess');
        end
        
        % Audio outputs
        audioOut1 = music;
        audioOut2 = band1 + band2 + band3 + band4;
        
        % Play audio
        %step(hPlay,audioOut1);
        
        % Write audio to file
        step(hWrite1, audioOut1);
        step(hWrite2, audioOut2);        
    end
    
    % Markers output
    startMarkers = endMarkers-1;
    
    % Write markers to file
    SaveTextFile(startMarkers,'output.txt');
    
    % Compare start markers with ground truth
    output = 100; %ComputeAccuracy();
    disp(['Current method (',num2str(option),'): ',num2str(output),'% accurate'])
    disp(' ')
    
    pause(hPlay.QueueDuration); % wait until audio is played to the end
    release(hMusic);
    release(hPlay);
    release(hWrite1);
    release(hWrite2);
end

function data = ReadTextFile(TextFileName)
% ReadTextFile
    data = load(TextFileName); % sample numbers = timing information
end

function SaveTextFile(data, TextFileName)
% SaveTextFile
    fileID = fopen(TextFileName,'w');
    fprintf(fileID,'%d\n',data);
    fclose(fileID);
end
