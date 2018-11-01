Tobii = EyeTrackingOperations();
eyetracker = Tobii.find_all_eyetrackers;
calib = ScreenBasedCalibration(eyetracker);
calib.leave_calibration_mode