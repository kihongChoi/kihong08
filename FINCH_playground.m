% playground
clear; clc; close all;
closescreen;

% this is for git test
myanyvar = [2, 5, 6, 1];
gitTest2 = myanyvar;

% ===== parameter initialization =====
	paramInit = {
		'FZP'  			'f' 			400 		'mm';
		
		'Scanning'  	'Range_x'   	2.7   		'mm';%1.8
		'Scanning'  	'Range_y'   	1.2   		'mm';%1.2
		'Scanning'  	'Range_z'   	100   		'mm';
		'Scanning'  	'Step_x'    	50  		'um';%50
		'Scanning'  	'Step_y'    	50  		'um'; %54 x 24 ?	
		'Scanning'  	'Step_z'    	100  		'um';
		'Scanning'  	'InitPos_x' 	2.2  		'mm';   %31.4455
		'Scanning'  	'InitPos_y' 	233.7 		'mm';   %287.9887
		
		'CCD'   		'Resolution_h'  2736    	'px';
		'CCD'   		'Resolution_v'  2192    	'px';
		'CCD'   		'PixelPitch'    4.54    	'um';
		'CCD'   		'Exposure'      0     		'-';
		'CCD'   		'Gain'          6      '-';
		'CCD'   		'Shutter'       999   		'ms';
		'CCD'   		'FrameRate'     1         	'%';
		
		'SLM'   		'ActiveArea_h'  15.36    	'mm';
		'SLM'   		'ActiveArea_v'  8.64    	'mm';
		'SLM'   		'Resolution_h'  1920    	'px';
		'SLM'   		'Resolution_v'  1080    	'px';
		'SLM'   		'PixelPitch'    8   		'um';
		
		'Wavelength'    'R' 			650 		'nm';
		'Wavelength'    'G' 			550 		'nm';
		'Wavelength'    'B' 			425 		'nm';
		
		'Phase'         'Step'          120     	'deg';
        'Operation'		'phaseStep'		3			'int';
		
		'Operation'		'isGreenOnly'   true    	'bool';
		'Operation'     'isDebugMode'   false   	'bool';
		'Operation'     'reconstructionDistance'    30e-3   'mm';
        'Operation'     'iNeedRaw'      false   	'bool';
        'Operation'     'iNeedReconstruction'   false   'bool'
        'Operation'		'isSingleShot'	1		'bool';
        
        'onTheRun'      'noStage'       true        'bool';
        };
    
    T = cell2table(paramInit,'VariableNames',{'Part','Element','Value','Unit'});
        
	params = containers.Map;
	params_raw = paramInit;
	params_raw_values = params_raw(:, 3);
    
for i = 1:length(params_raw_values)
    % ! important
    % var naming rule example: 'CCD' + 'Exposure' = 'CCD_Exposure'
    varName = sprintf('%s_%s', cell2mat(params_raw(i, 1)), cell2mat(params_raw(i, 2)));
    eval(['params(''', varName, ''') = cell2mat(params_raw_values(', num2str(i), '));']);
end
    
% Unit correction
	params('FZP_f') 				= 1e-3 * params('FZP_f');
	params('SLM_ActiveArea_h') 		= 1e-3 * params('SLM_ActiveArea_h');
	params('SLM_ActiveArea_v') 		= 1e-3 * params('SLM_ActiveArea_v');
	params('SLM_PixelPitch') 		= 1e-6 * params('SLM_PixelPitch');
	params('Scanning_InitPos_x') 	= params('Scanning_InitPos_x');
	params('Scanning_InitPos_y') 	= params('Scanning_InitPos_y');
	params('Scanning_Range_x') 		= 1e-3 * params('Scanning_Range_x');
	params('Scanning_Range_y') 		= 1e-3 * params('Scanning_Range_y');
	params('Scanning_Step_x') 		= 1e-6 * params('Scanning_Step_x');
	params('Scanning_Step_y') 		= 1e-6 * params('Scanning_Step_y');
	params('Scanning_Step_z') 		= 1e-3 * params('Scanning_Step_z');
	params('CCD_PixelPitch') 		= 1e-6 * params('CCD_PixelPitch');
	params('Wavelength_B') 			= 1e-9 * params('Wavelength_B');
	params('Wavelength_G') 			= 1e-9 * params('Wavelength_G');
	params('Wavelength_R') 			= 1e-9 * params('Wavelength_R');
	params('Phase_Step') 			= params('Phase_Step') * (pi/180);

	if params('Operation_isGreenOnly')
	    params('Wavelength') 		= params('Wavelength_G');
	end
     
% set temporary folder to save temporary fzp and pinhole images
	if exist('fzpImgs', 'dir') ~= 7
	    mkdir('fzpImgs');
    end
    
    dtFormat_filename = datestr(now, 'yyyymmdd-HHMMSS');
    dtFormat_string = datestr(now, 'yyyy.mm.dd HH:MM:SS');

    if exist(dtFormat_filename, 'dir') == 7
		thisFolder = [dtFormat_filename '-take2'];
	else
		thisFolder = dtFormat_filename;
	end

	if exist(sprintf('%s/CH', thisFolder), 'dir') ~= 7
		mkdir(sprintf('%s/CH', thisFolder));
    end
    
    if exist(sprintf('%s/rawImg', thisFolder), 'dir') ~= 7
		mkdir(sprintf('%s/rawImg', thisFolder));
    end

% break before the initiation
	note = input('anything to note?: ');
	isOkay = input('Check everything is okay (if okay, enter 1): ');


% print log messages
	log_filename = sprintf('%s/FINCH_log_%s.txt', thisFolder, dtFormat_filename);
	diary(log_filename);
	diary on;
	disp(note);
    disp('');
	disp('FINCH scanning operation initiated');
	disp('');
	disp(sprintf('Date and time: %s', dtFormat_string));
	disp('');
	disp(T);
	disp('');

	diary off;
	
if ~params('Operation_isSingleShot')
	% twitter notifier setting
		credentials.ConsumerKey='jdWqpjvAwe6DkUVoTUxEQ4TfE'; 
		credentials.ConsumerSecret = 'BnZyG4WQzpCowISqMbW9NO0krfGqfSdeAtvvF1x0DvYrrayNSY'; 
		credentials.AccessToken = '748338151362486272-vc0FHZHDl0r75Khf76X3xXwYUM5xgiB'; 
		credentials.AccessTokenSecret = 'tbXuIrRwrVYymROW9R9P5H4eHCKMBCMJ0cFoBY1GJFJba'; 
		
		tw = twitty(credentials);
		
	% email notifier setting
		mail_destination = 'kihong08@gmail.com';
		
		setpref('Internet','SMTP_Server','smtp.gmail.com');
		setpref('Internet','E_mail','doa.noti@gmail.com');
		setpref('Internet','SMTP_Username','doa.noti');
		setpref('Internet','SMTP_Password','doa29979');
		
		props = java.lang.System.getProperties;
		props.setProperty('mail.smtp.auth','true');
		props.setProperty('mail.smtp.socketFactory.class', ...
		                  'javax.net.ssl.SSLSocketFactory');
		props.setProperty('mail.smtp.socketFactory.port','465');
end	




% ===== initialize stages =====
if ~params('Operation_isSingleShot')
	input('Declutter around the stages\n');
	disp('Stage initiation');
	scanningStep_xy = params('Scanning_Step_x');
	scanningStep_z = params('Scanning_Step_z');

	fpos = get(0, 'DefaultFigurePosition');
	fpos(1) = 1200;
	fpos(3) = 640;
	fpos(4) = 450;
	% 
	% disp(sprintf('scanning step for x and y is %d (z is neglected).', scanningStep_xy));

	f_x = figure('Position', fpos, 'Menu', 'None', 'Name', 'APT GUI X');
	fpos(2) = 100;
	f_y = figure('Position', fpos, 'Menu', 'None', 'Name', 'APT GUI Y');

	stage_x = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400], f_x);
	stage_y = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400], f_y);

	stage_x.StartCtrl;
	stage_y.StartCtrl;

	SN_x = 45863501;
	SN_y = 45863507;

	set(stage_x, 'HWSerialNum', SN_x);
	set(stage_y, 'HWSerialNum', SN_y);

	stage_x.Identify;
	stage_y.Identify;

    while 1
        disp('If you just finished the scanning process, then it is okay to choose not to homing, otherwise stage must be homed in advance.');
        setHome = input('Set home? (0: do nothing, 1: set home, 2: just move to initial position): ');
        
        if setHome == 1
            stage_y.SetAbsMovePos(0, 3);
            stage_y.MoveAbsolute(0, 0==1);
            input('is y closed to home?');

            stage_x.SetAbsMovePos(0, 3);
            stage_x.MoveAbsolute(0, 0==1);
            input('is x closed to home?');

            stage_x.MoveHome(0,0);
            stage_y.MoveHome(0,0);
            input('is Home?');
            % home check
            
            stage_x.SetAbsMovePos(0, params('Scanning_InitPos_x'));
            stage_y.SetAbsMovePos(0, params('Scanning_InitPos_y'));

            stage_y.MoveAbsolute(0, 0==1);
            input('is y inPosition?');
            stage_x.MoveAbsolute(0, 0==1);
            input('is x inPosition?');  
            diary on;
            disp('Home set and position is reset');
            diary off;
            break;
        elseif setHome == 2
            stage_x.SetAbsMovePos(0, params('Scanning_InitPos_x'));
            stage_y.SetAbsMovePos(0, params('Scanning_InitPos_y'));

            stage_y.MoveAbsolute(0, 0==1);
            input('is y inPosition?');
            stage_x.MoveAbsolute(0, 0==1);
            input('is x inPosition?');  
            diary on;
            disp('Position is reset');
            diary off;
            break;
        elseif ~setHome
            break;
        end
    end
	
	stage_x.SetJogStepSize(0, params('Scanning_Step_x')*1000);
	stage_y.SetJogStepSize(0, params('Scanning_Step_y')*1000);

	disp('Stage initiated');
    pause(1);
end
    
% ===== initialize CCD =====
    imaqreset;
	vid = videoinput('pointgrey', 1, 'F7_Mono16_2736x2192_Mode0');
	src = getselectedsource(vid);

	vid.FramesPerTrigger = 1;
	src.Gamma = 3;

	src = getselectedsource(vid);

	vid.FramesPerTrigger = 1;


	set(src, 'ExposureMode', 'Manual');

	set(src, 'GainMode', 'Manual');
	set(src, 'ShutterMode', 'Manual');
	set(src, 'FrameRatePercentageMode', 'Manual');

	set(src, 'Exposure', params('CCD_Exposure'));
	set(src, 'Gain', params('CCD_Gain'));
	set(src, 'Shutter', params('CCD_Shutter'));
	set(src, 'FrameRatePercentage', params('CCD_FrameRate'));

    disp('CCD initiated');
    
% ===== check FZP exists (otherwise, make it) =====
	if exist(sprintf('fzp_%s_1.png', num2str(params('FZP_f'))), 'file') ~= 2
	    % otherwise, make one
	    generateFZP(params);
    end
%     fzp1 = 'fzp_0.55_1-4.png';
%     fzp2 = 'fzp_0.55_2-4.png';
%     fzp3 = 'fzp_0.55_3-4.png';

% ===== prepare for the iteration process =====
	x = 1:round(params('Scanning_Range_x') / params('Scanning_Step_x'));
	y = 1:round(params('Scanning_Range_y') / params('Scanning_Step_y'));
	z = 1; 		%forced for lateral scanning only -> to be modified later
    if params('Operation_isSingleShot')
        x = 1; y = 1; z = 1;
    end

    % warn if scanning step is too large (e.g. mistyped unit)
    if x > 1000
    	input('Number of scanning step is too large. Check the unit of range or step');
    end

	pp = params('CCD_PixelPitch');
	res = params('CCD_Resolution_v');
	if params('Operation_isGreenOnly')
		lambda = params('Wavelength_G');
	else
		lambda = thisWavelength;		% need to be modified later
	end

% ===== start iteration process =====
	if ~params('Operation_isSingleShot')
	    disp('get out');
	    for i = 1:5
	        pause(0.8);
	        fprintf('%d\n', 6-i);
	    end
	end

	diary on;
	initTime = clock;
	msg_init = sprintf('[FINCH]Operation starts: %s', dtFormat_string);
	disp(msg_init);
	disp(' ');
	if ~params('Operation_isSingleShot')
	    S = tw.updateStatus(msg_init);
	end

	h = waitbar(0,'Loading...',...
	            'Name','Status',...
	            'CreateCancelBtn',...
	            'setappdata(gcbf,''cancel_callback'',1)');
	setappdata(h,'cancel_callback',0);

for zz = z
	loopTime_z = clock;
    for yy = y
    	rowCell = {};		% temporary storage, flushed when the new row starts
    	loopTime_y = clock;
        
        
        for xx = x
    		if rem(xx, 25) == 0
    			try
                S = tw.updateStatus(sprintf('[FINCH] x%03d/%d, y%03d_z%03d', xx, length(x), yy, zz));
            	end
            end

            try
                diary off;
                % phase step iteration
                for i = 1:params('Operation_phaseStep')
                    % if - end below is related to waitbar
                    if getappdata(h,'cancel_callback')
                        break;
                    end

                    closescreen;
                    fprintf('FZP change, recording on the go: %d/%d\n', i, params('Operation_phaseStep'));
                    filename = sprintf('fzp_%s_%s-%s.png', num2str(params('FZP_f')), num2str(i), num2str(params('Operation_phaseStep')));
                    fullscreen(filename);

                    pause(0.2); 			% time for stabilization

                    eval(['h', num2str(i), ' = double(getsnapshot(vid));']);
                    eval(['h', num2str(i), ' = h', num2str(i), '(:, (2736-2192)/2 + 1:(2736-2192)/2 + 2192);']); 

                    if params('Operation_iNeedRaw')
                        eval(['this_H = h', num2str(i), ';']);
                        imwrite(imresize(uint16(real(this_H)), 0.5), sprintf('%s/rawImg/h_z%02dy%02dx%02d_%d.tif', dtFormat_filename, zz, yy, xx, i));
                    end
                    closescreen;

                    index_now = (zz-1)*length(y)*length(x)*params('Operation_phaseStep') + (yy-1)*length(x)*params('Operation_phaseStep') + (xx-1)*params('Operation_phaseStep') + i;
                    index_total = length(z)*length(y)*length(x)*params('Operation_phaseStep');
                    waitbar(index_now / index_total, h, sprintf('Operating...[%03d/%d, %03d/%d, %03d/%d] - %.2f%%', xx, length(x), yy, length(y), zz, length(z), 100*index_now/index_total));
                end

            % phase shifting procedure - complex hologram: CH
                if params('Operation_phaseStep') == 3
                    d1 = 0; d2 = params('Phase_Step'); d3 = 2 * d2;
                    CH = h1*(exp(-1j*d3)-exp(-1j*d2)) + h2*(exp(-1j*d1) - exp(-1j*d3)) + h3*(exp(-1j*d2) - exp(-1j*d1));
                elseif params('Operation_phaseStep') == 4
                    CH = (h1-h3) - 1j*(h2-h4);
                end

            % save single complex hologram into one .mat file (to preserve imagenary terms)
                eval(['h_x', num2str(sprintf('%03d', xx)), '_y', num2str(sprintf('%03d', yy)), '_z', num2str(sprintf('%03d', zz)), '= CH;']);
                eval(['save ', sprintf('%s/CH/CH_x%03dy%03dz%03d.mat', dtFormat_filename, xx, yy, zz), ' h_x', num2str(sprintf('%03d', xx)), '_y', num2str(sprintf('%03d', yy)), '_z', num2str(sprintf('%03d', zz)), ';']);
                eval(['clear h_x', num2str(sprintf('%03d', xx)),'_y' , num2str(sprintf('%03d', yy)), '_z', num2str(sprintf('%03d', zz)), ';']);
            % print msg
                diary on;
                fprintf('%s: [x%03d/%d | y%03d/%d | z%03d/%d]\n', datestr(now, 'yyyy.mm.dd-HH:MM:SS'), xx, length(x), yy, length(y), zz, length(z));

            %moveStage(params('stage_x'), 0, params);
                if ~params('Operation_isSingleShot')
                    stage_x.MoveJog(0,1);
                end


            catch exception
            	disp(exception);
                try
                    S = tw.updateStatus('[FINCH] operational error');
                end
                sendmail(mail_destination, '[FINCH] operational error', sprintf('%s\nTHIS IS AN ERROR!!', note), {log_filename});
                continue;
            end
        end     % end of row scanning
        
        % ===== Set stage to next step =====
	        if ~params('Operation_isSingleShot')
		        stage_x.SetAbsMovePos(0, params('Scanning_InitPos_x'));
		        stage_x.MoveAbsolute(0, 1==0);
		        stage_y.MoveJog(0,1);
	        end
	        
	        
        % ===== row end notification =====
			tLoop_y = fix(etime(clock, loopTime_y));

			t_el_sec = round(rem(etime(clock, initTime), 60));
            t_el_min = round(rem(fix(etime(clock, initTime)/60), 60));
            t_el_hr = fix(etime(clock, initTime)/3600);

		    %t_el_sec = rem(fix(etime(clock, initTime)), 60);
		    %t_el_min = fix(fix(etime(clock, initTime)/60));
		    %t_el_hr = fix(fix(etime(clock, initTime)/3600));
		    
		    if ~params('Operation_isSingleShot')
			    twMsg = sprintf('[FINCH] [y%03d/%d | z%03d/%d] %s sec / %02d:%02d:%02d passed', yy, length(y), zz, length(z), num2str(tLoop_y), t_el_hr, t_el_min, t_el_sec);
			    fprintf('%s: %s', datestr(now, 'yyyy.mm.dd-HH:MM:SS'), twMsg);
			    
			    try
			        S = tw.updateStatus(twMsg);
			    catch exception
			        disp('twit failed');
			        sendmail(mail_destination, '[FINCH] twit error', twMsg);
			        continue;
			    end
			end

            disp(' ');
	        
        
    end         % end of lateral scanning

    %moveStage(params('scanningStep_z'), 'z', x, y, z, length(steps_x), length(steps_y), length(steps_z));
end

% ===== send notification and wrap up =====
msg_done = sprintf('[FINCH] Operation Finished: [x%03d/%d | y%03d/%d | z%03d/%d], elapsed time %02d:%02d:%02d', xx, length(x), yy, length(y), zz, length(z), t_el_hr, t_el_min, t_el_sec);
if ~params('Operation_isSingleShot')
	try
	    S = tw.updateStatus(msg_done);
	catch exception
	    disp('twit failed');
	    sendmail(mail_destination, '[FINCH] twit error', msg_done);
	end

	disp(msg_done);

	diary off;
    mail_title = sprintf('[FINCH] Scan finished - %s', dtFormat_string);
	try
        sendmail(mail_destination, mail_title, sprintf('%s\n\n%s', note, msg_done), {log_filename});
    end
end

% kill process
    if ~params('Operation_isSingleShot')
        stage_x.SetAbsMovePos(0, params('Scanning_InitPos_x'));
        stage_y.SetAbsMovePos(0, params('Scanning_InitPos_y'));
        stage_x.MoveAbsolute(0, 1==0);
        stage_y.MoveAbsolute(0, 1==0);
    end

    closescreen;
    close all;
	delete(findall(0,'type','figure','tag','TMWWaitbar'));
