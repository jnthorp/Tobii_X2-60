%%Lines to put inside task script

%%%%%%%%%
%This goes at the beginning of the task, before there's any data you want, it initializes the eye tracker
%expVars.tobii is a logical variable that tells you if you are recording eyetracking data (so you can run the task without it)
if expVars.tobii == 1
    result = eyetracker.get_gaze_data;  %this call initializes the eyetracker, starts the stream of data
    et0 = Tobii.get_system_time_stamp;  %et0 is the Tobii system time stamp which you will later use to compare your data with Matlab's time stamp
    etrow = 0; %index of where to store the gaze data within cell gaze_data
    gaze_data = cell(1,1);  %where you will store gaze data eventually
end
%%%%%%%%%
%%%%%%%%%
%This records data into gaze_data
if expVars.tobii == 1
  etrow = etrow+1;  %index of where to store cells of gaze data within gaze_data
  result = eyetracker.get_gaze_data; %result is the current queue of gaze data stored in the eyetracker
  gaze_data{etrow,1} = result;  %store result in the cell indicated by etrow in gaze_data
end
%%%%%%%%%
%%%%%%%%%
if expVars.tobii == 1
    eyetracker.stop_gaze_data;  %stops data stream
    final_gaze_data = tobii_save(gaze_data,et0,Rect);   %call tobii_save
    clear gaze_data    %clear the gaze_data cell, it's usually too heavy to save
end
%%%%%%%%%