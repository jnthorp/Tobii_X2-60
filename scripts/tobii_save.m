function [final_gaze_data, gaze_data_header] = tobii_save(gaze_data,et0,rect)

%initialize final matrix of gaze data
final_gaze_data = [];

%row = every row of gaze data (every time you dumped the data stream into the
%gaze_data cell)
for row = 1:size(gaze_data,1)
    %Initialize matrix of data for every trial
    trial_data = [];
    %data = every timepoint the eyetracker has data for (60Hz = 60 timepoints a second)
    for data = 1:size(gaze_data{row,1},2)
        trial_data(data,1) = double((gaze_data{row,1}(1,data).SystemTimeStamp)) - et0;
        if double(gaze_data{row,1}(1,data).LeftEye.GazePoint.Validity) == 1 && double(gaze_data{row,1}(1,data).RightEye.GazePoint.Validity) == 1
            trial_data(data,2) = 1;
            trial_data(data,3) = (gaze_data{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,1)+gaze_data{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,1))/2*rect(3);
            trial_data(data,4) = (gaze_data{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,2)+gaze_data{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,2))/2*rect(4);
            trial_data(data,5) = (gaze_data{row,1}(1,data).LeftEye.Pupil.Diameter + gaze_data{row,1}(1,data).RightEye.Pupil.Diameter)/2;
        else
            trial_data(data,2) = 0;
            trial_data(data,3) = 0;
            trial_data(data,4) = 0;
            trial_data(data,5) = 0;
        end
        if double(gaze_data{row,1}(1,data).LeftEye.GazePoint.Validity) == 1
            trial_data(data,6) = gaze_data{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,1);
            trial_data(data,7) = gaze_data{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,2);
            trial_data(data,8) = gaze_data{row,1}(1,data).LeftEye.Pupil.Diameter;
            trial_data(data,9) = gaze_data{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,1);
            trial_data(data,10) = gaze_data{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,2);
            trial_data(data,11) = gaze_data{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,3);
        else
            trial_data(data,6) = 0;
            trial_data(data,7) = 0;
            trial_data(data,8) = 0;
            trial_data(data,9) = 0;
            trial_data(data,10) = 0;
            trial_data(data,11) = 0;
        end
        if double(gaze_data{row,1}(1,data).RightEye.GazePoint.Validity) == 1
            trial_data(data,12) = gaze_data{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,1);
            trial_data(data,13) = gaze_data{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,2);
            trial_data(data,14) = gaze_data{row,1}(1,data).RightEye.Pupil.Diameter;
            trial_data(data,15) = gaze_data{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,1);
            trial_data(data,16) = gaze_data{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,2);
            trial_data(data,17) = gaze_data{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,3);
        else
            trial_data(data,12) = 0;
            trial_data(data,13) = 0;
            trial_data(data,14) = 0;
            trial_data(data,15) = 0;
            trial_data(data,16) = 0;
            trial_data(data,17) = 0;
        end
    end
    final_gaze_data = [final_gaze_data; trial_data];
end
gaze_data_header = {'timestamp','validity','gaze_x','gaze_y','avg_pupil','left_validity','left_gaze_x','left_gaze_y','left_pupil','left_gaze_origin_x','left_gaze_origin_y','left_gaze_origin_z','left_validity','right_gaze_x','right_gaze_y','right_pupil','right_gaze_origin_x','right_gaze_origin_y','right_gaze_origin_z'};