%% Tobii Calibration w/ Quality Analysis

%%Edited by John Thorp from the Tobii Pro Matlab SDK, labeled
%%'calibrate_orig_sdk.m' Dec 8 -

%Contents:
%Find eye tracker, enter calibration mode, and prepare Psychtoolbox
%Define calibration points to collect
%Define oval fixation points from points_to_collect
%Calibrate
    %contains for loop that shrinks the point
%Find any points that need to be recalibrated
%Attempt to recalibrate points until either all points are properly
    %calibrated or there have been 3 attempts to calibrate
%Compose a plot of all recorded calibration data
%Record gaze data that will be used to analyze the quality of the
%calibration
%Determine quality of calibration using accuracy and precision data

%Will have to change between computers:
    %eyetracker_offset
        %distance in mm from center of eyetracker to bottom of screen
    %eyetracker_Hz (if not X2-60)
        %Hz of eyetracker
    %image addresses for calib_countdown, recal_countdown, and QA_countdown, which are displayed
    %throughout the calibration
        
%Gaze data is only used for quality analysis if both eyes have valid data
    %Code for including gaze that only has one valid eye is included but
    %commented out near the variables valid_gaze and use_gaze
        
    
    
    function [Accuracy,Precision,Calibrated_points] = tobii_calibrate(num_points,calibrate,Tobii,eyetracker,w,rect)
    Accuracy = 0;
    Precision = 0;
    Calibrated_points = 0;
    %%%%%%Find eye tracker%%%%%%
    if ~exist('eyetracker', 'var')
        Tobii = EyeTrackingOperations();
        eyetrackers = Tobii.find_all_eyetrackers;
        try eyetracker = eyetrackers(1,1);
        catch
            error('eyetracker not detected\n')
        end
    end
calib = ScreenBasedCalibration(eyetracker);


%determine number of points to be calibrated (11 recommended)

while num_points ~= 5 && num_points ~= 9 && num_points ~= 11 && num_points ~= 13
    prompt = 'How many calibration points? (5, 9, 11, 13)';
    num_points = GetNumber(Keyboard);
end
    screens=Screen('Screens');
    screenNumber=max(screens);
    KbName('UnifyKeyNames');
    a = GetKeyboardIndices;
    Keyboard = min(a);

    %If w and rect are provided, use the currently open window
    if exist('w','var')
        opened = 1;
    else
        opened = 0;
        [w,rect] = PsychImaging('OpenWindow', screenNumber, 128);
    end
    Screen('FillRect',w,[0 0 0]);
    
    %draw welcome screen for 2 seconds
        welcome = [ 'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep 'Calibration_welcome.jpg'];
        imdata=imread(welcome);
        imagetex=Screen('MakeTexture', w, imdata);
        Screen('DrawTexture', w, imagetex);
        Screen('Flip', w);
        pause(2)
        
    %draw start screen
        start = [ 'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep 'Calibration_start.jpg'];
        imdata = imread(start);
        imagetex = Screen('MakeTexture', w, imdata);
        points_to_collect = [0.1,0.9;0.5,0.9;0.9,0.9;];
        oval_points = zeros(size(points_to_collect,1),4);
        for point = 1:size(points_to_collect,1)
            oval_points(point,1) = points_to_collect(point,1) * rect(3) - 18;
            oval_points(point,2) = points_to_collect(point,2) * rect(4) - 18;
            oval_points(point,3) = points_to_collect(point,1) * rect(3) + 18;
            oval_points(point,4) = points_to_collect(point,2) * rect(4) + 18;
        end
        shrink = 1; %will be used to shrink the point in the calibration animation
        KbQueueCreate();
        KbQueueStart();
        
        flag = 0;
        while KbQueueCheck == 0
            for cal_point = randperm(size(points_to_collect,1))
                white = [250 250 250]; %color, should be white
                for animate = 1:15 %animates the oval shrinking by adding/subtracting an increasing constant to the oval dimensions
                    Screen('DrawTexture', w, imagetex);
                    rect_oval = [oval_points(cal_point,1)+shrink*animate,oval_points(cal_point,2)+shrink*animate,oval_points(cal_point,3)-shrink*animate,oval_points(cal_point,4)-shrink*animate];
                    Screen('FillOval',w,white,rect_oval);
                    Screen('Flip',w);
                    Kb = KbQueueCheck;
                    if Kb ~= 0
                        flag = 1;
                        break
                    end
                    pause(0.07)
                end
                Kb = KbQueueCheck;
                if Kb ~= 0 || flag == 1
                    break
                end
                pause(1)
            end
            if Kb ~= 0 || flag == 1
                break
            end
        end
        KbQueueStop();


    %list of points to collect, can be any number and position
    if num_points == 5
        points_to_collect = [[0.1,0.1];[0.1,0.9];[0.5,0.5];[0.9,0.1];[0.9,0.9]];
    end
    if num_points == 9
        points_to_collect = [[0.4,0.2];[0.6,0.2];[0.2,0.4];[0.8,0.4];[0.5,0.5];[0.2,0.6];[0.8,0.6];[0.4,0.8];[0.6,0.8]];
    end
    if num_points == 11
        points_to_collect = [[0.2,0.2];[0.4,0.2];[0.6,0.2];[0.8,0.2];[0.1,0.5];[0.5,0.5];[0.9,0.5];[0.2,0.8];[0.4,0.8];[0.6,0.8];[0.8,0.8]];
    end
    if num_points == 13
        points_to_collect = [[0.1,0.1];[0.5,0.1];[0.9,0.1];[0.3,0.3];[0.7,0.3];[0.1,0.5];[0.5,0.5];[0.9,0.5];[0.3,0.7];[0.7,0.7];[0.1,0.9];[0.5,0.9];[0.9,0.9]];     
    end
    
    %points of the ovals that are displayed on screen, uses the
    %points_to_collect variable and wrect (size of the screen) to calculate their size and position
    oval_points = zeros(size(points_to_collect,1),4);
    for point = 1:size(points_to_collect,1)
        oval_points(point,1) = points_to_collect(point,1) * rect(3) - 18;
        oval_points(point,2) = points_to_collect(point,2) * rect(4) - 18;
        oval_points(point,3) = points_to_collect(point,1) * rect(3) + 18;
        oval_points(point,4) = points_to_collect(point,2) * rect(4) + 18;
    end
    shrink = 1; %will be used to shrink the point in the calibration animation
    
    

%%%%%% Initial Calibration %%%%%%
if calibrate == 1
    %calib_countdown is the cell array that the locations of the files are
    %stored in
    countdown_path = {'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep };
    num{1} = sprintf('%sCalibration_3.jpg',strjoin(countdown_path,''));
    num{2} = sprintf('%sCalibration_2.jpg',strjoin(countdown_path,''));
    num{3} = sprintf('%sCalibration_1.jpg',strjoin(countdown_path,''));
    for count = 1:3 %Draws each countdown screen for 1 second
        number = char(num{count}); %num is the character string of the countdown file
        imdata=imread(number);
        imagetex=Screen('MakeTexture', w, imdata);
        Screen('DrawTexture', w, imagetex);
        Screen('Flip', w);
        pause(1)
    end
        
    calib.enter_calibration_mode() %Enters the calibration mode of the eyetracker
    
    for cal_point = randperm(size(points_to_collect,1))
        white = [250 250 250]; %color, should be white 
        for animate = 1:15 %animates the oval shrinking by adding/subtracting an increasing constant to the oval dimensions
           rect_oval = [oval_points(cal_point,1)+shrink*animate,oval_points(cal_point,2)+shrink*animate,oval_points(cal_point,3)-shrink*animate,oval_points(cal_point,4)-shrink*animate];
           Screen('FillOval',w,white,rect_oval);
           Screen('Flip',w);
           pause(0.07);
        end
        %collect calibration data
        collect_result = calib.collect_data(points_to_collect(cal_point,:));
        fprintf('Point [%.2f,%.2f] Collect Result: %s\n',points_to_collect(cal_point,:),char(collect_result));
    end
        %Compute and apply calibration data
        calibration_result = calib.compute_and_apply();
        fprintf('Calibration Status: %s\n',char(calibration_result.Status));

        %Look for which points are calibrated and create idx of points to
        %recalibrate      
        cal_et = zeros(length(calibration_result.CalibrationPoints),2); %cal_et = calibrated points in the order they appear in
        cal_idx = zeros(size(points_to_collect)); %cal_idx = index of the calibrated points that can extract the points to recalibrate from points_to_collect
        for cal_point = 1:length(calibration_result.CalibrationPoints)
            cal_et(cal_point,:) = calibration_result.CalibrationPoints(1,cal_point).PositionOnDisplayArea; %calibration_result, presented in the dimensions of the eyetracker (0:1)
            for row = 1:size(points_to_collect,1) %extracts the index by finding when cal_et == points_to_collect
                if round(cal_et(cal_point,1),1) - points_to_collect(row,1) == 0 && round(cal_et(cal_point,2),1) - points_to_collect(row,2) == 0
                    cal_idx(row,:) = 1;
                end
            end
        end

        %find index and values of points to recalibrate, then the oval points
        %to recalibrate
        recal_idx = find(cal_idx(:,1) == 0);
        points_to_recalibrate = points_to_collect(recal_idx,:);
        oval_points_recal = oval_points(recal_idx,:);
        prev_cal = eyetracker.retrieve_calibration_data;
        prev_cal_quality = size(calibration_result.CalibrationPoints,2);

        %Prompt on whether to move on to Quality Analysis or attempt to
        %recalibrate
        resp_qa = 2;
        resp_stopcal = 2;
        resp_qa2 = 2;
        if isempty(points_to_recalibrate) == 1
            try
                while resp_qa ~= 0 && resp_qa ~= 1

                prompt = ('Calibration complete! Continue to Quality Analysis? (0 = no, 1 = yes) ');
                DrawFormattedText(w,prompt,'center','center',white);
                Screen('Flip',w);
                resp_qa = GetNumber(Keyboard);
                end
            catch
                    prompt = ('Please enter again');
                    DrawFormattedText(w,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
            end
        else
            try
            while resp_stopcal ~= 0 && resp_stopcal ~= 1
               
                prompt = sprintf('Calibration incomplete! %d points needed. Move on without recalibrating? (0 = no, 1 = yes) ',size(points_to_recalibrate,1));
                DrawFormattedText(w,prompt,'center','center',white);
                Screen('Flip',w);
                resp_stopcal = GetNumber(Keyboard);
            end
                catch
                    prompt = ('Please enter again');
                    DrawFormattedText(w,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
                end
            
            if resp_stopcal == 1
                try
                while resp_qa ~= 0 && resp_qa ~= 1
                    
                    prompt = ('Calibration complete! Continue to Quality Analysis? (0 = no, 1 = yes) ');
                    DrawFormattedText(w,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
                end
                catch
                    prompt = ('Please enter again');
                    DrawFormattedText(w,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
                end
            end
        end
    if resp_qa == 0 
        calib.leave_calibration_mode
    else
    %Recalibrate
    %Most everything after the while statement is the same as the initial
    %calibration
        if resp_qa == 1
        else
            countdown_path = {'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep };
            num{1} = sprintf('%sRecalibration_3.jpg',strjoin(countdown_path,''));
            num{2} = sprintf('%sRecalibration_2.jpg',strjoin(countdown_path,''));
            num{3} = sprintf('%sRecalibration_1.jpg',strjoin(countdown_path,''));
            while resp_stopcal == 0 %Attempt to recalibrate until there have been 3 attempts or all points are properly calibrated
                %tries = tries+1;
                
           
            for count = 1:3 %Draws each countdown screen for 1 second
                number = char(num{count}); %num is the character string of the countdown file
                imdata=imread(number);
                imagetex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, imagetex);
                Screen('Flip', w);
                pause(1)
            end
                for cal_point = randperm(size(points_to_recalibrate,1))
                    calib.discard_data(points_to_recalibrate(cal_point,:));
                    white = [250 250 250];
                    for animate = 1:15
                        rect_oval = [oval_points_recal(cal_point,1)+shrink*animate,oval_points_recal(cal_point,2)+shrink*animate,oval_points_recal(cal_point,3)-shrink*animate,oval_points_recal(cal_point,4)-shrink*animate];
                        Screen('FillOval',w,white,rect_oval);
                        Screen('Flip',w);
                        pause(0.07);
                    end
                    collect_result = calib.collect_data(points_to_recalibrate(cal_point,:));
                    fprintf('Point [%.2f,%.2f] Collect Result: %s\n',points_to_recalibrate(cal_point,:),char(collect_result));
                end

                calibration_result = calib.compute_and_apply();
                fprintf('Calibration Status: %s\n',char(calibration_result.Status));
                
                if size(calibration_result.CalibrationPoints,2) < prev_cal_quality
                    fprintf('less\n')
                    eyetracker.apply_calibration_data(prev_cal);
                    calibration_result = calib.compute_and_apply();
                end

                cal_et = zeros(length(calibration_result.CalibrationPoints),2);
                cal_idx = zeros(size(points_to_collect));
                for point = 1:length(calibration_result.CalibrationPoints)
                    cal_et(point,:) = calibration_result.CalibrationPoints(1,point).PositionOnDisplayArea;
                    for row = 1:size(points_to_collect,1)
                        if round(cal_et(point,1),1) - points_to_collect(row,1) == 0 && round(cal_et(point,2),1) - points_to_collect(row,2) == 0
                            cal_idx(row,:) = 1;
                        end
                    end
                end

                recal_idx = find(cal_idx(:,1) == 0);
                points_to_recalibrate = points_to_collect(recal_idx,:);
                oval_points_recal = oval_points(recal_idx,:);
                prev_cal = eyetracker.retrieve_calibration_data;
                prev_cal_quality = size(calibration_result.CalibrationPoints,2);
                resp_stopcal = 2;
                resp_qa2 = 2;
                if isempty(points_to_recalibrate) == 1
                    try
                    while resp_qa2 ~= 0 && resp_qa2 ~= 1
                        prompt = ('Calibration complete! Continue to Quality Analysis? (0 = no, 1 = yes) ');
                        DrawFormattedText(w,prompt,'center','center',white);
                        Screen('Flip',w);
                        resp_qa2 = GetNumber(Keyboard);
                    end 
                    catch
                    prompt = ('Please enter again');
                    DrawFormattedText(2,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
                    end
                else
                    try
                    while resp_stopcal ~= 0 && resp_stopcal ~= 1
                        prompt = sprintf('Calibration incomplete! %d points needed. Move on without recalibrating? (0 = no, 1 = yes) ',size(points_to_recalibrate,1));
                        DrawFormattedText(w,prompt,'center','center',white);
                        Screen('Flip',w);
                        resp_stopcal = GetNumber(Keyboard);
                    end
                    catch
                    prompt = ('Please enter again');
                    DrawFormattedText(2,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_qa = GetNumber(Keyboard);
                    end
                    if resp_stopcal == 1
                        try
                        while resp_qa2 ~= 0 && resp_qa2 ~= 1
                            prompt = ('Calibration complete! Continue to Quality Analysis? (0 = no, 1 = yes) ');
                            DrawFormattedText(w,prompt,'center','center',white);
                            Screen('Flip',w);
                            resp_qa2 = GetNumber(Keyboard);
                        end
                        catch
                            prompt = ('Please enter again');
                            DrawFormattedText(2,prompt,'center','center',white);
                            Screen('Flip',w);
                            resp_qa = GetNumber(Keyboard);
                        end
                    end
                end
                if resp_qa2 == 1 || resp_qa2 == 0
                    break
                end
                if resp_stopcal == 0
                    continue
                end
            end
        end

        %Get final calibrated points for quality analysis
        calibrated_idx = find(cal_idx(:,1) == 1);
        calibrated_points = points_to_collect(calibrated_idx,:);
        calib.leave_calibration_mode;
    end
end
if resp_qa == 0 || resp_qa2 == 0
    Accuracy = 0;
    Precision = 0;
else
%%%%%% Calibration Quality Analysis %%%%%%
    %Draw start screen
    start = [ 'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep 'QA_welcome.jpg'];
    imdata = imread(start);
    [iy, ix, ~] = size(imdata);
    imagetex = Screen('MakeTexture', w, imdata(1:round(0.7*iy),1:ix,:));
    points_to_collect_example = [0.1,0.9;0.5,0.9;0.9,0.9;];
    oval_points_example = zeros(size(points_to_collect_example,1),4);
    for point = 1:size(points_to_collect_example,1)
        oval_points_example(point,1) = points_to_collect_example(point,1) * rect(3) - 18;
        oval_points_example(point,2) = points_to_collect_example(point,2) * rect(4) - 18;
        oval_points_example(point,3) = points_to_collect_example(point,1) * rect(3) + 18;
        oval_points_example(point,4) = points_to_collect_example(point,2) * rect(4) + 18;
    end
    shrink = 1; %will be used to shrink the point in the calibration animation
    KbQueueCreate();
    KbQueueStart();
    
    flag = 0;
    while KbQueueCheck == 0
        for cal_point = randperm(size(points_to_collect_example,1))
            white = [250 250 250]; %color, should be white
            for animate = 1:15 %animates the oval shrinking by adding/subtracting an increasing constant to the oval dimensions
                Screen('DrawTexture', w, imagetex);
                rect_oval = [oval_points_example(cal_point,1)+shrink*animate,oval_points_example(cal_point,2)+shrink*animate,oval_points_example(cal_point,3)-shrink*animate,oval_points_example(cal_point,4)-shrink*animate];
                Screen('FillOval',w,white,rect_oval);
                Screen('Flip',w);
                Kb = KbQueueCheck;
                if Kb ~= 0
                    flag = 1;
                    break
                end
                pause(0.07)
            end
            Kb = KbQueueCheck;
            if Kb ~= 0 || flag == 1
                break
            end
            pause(1)
        end
        if Kb ~= 0 || flag == 1
            break
        end
    end
    KbQueueStop();
        
    countdown_path = {'C:' filesep 'Users' filesep 'activate-ccn' filesep 'Documents' filesep 'MATLAB' filesep 'NewSRM' filesep 'Tobii' filesep };
    num{1} = sprintf('%sQA_3.jpg',strjoin(countdown_path,''));
    num{2} = sprintf('%sQA_2.jpg',strjoin(countdown_path,''));
    num{3} = sprintf('%sQA_1.jpg',strjoin(countdown_path,''));
        
    for count = 1:3 %Draws each countdown screen for 1 second
        number = char(num{count}); %num is the character string of the countdown file
        imdata=imread(number);
        imagetex=Screen('MakeTexture', w, imdata);
        Screen('DrawTexture', w, imagetex);
        Screen('Flip', w);
        pause(1)
    end
        
    %Get gaze data for calculations of calibration quality
    gaze = cell(1,1,size(points_to_collect,1));
    for cal_point = randperm(size(points_to_collect,1))
        white = [250 250 250]; %color, should be white 
        for animate = 1:15 %animates the oval shrinking by adding/subtracting an increasing constant to the oval dimensions
           rect_oval = [oval_points(cal_point,1)+shrink*animate,oval_points(cal_point,2)+shrink*animate,oval_points(cal_point,3)-shrink*animate,oval_points(cal_point,4)-shrink*animate];
           Screen('FillOval',w,white,rect_oval);
           Screen('Flip',w);
           pause(0.07);
        end
        %collect gaze data
        result = eyetracker.get_gaze_data;
        pause(1)
        gaze{:,:,cal_point} = eyetracker.get_gaze_data;
    end
    
    %Get gaze data of points without gaze data
    eyetracker_Hz = 60; %eyetracker Hz is used to determine if enough gaze data is valid
    valid_gaze = cell(1,1,size(gaze,3)); %stores validity of left and right eye gaze data
    use_gaze = cell(size(gaze,3),1); %stores index of whether or not at least one eye is valid for a quantum of eye data
    points_to_recalibrate_bin = zeros(size(gaze,3),1); %logical index of whether or not 80% of the eye data recorded for a point is valid, and therefore whether or not it should be recalibrated
    valid_gaze_size = cell(size(gaze,3),1); %the number of valid gaze points for each calibrated point
    for cal_point = 1:size(gaze,3)
        for row = 1:length(gaze{:,:,cal_point}) %1 'row' for every moment of gaze data
            valid_gaze{:,:,cal_point}(row,1) = gaze{:,:,cal_point}(1,row).LeftEye.GazePoint.Validity; %records validity of gaze data for left eye
            valid_gaze{:,:,cal_point}(row,2) = gaze{:,:,cal_point}(1,row).RightEye.GazePoint.Validity; %records validity of gaze data for right eye
            if valid_gaze{:,:,cal_point}(row,1) == 1 && valid_gaze{:,:,cal_point}(row,2) == 1 %if the right or left eye is valid, record it as valid in use_gaze
                use_gaze{cal_point,1}(row,1) = 1;
            end
        end
        valid_gaze_size{cal_point,1} = find(use_gaze{cal_point,1} == 1);
        points_to_recalibrate_bin(cal_point,1) = size(use_gaze{cal_point,1},1) < 0.8*(eyetracker_Hz); %creates a logical index of whether or not 80% of the recorded eye data is valid, with 80% of 60Hz at 60secs == 45.
    end
    
    points_to_recalibrate_idx = find(points_to_recalibrate_bin == 1); %creates an index of rows that should be recalibrated
    points_to_recalibrate = points_to_collect(points_to_recalibrate_idx,:); %creates a matrix of points to be recalibrated by taking the indexed rows of points_to_collect
    
    resp_stopcal = 0;
    if isempty(points_to_recalibrate) %Don't recalibrate if all points are properly calibrated
    else
        prompt = ('Assessment incomplete! Move on without completing? (0 = no, 1 = yes) ');
        DrawFormattedText(w,prompt,'center','center',white);
        Screen('Flip',w);
        resp_stopcal = GetNumber(Keyboard);
        try
        while resp_stopcal ~= 0 && resp_stopcal ~= 1
            prompt = ('Assessment incomplete! Move on without completing? (0 = no, 1 = yes) ');
            DrawFormattedText(w,prompt,'center','center',white);
            Screen('Flip',w);
            resp_stopcal = GetNumber(Keyboard);
        end
        catch
            prompt = ('Please enter again');
            DrawFormattedText(2,prompt,'center','center',white);
            Screen('Flip',w);
            resp_qa = GetNumber(Keyboard);
        end
       
        while resp_stopcal ~= 1
            for count = 1:3 %Draws each countdown screen for 1 second
                number = char(num{count}); %num is the character string of the countdown file
                imdata=imread(number);
                imagetex=Screen('MakeTexture', w, imdata);
                Screen('DrawTexture', w, imagetex);
                Screen('Flip', w);
                pause(1)
            end
            for idx = randperm(size(points_to_recalibrate,1))
                cal_point = points_to_recalibrate_idx(idx,1);
                white = [250 250 250]; %color, should be white 
                for animate = 1:15 %animates the oval shrinking by adding/subtracting an increasing constant to the oval dimensions
                   rect_oval = [oval_points(cal_point,1)+shrink*animate,oval_points(cal_point,2)+shrink*animate,oval_points(cal_point,3)-shrink*animate,oval_points(cal_point,4)-shrink*animate];
                   Screen('FillOval',w,white,rect_oval);
                   Screen('Flip',w);
                   pause(0.07);
                end
                %collect gaze data
                result = eyetracker.get_gaze_data;
                pause(1)
                gaze{:,:,cal_point} = eyetracker.get_gaze_data;

                for row = 1:length(gaze{:,:,cal_point}) %1 'row' for every moment of gaze data
                    valid_gaze{:,:,cal_point}(row,1) = gaze{:,:,cal_point}(1,row).LeftEye.GazePoint.Validity; %records validity of gaze data for left eye
                    valid_gaze{:,:,cal_point}(row,2) = gaze{:,:,cal_point}(1,row).RightEye.GazePoint.Validity; %records validity of gaze data for right eye
                    if valid_gaze{:,:,cal_point}(row,1) == 1 && valid_gaze{:,:,cal_point}(row,2) == 1
                        use_gaze{cal_point,1}(row,1) = 1;
                    end
                end
                valid_gaze_size{cal_point,1} = find(use_gaze{cal_point,1} == 1);
                points_to_recalibrate_bin(cal_point,1) = size(use_gaze{cal_point,1},1) < 0.8*(eyetracker_Hz); %Only uses points that have 80% validity
            end
            points_to_recalibrate_idx = find(points_to_recalibrate_bin == 1);
            points_to_recalibrate = points_to_collect(points_to_recalibrate_idx,:);
            
            resp_stopcal = 2;
            if isempty(points_to_recalibrate) == 0
                while resp_stopcal ~= 0 && resp_stopcal ~= 1
                    prompt = ('Assessment incomplete! Move on without completing? (0 = no, 1 = yes) ');
                    DrawFormattedText(w,prompt,'center','center',white);
                    Screen('Flip',w);
                    resp_stopcal = GetNumber(Keyboard);
                end
            end
            
            if resp_stopcal == 1 || isempty(points_to_recalibrate)
                break
            end
        end
    end

    %Get mean distance of eyes from eyetracker
    try
    Distancexyz_all = cell(1,1,size(gaze,3)); %will be (x,y,z) coordinates for gaze position, with the eyetracker being (0,0,0)
    valid_gaze = cell(1,1,size(gaze,3)); %index of what gaze data is valid
    used = zeros(size(gaze,3),1);
    for cal_point = 1:size(gaze,3)
        for row = 1:length(gaze{:,:,cal_point}) %1 'row' for every moment of gaze data
            valid_gaze{:,:,cal_point}(row,1) = gaze{:,:,cal_point}(1,row).LeftEye.GazeOrigin.Validity; %records validity of gaze data for left eye
            valid_gaze{:,:,cal_point}(row,2) = gaze{:,:,cal_point}(1,row).RightEye.GazeOrigin.Validity; %records validity of gaze data for right eye
            for coord = 1:3 %1 'coord' for each x,y,z, coordinate
                if valid_gaze{:,:,cal_point}(row,1) == 1 && valid_gaze{:,:,cal_point}(row,2) == 1 %if both the left and the right eye are valid, use the mean of their distance in the user coordinate sytem
                    Distancexyz_all{:,:,cal_point}(row,:) = (gaze{:,:,cal_point}(1,row).LeftEye.GazeOrigin.InUserCoordinateSystem + gaze{:,:,cal_point}(1,row).RightEye.GazeOrigin.InUserCoordinateSystem)/2;
                else
                    %if valid_gaze{:,:,cal_point}(row,1) == 1 %if just the left eye is valid, just use the left eye
                        %Distancexyz_all{:,:,cal_point}(row,:) = gaze{:,:,cal_point}(1,row).LeftEye.GazeOrigin.InUserCoordinateSystem;
                    %else
                        %if valid_gaze{:,:,cal_point}(row,2) == 1 %if just the right eye is valid, just use the right eye
                        %Distancexyz_all{:,:,cal_point}(row,:) = gaze{:,:,cal_point}(1,row).RightEye.GazeOrigin.InUserCoordinateSystem;
                        %end
                    %end
                end
            end
        end
        if cal_point == 1
            Distancexyz = Distancexyz_all{:,:,cal_point};
        else
            Distancexyz = [Distancexyz;Distancexyz_all{:,:,cal_point}];
        end
    end

  
    Distancexyz = Distancexyz(any(Distancexyz ~= 0,2),:); %eliminate 0 values
    Distancexyz = mean(Distancexyz); %Distancexyz = the mean of all the distance data
    DistanceBoth = sqrt(Distancexyz(1,1)^2 + Distancexyz(1,2)^2 + Distancexyz(1,3)^2); %%pythagorean theorem, DistanceBoth = hypotenuse to eyes
   
    %Mean of Gazepoints
    
    used_eye = cell(size(gaze,3),1); %idx of validity of eye data
    cal_data_x = cell(size(gaze,3),1); %left and right gaze position on display for the x-axis
    cal_data_y = cell(size(gaze,3),1); %left and right gaze position on display for the y-axis
    xy = cell(size(gaze,3),1); %average of left and right gaze from x and y
        for cal_point = 1:size(gaze,3) %cal_point = each gaze test point is its own cell
            for row = 1:length(gaze{:,:,cal_point})
                %get idx of which points were used in gaze test
                used_eye{cal_point}(row,1) = gaze{:,:,cal_point}(:,row).LeftEye.GazePoint.Validity;
                used_eye{cal_point}(row,2) = gaze{:,:,cal_point}(:,row).RightEye.GazePoint.Validity;
                %compile left x and right x data as well as left y and right y
                %data
                cal_data_x{cal_point}(row,1) = gaze{:,:,cal_point}(:,row).LeftEye.GazePoint.OnDisplayArea(1);
                cal_data_x{cal_point}(row,2) = gaze{:,:,cal_point}(:,row).RightEye.GazePoint.OnDisplayArea(1);
                cal_data_y{cal_point}(row,1) = gaze{:,:,cal_point}(:,row).LeftEye.GazePoint.OnDisplayArea(2);
                cal_data_y{cal_point}(row,2) = gaze{:,:,cal_point}(:,row).RightEye.GazePoint.OnDisplayArea(2);

                if used_eye{cal_point}(row,1) == 1 && used_eye{cal_point}(row,2) == 1
                   xy{cal_point}(row,1) = mean(cal_data_x{cal_point}(row,:),2);
                   xy{cal_point}(row,2) = mean(cal_data_y{cal_point}(row,:),2);
                end
            end 
            xy{cal_point} = xy{cal_point}(any(xy{cal_point} ~= 0,2),:);
            used(cal_point,1) = isempty(xy{cal_point});   
        end
        
    
    %Accuracy
    used_final = find(used == 0); %used_final = index of points that had enough valid gaze data
    [w,~] = Screen('DisplaySize',screenNumber);
    pixel_size = w/(rect(1,3)); %%not sure how to automatically detect pixel size from resolution and monitor size data, report in mm
    Eyetrackeroffset = 20; %%distance between center of eyetracker and bottom of screen. Can't auto detect, report in mm
    xy_means = cell(size(xy)); %means of xy gaze coordinates in pixels for each calibration point
    xy_means_et = cell(size(xy)); %means of xy gaze coordinates in eyetracker coordinates (0:1) for each calibration point
    cal = zeros(size(points_to_collect)); %all points shown for gaze data
    cal(:,1) = points_to_collect(:,1) .* rect(1,3); %converts x coordinates from eyetracker points to pixels
    cal(:,2) = points_to_collect(:,2) .* rect(1,4); %converts y coordinates from eyetracker points to pixels

    %PixelAccuracy_all, OnScreenDistance_all, Angle_all, AngleAccuracyBoth
    PixelAccuracy_all = zeros(size(used_final,1),1); %PixelAccuracy_all = proportion of the xy gazepoints to the xy target calibration points
    OnScreenDistance_all = zeros(size(used_final,1),1); %OnScreenDistance_all = distance from xy gazepoints to the xy target calibration points in mm
    Angle_all = zeros(size(used_final,1),1); %Angle_all = difference between gaze angles of gazepoint and target point
    AngleAccuracy_all = zeros(size(used_final,1),1); %AngleAccuracy_all = proportion of gaze angle and gazepoint angle
    for idx = 1:size(used_final,1)
        cal_point = used_final(idx,1);
        xy_means_et{cal_point,1}(:,1) = mean(xy{cal_point,1}(:,1));
        xy_means_et{cal_point,1}(:,2) = mean(xy{cal_point,1}(:,2));
        xy_means{cal_point,1}(1,1) = xy_means_et{cal_point,1}(1,1)*rect(1,3);
        xy_means{cal_point,1}(1,2) = xy_means_et{cal_point,1}(1,2)*rect(1,4);
        PixelAccuracy_all(cal_point,1) = sqrt((cal(cal_point,1) - xy_means{cal_point,1}(1,1))^2 + (cal(cal_point,2) - xy_means{cal_point,1}(1,2))^2);
        xpixels = abs((xy_means{cal_point,1}(1,1)) - (cal(cal_point,1))); %pixel shift between gaze point and target for x
        ypixels = abs((xy_means{cal_point,1}(1,2)) - (cal(cal_point,2))); %pixel shift between gaze point and target for y
        OnScreenDistance_all(cal_point,1) = pixel_size * sqrt(((xy_means{cal_point,1}(1,1)) - (xpixels/2))^2 + (ypixels - xy_means{cal_point,1}(1,2) + (Eyetrackeroffset/pixel_size))^2);
        Angle_all(cal_point,1) = atand(OnScreenDistance_all(cal_point,1)/DistanceBoth);

        AngleAccuracy_all(cal_point,1) = (pixel_size * PixelAccuracy_all(cal_point,1) * (cosd(Angle_all(cal_point,1)))^2)/DistanceBoth;
    end
        
    %Precision
    PixelPrecision_all = zeros(size(used_final,1),1); %mean of differentials between successive gazepoints
    AnglePrecision_all = zeros(size(used_final,1),1); %conversion of PixelPrecision_all to degrees of gaze angle
       for idx = 1:size(used_final,1)
            cal_point = used_final(idx,1);
            if size(xy{cal_point,1},1) == 1   %in case there's only one row of gaze data
            else
                dX_et = diff(xy{cal_point,1}(:,1)); %dX_et = all differentials between successive gazepoints along the X axis in eyetracker coordinates
                dX = dX_et .* rect(1,3); %dX = dX_et in pixel coordinates
                dY_et = diff(xy{cal_point,1}(:,2)); %dY_et = all differentials between successive gazepoints along the Y axis in eyetracker coordinates
                dY = dY_et .* rect(1,4); %dY = dY_et in pixel coordinates
                diffs = sqrt(dX.^2 + dY.^2); %diffs = total differential between successive xy pixel coordinates
                PixelPrecision_all(cal_point,1) = sqrt(mean(diffs)^2); 
                AnglePrecision_all(cal_point,1) = (pixel_size * PixelPrecision_all(cal_point,1) * (cosd(Angle_all(cal_point,1)))^2)/DistanceBoth;
            end
        end
        
    %Rating System
    AngleAccuracy_all = AngleAccuracy_all(any(AngleAccuracy_all ~= 0,2),:);
    AnglePrecision_all = AnglePrecision_all(any(AnglePrecision_all ~= 0,2),:);
    
    Accuracy = mean(AngleAccuracy_all);
    Precision = mean(AnglePrecision_all);
    if calibrate == 1
        Calibrated_points = calibration_result;
    end
    catch
        Accuracy = 0;
        Precision = 0;
        Calibrated_points = 0;
    end
end
    if opened == 0
        sca
    end
    %Store Accuracy and Precision in the task script
%%