Tobii Operating Procedures
By John Thorp
02/07/18
Edit 11/01/18

	Congratulations, you are running a study with the Tobii X2-60 Eye Tracker

Hardware Setup

The eye tracker camera itself clips onto the base of the computer screen via the clip (I donÕt know how this works yet).
      
The eye tracker then plugs into the Tobii console via its own USB cable, and the console draws power from a 19V DC cable and plugs into the computer via an Ethernet cable and Trendnet Ethernet-USB converter.
      
Software / Code

Edit: JNT 11/2018
	This code is now on github under jnthorp/Tobii_X2-60

You should be using a Matlab code that I, John Thorp, have created, or a variation of your own. If you donÕt have code, contact me at john.n.thorp@gmail.com.

The Tobii Eye Tracker Manager is a quick way to check if your computer is detecting the eye tracker, and is available for free at https://www.tobiipro.com/product-listing/eye-tracker-manager/ . Make sure the eyetracker is showing up before running your task.

You will need the Tobii SDK in your Matlab path (if youÕre using Matlab), available here http://developer.tobiipro.com/matlab.html 

Run a calibration before the task and update at your discretion (maybe three times per whole task / hour-ish). This is called tobii_calibrate, and it should be on aa-cerberus, or (if weÕve been working together) on your local machine. Store the outputs Accuracy, Precision, and Calibrated_points in your task script.

	11 calibration points is best

The tobii_save function outputs all gaze data with columns:

1. Timestamp (in microseconds)
2. Validity
3. X Gaze Point
4. Y Gaze Point
5. Average Pupil Diameter
6. Left Gaze Point X
7. Left Gaze Point Y
8. Left Pupil Diameter
9. Left Gaze Origin X
10. Left Gaze Origin Y
11. Left Gaze Origin Z
12. Right Gaze Point X
13. Right Gaze Point Y
14. Right Pupil Diameter
15. Right Gaze Origin X
16. Right Gaze Origin Y
17. Right Gaze Origin Z

Rundown of scripts:
tobii_setup.m: Sets up Tobii object, finds eyetracker
	Outputs:
		Tobii: Tobii object with commands
		eyetracker: eyetracker object

tobii_calibrate.m : See beginning of script for contents and instructions.
	Inputs:
		num_points: number of points to be calibrated (11 is best practices)
		calibrate: Binary of whether or not to calibrate (will skip to QA)
		Tobii: Tobii object/commands, set up by tobii_setup
		eyetracker: eyetracker object set up by tobii_setup
		w: window Psychtoolbox is using (used in Screen(w,..))
		rect: dimensions of window
	Outputs:
		Accuracy: accuracy calculated by QA
		Precision: precision calculated by QA
		Calibrated_points: how many of the points could be calibrated

tobii_leave_calibrate.m: ONLY USED IF CALIBRATION BREAKS DOWN
Call this from the command line if calibration breaks down, itÕll exit the calibration mode so you can re-enter it

task_code_lines.m: Lines to be integrated into task script
	First: initializes data stream
	Second: records data as the task progresses (have to use every second or so)
	Third: call for tobii_save, just remember to call eyetracker.stop_gaze_data;

tobii_save.m: Compiles all Tobii data into one matrix (call at the end)
	Inputs:
		gaze_data: gaze_data cells
		et0: eyetracker initial timestamp
		rect: dimensions of the window
	Outputs:
		final_gaze_data: final matrix of gaze data (format ripped from eyetribe)
		gaze_data_header: column names for final_gaze_data

