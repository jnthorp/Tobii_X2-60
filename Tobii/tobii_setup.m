function [Tobii, eyetracker] = tobii_setup

Tobii = EyeTrackingOperations();

    %change this with each computer:
eyetrackers = Tobii.find_all_eyetrackers;

try eyetracker = eyetrackers(1,1);
catch
    error('eyetracker not detected')
end