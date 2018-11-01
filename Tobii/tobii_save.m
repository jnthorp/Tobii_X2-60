function final_gaze_data = tobii_save(gaze_data_all,et0,rect)

final_gaze_data = [];
for row = 1:size(gaze_data_all,1)
    trial_data = [];
    for data = 1:size(gaze_data_all{row,1},2)
        trial_data(data,1) = double((gaze_data_all{row,1}(1,data).SystemTimeStamp)) - et0;
        if double(gaze_data_all{row,1}(1,data).LeftEye.GazePoint.Validity) == 1 && double(gaze_data_all{row,1}(1,data).RightEye.GazePoint.Validity) == 1
            trial_data(data,2) = 1;
            trial_data(data,3) = (gaze_data_all{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,1)+gaze_data_all{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,1))/2*rect(3);
            trial_data(data,4) = (gaze_data_all{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,2)+gaze_data_all{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,2))/2*rect(4);
            trial_data(data,5) = (gaze_data_all{row,1}(1,data).LeftEye.Pupil.Diameter + gaze_data_all{row,1}(1,data).RightEye.Pupil.Diameter)/2;
        else
            trial_data(data,2) = 0;
            trial_data(data,3) = 0;
            trial_data(data,4) = 0;
            trial_data(data,5) = 0;
        end
        if double(gaze_data_all{row,1}(1,data).LeftEye.GazePoint.Validity) == 1
            trial_data(data,6) = gaze_data_all{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,1);
            trial_data(data,7) = gaze_data_all{row,1}(1,data).LeftEye.GazePoint.OnDisplayArea(1,2);
            trial_data(data,8) = gaze_data_all{row,1}(1,data).LeftEye.Pupil.Diameter;
            trial_data(data,9) = gaze_data_all{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,1);
            trial_data(data,10) = gaze_data_all{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,2);
            trial_data(data,11) = gaze_data_all{row,1}(1,data).LeftEye.GazeOrigin.InUserCoordinateSystem(1,3);
        else
            trial_data(data,6) = 0;
            trial_data(data,7) = 0;
            trial_data(data,8) = 0;
            trial_data(data,9) = 0;
            trial_data(data,10) = 0;
            trial_data(data,11) = 0;
        end
        if double(gaze_data_all{row,1}(1,data).RightEye.GazePoint.Validity) == 1
            trial_data(data,12) = gaze_data_all{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,1);
            trial_data(data,13) = gaze_data_all{row,1}(1,data).RightEye.GazePoint.OnDisplayArea(1,2);
            trial_data(data,14) = gaze_data_all{row,1}(1,data).RightEye.Pupil.Diameter;
            trial_data(data,15) = gaze_data_all{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,1);
            trial_data(data,16) = gaze_data_all{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,2);
            trial_data(data,17) = gaze_data_all{row,1}(1,data).RightEye.GazeOrigin.InUserCoordinateSystem(1,3);
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
clear gaze_data_all
