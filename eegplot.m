% eegplot() - display data in a horizontal scrolling fashion 
%             with gui controls (version 3).
% Usage: 
%        >> eegplot(data, 'key1', value1 ...);
%        >> eegplot('noui', data, 'key1', value1 ...);
%
% Input:
%    data         - Input data matrix (chans,timepoints) or (chans x timepoints
%                   x epohcs). In the case the data varialbe 'data' is
%                   preceeded by 'noui', the gui control are removed.
%
% Optional inputs:
%    'srate'      - Sampling rate in Hz {default|0: 256 Hz}
%    'spacing'    - scale for the values (default|0: max(data)-min(data))
%    'eloc_file'  - Electrode filename as in >> topoplot example
%                    [] -> no labels; default|0 -> integers 1:nchans
%                    vector of integers -> channel numbers
%    'winlength'  - Number of seconds of EEG displayed {default 5 (seconds
%                   for continuous data or epochs for data epochs)}
%    'title'      - title of the figure
%    'position'   - position of the figure [cornerx cornery width height].
%    'trialstag'  - points to tag (i.e. trials delimitation {default []}
%    'winrej'     - array of rejection windows, each row being a rejection
%                   [begpoint endpoint colorR colorV colorB e1 e2 e3 ...]
%                   begpoint and endpoint are the delimitation of the window
%                   colorR colorV colorB indicate the color of the window
%                   e1 e2 e3 ... 0 and 1 represenfing rejected electrode or
%                   component in the window (1=rejected). There must be as
%                   many electrode or component as row in the data array
%    'command'     - command to be evaluated when the button reject is 
%                   pushed (see Outputs).
%    'tag'         - tag to identify the EEGPLOT window.
%    'xgrid'       - ['on'|'off'] toggle the abscice grid on or off. 
%                  Default is 'off'. 
%    'ygrid'       - ['on'|'off'] toggle the ordinate grid on or off 
%                  Default is 'off'. 
%    'submean'     - ['on'|'off'] subtract the mean before displaying on each 
%                  window. Default is 'on'.  
%    'freq'        - maximum frequencies in case on want to plot frequencies.
%    'limits'      - time limits for trials.
%    'color'       - ['on'|'off'] toggle the color for plotting on or off. If
%                  'on' every row has a different color to facilitate
%                  readability. Default is 'off'. 
%    'children'   - handler of a dependant eegplot window to call if the 
%                  current window is affected. Default none {0}. 
%
% Outputs:
%    TMPREJ       - indexes of rejected trials.
%                   this variable is assigned into the global workspave
%                   when the user hit the reject button. If the argument 
%                   command is defined, it can use this variable to perform
%                   various operations. See also EEGPLOT2TRIAL and EEGPLOT2EVENT
%                   for conversion between rejection data types.
%
% Author: Arnaud Delorme & Colin Humphries, CNL / Salk Institute, 1998-2001
%
% See also: eeg_multieegplot(), eegplot2event(), eegplot2trial(), eeglab()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme & Colin Humphries, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: eegplot.m,v $
% Revision 1.1  2002/04/05 17:39:45  jorn
% Initial revision
%
% 4/01 version 3 Arnaud Delorme, CNL / Salk Institute, La Jolla CA (arno@salk.edu)
% 4-28-01 change popup windows; regroup drawing functions; add the trials tags  -ad
% 4-29-01 colored timerange selection with mouse; g.time, electrode and value online display -ad 
% 4-30-01 reorganize menus and buttons, add new ones; electrode selection with mouse; output -ad 
% 5-01-01 multisignal display, add boudary contraints  -ad
% 9-11-01 debugging, inversing Y direction for everything -ad
% 9-16-01 normalization of the positions of button (PC and UNIX compatibility) -ad
% 9-26-01 using 'key', value, matlab calling convention -ad
% 10-10-01 adding 'xgrid', 'ygrid', 'color', 'freq' options  -ad
% 11-10-01 whole restructuration of userdata variable, regroupment in g -ad
% 12-10-01 add trial number (top) and trials limits (bottom) for EEG trials -ad   
% 01-25-02 reformated help & license -ad 
% 03-04-02 preserve data 3D structure (to avoid reserving new memory:worked) -ad 
% 03-08-02 debug cancel and reject button -ad 
% 03-15-02 added readlocs and the use of eloc input structure -ad 
% 03-15-02 re-program noui version -ad 
% 03-17-02 debugging and text -ad & sm
% 03-20-02 more complex names for the callback variables -ad & sm
% 03-22-02 change help message -ad & lf
% ---------------------------------------------------------------------- 
% from an original version by Colin Humphries, 5/98  
% CNL / Salk Institute, La Jolla CA (colin@salk.edu) 
% 5-14-98 v2.1 fixed bug for small-variance data -ch
% 1-31-00 v2.2 exchanged meaning of > and >>, < and << -sm
% 8-15-00 v2.3 turned on SPACING_EYE and added int vector input for eloc_file -sm
% 12-16-00 added undocumented figure position arg (if not 'noui') -sm

% internal variables structure
% All in g except for Eposition and Eg.spacingwhich are inside the boxes
%
% gcf
%    1 - winlength
%    2 - srate 
%    3 - children
% 'backeeg' axis
%    1 - trialtag
%    2 - g.winrej
%    3 - nested call flag
% 'eegaxis'
%    1 - data
%    2 - colorlist
%    3 - submean    % on or off, subtract the mean
%    4 - maxfreq    % empty [] if no gfrequency content
% 'buttons hold other informations' Eposition for instance hold the current postition

function [outvar1] = eegplot(data, varargin); % p1,p2,p3,p4,p5,p6,p7,p8,p9)

% Defaults (can be re-defined):

DEFAULT_PLOT_COLOR = { 'k', [0.7 0.7 0.7]};         % EEG line color
DEFAULT_AXIS_BGCOLOR = [.8 .8 .8];% EEG Axes Background Color
DEFAULT_FIG_COLOR = [.8 .8 .8];   % Figure Background Color
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
YAXIS_NEG = 'off';                % 'off' = positive up 
DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.788095];
                                  % dimensions of main EEG axes
ORIGINAL_POSITION = [100 300 800 500];
                                  
if nargin < 1
   help eegplot
   return
end
				  
% %%%%%%%%%%%%%%%%%%%%%%%%
% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

if ~isstr(data) % If NOT a 'noui' call or a callback from uicontrols

   try
   		if ~isempty( varargin ), g=struct(varargin{:}); 
   		else g= []; end;
   catch
   		disp('Error: calling convention {''key'', value, ... } error'); return;
   end;	
		 
   try, g.srate; 			catch, g.srate		= 256; 	end;
   try, g.spacing; 			catch, g.spacing	= 0; 	end;
   try, g.eloc_file; 		catch, g.eloc_file	= 0; 	end; % 0 mean numbered
   try, g.winlength; 		catch, g.winlength	= 5; 	end; % Number of seconds of EEG displayed
   try, g.position; 		catch, g.position	= [100 300 600 500]; 	end;
   try, g.title; 			catch, g.title		= ['Scroll activity -- eegplot()']; 	end;
   try, g.trialstag; 		catch, g.trialstag	= -1; 	end;
   try, g.winrej; 			catch, g.winrej		= []; 	end;
   try, g.command; 			catch, g.command	= ''; 	end;
   try, g.tag; 				catch, g.tag		= 'EEGPLOT'; end;
   try, g.xgrid;			catch, g.xgrid		= 'off'; end;
   try, g.ygrid;			catch, g.ygrid		= 'off'; end;
   try, g.color;			catch, g.color		= 'off'; end;
   try, g.freq;				catch, g.freq		= []; end;
   try, g.submean;			catch, g.submean	= 'on'; end;
   try, g.children;			catch, g.children	= 0; end;
   try, g.limits;			catch, g.limits	    = [0 1]; end;

   if ndims(data) > 2
   		g.trialstag = size(	data, 2);
   	end;	

   if length(g.srate) > 1
   		disp('Error: srate must be a single number'); return;
   end;	
   if length(g.spacing) > 1
   		disp('Error: g.spacingmust be a single number'); return;
   end;	
   if length(g.winlength) > 1
   		disp('Error: winlength must be a single number'); return;
   end;	
   if isstr(g.title) > 1
   		disp('Error: title must be is a string'); return;
   end;	
   if isstr(g.command) > 1
   		disp('Error: command must be is a string'); return;
   end;	
   if isstr(g.tag) > 1
   		disp('Error: tag must be is a string'); return;
   end;	
   if length(g.position) ~= 4
   		disp('Error: position must be is a 4 elements array'); return;
   end;	
   switch lower(g.xgrid)
	   case { 'on', 'off' },; 
	   otherwise disp('Error: xgrid must be either ''on'' or ''off'''); return;
   end;	
   switch lower(g.ygrid)
	   case { 'on', 'off' },; 
	   otherwise disp('Error: ygrid must be either ''on'' or ''off'''); return;
   end;	
   switch lower(g.submean)
	   case 'on', g.submean  = 1;
	   case 'off', g.submean = 0;  
	   otherwise disp('Error: submean must be either ''on'' or ''off'''); return;
   end;	
   if length(g.freq) > 1
   		disp('Error: winlength must be a single number'); return;
   end;	
   
   switch lower(g.color)
	   case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' }; 
	   case 'off', g.color = { 'k' };  
	   otherwise disp('Error: color must be either ''on'' or ''off'''); return;
   end;	

  [g.chans,g.frames, tmpnb] = size(data);
  g.frames = g.frames*tmpnb;
  
  if g.spacing == 0
    maxindex = min(10000, g.frames);  
    g.spacing = max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
    if g.spacing > 10
      g.spacing = round(g.spacing);
    end
  end

  % set defaults
  % ------------ 
  g.incallback = 0;
  g.winstatus = 1;
  g.wincolor = [ 0.8345 1 0.9560];
  g.setelectrode  = 0;
  [g.chans,g.frames,tmpnb] = size(data);   
  g.frames = g.frames*tmpnb;
  g.nbdat = 1; % deprecated
  g.time  = 0;
  
  % %%%%%%%%%%%%%%%%%%%%%%%%
  % Prepare figure and axes
  % %%%%%%%%%%%%%%%%%%%%%%%%
  
    figh = figure('UserData', g,... % store the settings here
      'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
      'MenuBar','none','tag', g.tag ,'Position',ORIGINAL_POSITION, 'numbertitle', 'off');

	pos = get(gcf,'position'); % plot relative to current axes
	q = [pos(1) pos(2) 0 0];
	s = [pos(3) pos(4) pos(3) pos(4)]./100;
	clf;
      

  % Background axis
  % --------------- 
  ax0 = axes('tag','backeeg','parent',figh,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','off','xgrid','off', 'xaxislocation', 'top'); 

  % Drawing axis
  % --------------- 
  YLabels = num2str((1:g.chans)');  % Use numbers as default
  YLabels = flipud(str2mat(YLabels,' '));
  ax1 = axes('Position',DEFAULT_AXES_POSITION,...
             'userdata', data, ...% store the data here (when in g, slow down display)
   			'tag','eegaxis','parent',figh,...
      'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 g.winlength*g.srate],...
      'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
      'Ylim',[0 (g.chans+1)*g.spacing],...
      'YTick',[0:g.spacing:g.chans*g.spacing],...
      'YTickLabel', YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
      'TickLength',[.005 .005],...
      'Color','none',...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR);

  if isstr(g.eloc_file) | isstruct(g.eloc_file)  % Read in electrode names
     eegplot('setelect', g.eloc_file, ax1);
  end;
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uicontrols
  % %%%%%%%%%%%%%%%%%%%%%%%%%

% positions of buttons
  posbut(1,:) = [ 0.0364    0.0254    0.0385    0.0339 ]; % <<
  posbut(2,:) = [ 0.0824    0.0254    0.0288    0.0339 ]; % <
  posbut(3,:) = [ 0.1824    0.0254    0.0299    0.0339 ]; % >
  posbut(4,:) = [ 0.2197    0.0254    0.0385    0.0339 ]; % >>
  posbut(5,:) = [ 0.1187    0.0203    0.0561    0.0390 ]; % Eposition
  posbut(6,:) = [ 0.4744    0.0236    0.0582    0.0390 ]; % Espacing
  posbut(7,:) = [ 0.2762    0.01    0.0582    0.0390 ]; % elec
  posbut(8,:) = [ 0.3256    0.01    0.0707    0.0390 ]; % g.time
  posbut(9,:) = [ 0.4006    0.01    0.0582    0.0390 ]; % value
  posbut(14,:) = [ 0.2762    0.05    0.0582    0.0390 ]; % elec tag
  posbut(15,:) = [ 0.3256    0.05    0.0707    0.0390 ]; % g.time tag
  posbut(16,:) = [ 0.4006    0.05    0.0582    0.0390 ]; % value tag
  posbut(10,:) = [ 0.5437    0.0458    0.0275    0.0270 ]; % +
  posbut(11,:) = [ 0.5437    0.0134    0.0275    0.0270 ]; % -
  posbut(12,:) = [ 0.6    0.02    0.09    0.05 ]; % cancel
  posbut(13,:) = [-0.1    0.02    0.09    0.05 ]; % accept
  posbut(:,1) = posbut(:,1)+0.2;

% Four move buttons: << < > >>

  u(1) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(1,:), ...
	'Tag','Pushbutton1',...
	'string','<<',...
	'Callback','eegplot(''drawp'',1)');
  u(2) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(2,:), ...
	'Tag','Pushbutton2',...
	'string','<',...
	'Callback','eegplot(''drawp'',2)');
  u(3) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(3,:), ...
	'Tag','Pushbutton3',...
	'string','>',...
	'Callback','eegplot(''drawp'',3)');
  u(4) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(4,:), ...
	'Tag','Pushbutton4',...
	'string','>>',...
	'Callback','eegplot(''drawp'',4)');

% Text edit fields: EPosition ESpacing

  u(5) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(5,:), ...
	'Style','edit', ...
	'Tag','EPosition',...
	'string','0',...
	'Callback', 'eegplot(''drawp'',0);' );
	
  u(6) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(6,:), ...
	'Style','edit', ...
	'Tag','ESpacing',...
	'string',num2str(g.spacing),...
	'Callback', 'eegplot(''draws'',0);' );


% electrodes, postion, value and tag

  u(9) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(7,:), ...
	'Style','text', ...
	'Tag','Eelec',...
	'string','FP1');
  u(10) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(8,:), ...
	'Style','text', ...
	'Tag','Etime',...
	'string','0.00');
  u(11) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(9,:), ...
	'Style','text', ...
	'Tag','Evalue',...
	'string','0.00');

  u(14)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(14,:), ...
	'Style','text', ...
	'Tag','Eelecname',...
	'string','Elec.');
  u(15) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(15,:), ...
	'Style','text', ...
	'Tag','Etimename',...
	'string','Time');
  u(16) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(16,:), ...
	'Style','text', ...
	'Tag','Evaluename',...
	'string','Value');

% ESpacing buttons: + -

  u(7) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(10,:), ...
	'Tag','Pushbutton5',...
	'string','+',...
	'FontSize',8,...
	'Callback','eegplot(''draws'',1)');
  u(8) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(11,:), ...
	'Tag','Pushbutton6',...
	'string','-',...
	'FontSize',8,...
	'Callback','eegplot(''draws'',2)');

  if isempty(g.command) g.command = 'fprintf(''Rejections saved in variable TMPREJ\n'');'; end;
  acceptcommand = [ 'g = get(gcbf, ''userdata'');' ... 
				    'TMPREJ = g.winrej;' ...
                    'if g.children, delete(g.children); end;' ...
                    'delete(gcbf);' ...
		  			g.command ...
                    'clear g;']; % quitting expression
  u(12) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(12,:), ...
	'Tag','Accept',...
	'string','REJECT', 'callback', acceptcommand);
  u(13) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(13,:), ...
	'string','CLOSE', 'callback', ...
		[	'g = get(gcbf, ''userdata'');' ... 
            'if g.children, delete(g.children); end;' ...
			'close(gcbf);'] );

  set(u,'Units','Normalized')
  set(gcf, 'position', g.position);
  
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uimenus
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(7) = uimenu('Parent',figh,'Label','Figure');
  m(8) = uimenu('Parent',m(7),'Label','Print');
  uimenu('Parent',m(7),'Label','Accept & close', 'Callback', acceptcommand );
  uimenu('Parent',m(7),'Label','Close','Callback','delete(gcbf)')
  
  % Portrait %%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''portrait'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
		
  uimenu('Parent',m(8),'Label','Portrait','checked',...
      'on','tag','orient','callback',timestring)
  
  % Landscape %%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''landscape'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
  
  uimenu('Parent',m(8),'Label','Landscape','checked',...
      'off','tag','orient','callback',timestring)

  % Print command %%%%%%%
  uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
  		['RESULT = inputdlg( { ''Enter command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
		 'if size( RESULT,1 ) ~= 0' ... 
		 '  eval ( RESULT{1} );' ...
		 'end;' ...
		 'clear RESULT;' ]);
  
  % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(1) = uimenu('Parent',figh,...
      'Label','Display', 'tag', 'displaymenu');
  
  % window grid %%%%%%%%%%%%%
  % userdata = 4 cells : display yes/no, color, electrode yes/no, trial boundary adapt yes/no (1/0)  
  m(11) = uimenu('Parent',m(1),'Label','Windows', 'tag', 'displaywin', 'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)} );
  uimenu('Parent',m(11),'Label','Windows off','Callback', ...
  	['g = get(gcbf, ''userdata'');' ...
  	 'if g.winstatus' ... 
  	 '  set(gcbo, ''label'', ''Windows off'');' ...
  	 'else' ...
  	 '  set(gcbo, ''label'', ''Windows on'');' ...
  	 'end;' ...
  	 'g.winstatus = ~g.winstatus;' ...
  	 'set(gcbf, ''userdata'', g);' ...
  	 'eegplot(''drawb''); clear g;'] )

	% color
	uimenu('Parent',m(11),'Label','color', 'Callback', ...
  	[ 'g = get(gcbf, ''userdata'');' ...
  	  'g.wincolor = uisetcolor(g.wincolor);' ...
      'set(gcbf, ''userdata'', g ); ' ...
      'clear g;'] )

	% set electrodes
	uimenu('Parent',m(11),'Label','Set electrodes', 'enable', 'off', 'checked', 'off', 'Callback', ...
  	['g = get(gcbf, ''userdata'');' ...
  	 'g.setelectrode = ~g.setelectrode;' ...
  	 'set(gcbf, ''userdata'', g); ' ...
     'if ~g.setelectrode set(gcbo, ''checked'', ''on''); else set(gcbo, ''checked'', ''off''); end;'...
     ' clear g;'] )

	% trials boundaries
	%uimenu('Parent',m(11),'Label','Trial boundaries', 'checked', fastif( g.trialstag(1) == -1, 'off', 'on'), 'Callback', ...
  	%['hh = findobj(''tag'',''displaywin'',''parent'', findobj(''tag'',''displaymenu'',''parent'', gcbf ));' ...
  	% 'hhdat = get(hh, ''userdata'');' ...
  	% 'set(hh, ''userdata'', { hhdat{1},  hhdat{2}, hhdat{3}, ~hhdat{4}} ); ' ...
    %'if ~hhdat{4} set(gcbo, ''checked'', ''on''); else set(gcbo, ''checked'', ''off''); end;' ... 
    %' clear hh hhdat;'] )

  % X grid %%%%%%%%%%%%
  m(3) = uimenu('Parent',m(1),'Label','Grid');
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''xgrid''),2) == 2' ... %on
		        '  set(AXESH,''xgrid'',''off'');',...
		        '  set(gcbo,''label'',''X grid on'');',...
		        'else' ...
		        '  set(AXESH,''xgrid'',''on'');',...
		        '  set(gcbo,''label'',''X grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label','X grid off', 'Callback',timestring)
  
  % Y grid %%%%%%%%%%%%%
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''ygrid''),2) == 2' ... %on
		        '  set(AXESH,''ygrid'',''off'');',...
		        '  set(gcbo,''label'',''Y grid on'');',...
		        'else' ...
		        '  set(AXESH,''ygrid'',''on'');',...
		        '  set(gcbo,''label'',''Y grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label','Y grid on', 'Callback',timestring)

  % Grid Style %%%%%%%%%
  m(5) = uimenu('Parent',m(3),'Label','Grid Style');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''--'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','- -','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-.'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'','':'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','. .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','__','Callback',timestring)
  
  % Scale Eye %%%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'eegplot(''scaleeye'',OBJ1,FIG1);',...
		'clear OBJ1 FIG1;'];
  m(7) = uimenu('Parent',m(1),'Label','Scale I','Callback',timestring);
  
  % Title %%%%%%%%%%%%
  uimenu('Parent',m(1),'Label','Title','Callback','eegplot(''title'')')
  
  % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(2) = uimenu('Parent',figh,...
      'Label','Settings'); 
  
  % Window %%%%%%%%%%%%
  uimenu('Parent',m(2),'Label','Window',...
      'Callback','eegplot(''window'')')
  
  % Samplerate %%%%%%%%
  uimenu('Parent',m(2),'Label','Samplerate',...
      'Callback','eegplot(''samplerate'')')
  
  % Electrodes %%%%%%%%
  m(6) = uimenu('Parent',m(2),'Label','Electrodes');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'YTICK = get(AXESH,''YTick'');',...
		'YTICK = length(YTICK);',...
		'set(AXESH,''YTickLabel'',flipud(str2mat(num2str((1:YTICK-1)''),'' '')));',...
		'clear FIGH AXESH YTICK;'];
  uimenu('Parent',m(6),'Label','numbered','Callback',timestring)
  uimenu('Parent',m(6),'Label','load file',...
      'Callback','eegplot(''loadelect'');')
  
  % %%%%%%%%%%%%%%%%%
  % Set up autoselect
  % %%%%%%%%%%%%%%%%%

  % push button: create/remove window or select electrode
  command = ['ax1 = findobj(''tag'',''backeeg'',''parent'',gcbf);' ... 
			 'tmppos = get(ax1, ''currentpoint'');' ...
  			 'g = get(gcbf,''UserData'');' ... % get data of backgroung image {g.trialstag g.winrej incallback}
			 'if g.incallback ~= 1' ... % interception of nestest calls
 			 '   if g.trialstag ~= -1,' ...
			 '   	lowlim = round(g.time*g.trialstag+1);' ...
 			 '   else,' ...
			 '   	lowlim = round(g.time*g.srate+1);' ...
  			 '   end;' ...
			 '  if isempty(g.winrej) Allwin=0;' ...
			 '  else Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));' ...
			 '  end;' ...
			 '  if any(Allwin)' ... % remove the mark or select electrode if necessary
			 '    lowlim = find(Allwin==1);' ...
 			 '    if g.setelectrode' ...  % select electrode  
 			 '      ax2 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ...
			 '      tmppos = get(ax2, ''currentpoint'');' ...
    		 '      tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);' ...
    		 '      tmpelec = min(max(tmpelec, 1), g.chans);' ...
			 '      g.winrej(lowlim,tmpelec+5) = ~g.winrej(lowlim,tmpelec+5);' ... % set the electrode
			 '    else' ...  % remove mark
			 '      g.winrej = [ g.winrej(1:lowlim-1,:)'' g.winrej(lowlim+1:end,:)'']''; ' ...
			 '    end;' ...
			 '  else' ...
 			 '    g.incallback = 1;' ...  % set this variable for callback
			 '    g.winrej = [g.winrej'' [tmppos(1)+lowlim tmppos(1)+lowlim g.wincolor zeros(1,g.chans)]'']'';' ...
			 '  end;' ...
  			 '  set(gcbf,''UserData'', g);' ...
			 '  eegplot(''drawb'', 0);' ...  % redraw background
             'end;' ...
             'clear g hhdat hh tmpelec tmppos ax2 ESpacing lowlim Allwin Fs winlength EPosition ax1' ];
			 		
  set(gcf, 'windowbuttondownfcn', command);

  % motion button: move windows or display current position (channel, g.time and activation)
  command = ['ax1 = findobj(''tag'',''backeeg'',''parent'',gcbf);' ... 
			 'tmppos = get(ax1, ''currentpoint'');' ...
 			 'g = get(gcbf,''UserData'');' ...
    		 'if isstruct(g)' ...      %check if we are dealing with the right window
 			 '   if g.trialstag ~= -1,' ...
			 '   	lowlim = round(g.time*g.trialstag+1);' ...
 			 '   else,' ...
			 '   	lowlim = round(g.time*g.srate+1);' ...
  			 '   end;' ...
			 '   if g.incallback' ...
			 '      g.winrej = [g.winrej(1:end-1,:)'' [g.winrej(end,1) tmppos(1)+lowlim g.winrej(end,3:end)]'']'';' ...
 			 '      set(gcbf,''UserData'', g);' ...
 			 '      eegplot(''drawb'');' ...
 			 '   else' ...
 			 '     hh = findobj(''tag'',''Etime'',''parent'',gcbf);' ...
 			 '     if g.trialstag ~= -1,' ...
 			 '        set(hh, ''string'', num2str(mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1)));' ...
 			 '     else,' ...
  			 '     	  set(hh, ''string'', num2str((tmppos(1)+lowlim-1)/g.srate));' ... % put g.time in the box
  			 '     end;' ...
  			 '     ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ... 
			 '     tmppos = get(ax1, ''currentpoint'');' ...
    		 '     tmpelec = round(tmppos(1,2) / g.spacing);' ...
    		 '     tmpelec = min(max(tmpelec, 1),g.chans);' ...
    		 '     labls = get(ax1, ''YtickLabel'');' ...
 			 '     hh = findobj(''tag'',''Eelec'',''parent'',gcbf);' ...  % put electrode in the box
 			 '     set(hh, ''string'', labls(tmpelec+1,:));' ...
 			 '     hh = findobj(''tag'',''Evalue'',''parent'',gcbf);' ...
             '     eegplotdata = get(ax1, ''userdata'');' ...
  			 '     set(hh, ''string'', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,round(tmppos(1)+lowlim))))));' ...  % put value in the box
    		 '  end;' ...
			 'end;' ...
			 'clear g labls eegplotdata tmpelec nbdat ESpacing tmppos ax1 hh lowlim Fs winlength;' ];

  set(gcf, 'windowbuttonmotionfcn', command);

  % release button: check window consistency, adpat to trial boundaries
  command = ['ax1 = findobj(''tag'',''backeeg'',''parent'',gcbf);' ... 
 			 'g = get(gcbf,''UserData'');' ...
 			 'g.incallback = 0;' ...
			 'set(gcbf,''UserData'', g); ' ... % early save in case of bug in the following
			 'if ~isempty(g.winrej)', ...
			 '	if g.winrej(end,1) == g.winrej(end,2)' ... % remove unitary windows
			 '		g.winrej = g.winrej(1:end-1,:);' ...
			 '  else' ...
             '    if g.winrej(end,1) > g.winrej(end,2)' ... % reverse values if necessary
             '       g.winrej(end, 1:2) = [g.winrej(end,2) g.winrej(end,1)];' ...
             '    end;' ...
			 '    if g.trialstag ~= -1' ... % find nearest trials boundaries if necessary
			 '      alltrialtag = [0:g.trialstag:g.frames];' ...
			 '      [tmptmp I1] = min(abs(g.winrej(end,1)-alltrialtag));' ... 
			 '      [tmptmp I2] = min(abs(alltrialtag-g.winrej(end,2)));' ...
			 '      if ~isempty(I1) & ~isempty(I2)' ...
			 '        if I1 ~= I2' ... % accept if more than 1 epoch
			 '    	    for tmptmp=I1:I2-1' ...
			 '      	  g.winrej(end,1) = alltrialtag(tmptmp);' ... % modify boundaries to match trials' ones
			 '      	  g.winrej(end,2) = alltrialtag(tmptmp+1);' ...
			 '      	  if tmptmp ~= I2-1 g.winrej(end+1,:) = g.winrej(end,:); end;' ...
			 '    	    end;' ...
			 '    	  else' ...
			 '		    g.winrej = g.winrej(1:end-1,:);' ... % remove if one epoch only
			 '    	  end;' ...
			 '    	else' ...
			 '		  g.winrej = g.winrej(1:end-1,:);' ... % remove if empty match
			 '      end;' ...
			 '    end;' ...
			 '  end;' ...
			 'end;' ...
             'set(gcbf,''UserData'', g);' ...
             'eegplot(''drawb'');' ...
             'clear alltrialtag g tmptmp ax1 I1 I2 trialtag hhdat hh;'];

  set(gcf, 'windowbuttonupfcn', command);

  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot EEG Data
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
    
   	axes(ax1)
	hold on
	%for nbplot=1:nbdat	
   	%	meandata = mean(data(:,1:round(min(g.frames,g.winlength*g.srate)),nbplot )');  
  	% 	for i = 1:g.chans
    %		plot(data(g.chans-i+1,1:round(min(g.frames,g.winlength*g.srate)),nbplot) ...
    %		-meandata(g.chans-i+1)+i*g.spacing, 'color', DEFAULT_PLOT_COLOR{nbplot})
   	%	end
   	%end;	
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot Spacing I
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  if strcmp(SPACING_EYE,'on')
    
    YLim = get(ax1,'Ylim');
    A = DEFAULT_AXES_POSITION;
    axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],...
	'Visible','off','Ylim',YLim,'tag','eyeaxes')
    axis manual
    Xl = [.3 .6 .45 .45 .3 .6];
    Yl = [g.spacing*2 g.spacing*2 g.spacing*2 g.spacing*1 g.spacing*1 g.spacing*1];
    line(Xl,Yl,'color',DEFAULT_AXIS_COLOR,'clipping','off',...
 	'tag','eyeline')
    text(.5,YLim(2)/23+Yl(1),num2str(g.spacing,4),...
	'HorizontalAlignment','center','FontSize',10,...
	'tag','thescale')
    if strcmp(YAXIS_NEG,'off')
      text(Xl(2)+.1,Yl(1),'+','HorizontalAlignment','left',...
	  'verticalalignment','middle')
      text(Xl(2)+.1,Yl(4),'-','HorizontalAlignment','left',...
	  'verticalalignment','middle')
    else
      text(Xl(2)+.1,Yl(4),'+','HorizontalAlignment','left',...
	  'verticalalignment','middle')
      text(Xl(2)+.1,Yl(1),'-','HorizontalAlignment','left',...
	  'verticalalignment','middle')
    end
    if ~isempty(SPACING_UNITS_STRING)
      text(.5,-YLim(2)/23+Yl(4),SPACING_UNITS_STRING,...
	  'HorizontalAlignment','center','FontSize',10)
    end
    set(m(7),'checked','on')
  
  elseif strcmp(SPACING_EYE,'off')
    YLim = get(ax1,'Ylim');
    A = DEFAULT_AXES_POSITION;
    axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],...
	'Visible','off','Ylim',YLim,'tag','eyeaxes')
    axis manual
    set(m(7),'checked','off')
    
  end 
  
  eegplot('drawp', 0);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Main Function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  try, p1 = varargin{1}; p2 = varargin{2}; p3 = varargin{3}; catch, end;
  switch data
  case 'drawp' % Redraw EEG and change position

    % this test help to couple eegplot windows
    if exist('p3')
    	figh = p3;
    	figure(p3);
    else	
    	figh = gcf;                          % figure handle
	end;
	
    if strcmp(get(figh,'tag'),'dialog')
      figh = get(figh,'UserData');
    end
    ax0 = findobj('tag','backeeg','parent',figh); % axes handle
    ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
    g = get(figh,'UserData');
    data = get(ax1,'UserData');
    ESpacing = findobj('tag','ESpacing','parent',figh);   % ui handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    g.time    = str2num(get(EPosition,'string'));  
    g.spacing = str2num(get(ESpacing,'string'));
        
    if p1 == 1
      g.time = g.time-g.winlength;     % << subtract one window length
    elseif p1 == 2               
      g.time = g.time-1;             % < subtract one second
    elseif p1 == 3
      g.time = g.time+1;             % > add one second
    elseif p1 == 4
      g.time = g.time+g.winlength;     % >> add one window length
    end
    
	if g.trialstag ~= -1 % time in second or in trials
		multiplier = g.trialstag;	
	else
		multiplier = g.srate;
	end;		
    
    % Update edit box
    g.time = max(0,min(g.time,ceil(g.frames/multiplier)-g.winlength));
    set(EPosition,'string',num2str(g.time)); 
    set(figh, 'userdata', g);

    % Plot data and update axes
    switch lower(g.submean) % subtract the mean ?
    	case 'on', meandata = mean(data(:,round(g.time*multiplier+1):round(min((g.time+g.winlength)*multiplier,g.frames)))');  
    	otherwise, meandata = zeros(1,g.chans);
	end;
    axes(ax1)
    cla
    
	% plot data
   	axes(ax1)
	hold on
	lowlim = round(g.time*multiplier+1);
	highlim = round(min((g.time+g.winlength)*multiplier,g.frames));
 	for i = 1:g.chans
      	plot(data(g.chans-i+1,lowlim:highlim) -meandata(g.chans-i+1)+i*g.spacing, ...
      		'color', g.color{mod(i-1,length(g.color))+1}, 'clipping','on')
   	end

	% draw selected electrodes
    if ~isempty(g.winrej)
    	for tpmi = 1:size(g.winrej,1) % scan rows
			if (g.winrej(tpmi,1) >= lowlim & g.winrej(tpmi,1) <= highlim) | ...
				(g.winrej(tpmi,2) >= lowlim & g.winrej(tpmi,2) <= highlim)
				abscmin = max(1,round(g.winrej(tpmi,1)-lowlim));	 
				abscmax = round(g.winrej(tpmi,2)-lowlim);
				maxXlim = get(gca, 'xlim');
				abscmax = min(abscmax, round(maxXlim(2)-1));	 
   				for i = 1:g.chans
   					if g.winrej(tpmi,g.chans-i+1+5)
   						plot(abscmin+1:abscmax+1,data(g.chans-i+1,abscmin+lowlim:abscmax+lowlim) ...
   							-meandata(g.chans-i+1)+i*g.spacing, 'color','r','clipping','on')
					end;
    			end
  			end;	
    	end;
    end;		

    set(ax1,'XTickLabel', num2str((g.time:DEFAULT_GRID_SPACING:g.time+g.winlength)'),...
		'Xlim',[0 g.winlength*multiplier],...
		'XTick',[0:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier])

	eegplot('drawb');
	
	if g.children ~= 0
		if ~exist('p2')
			p2 =[];
		end;	
		eegplot( 'drawp', p1, p2, g.children);
		figure(figh);
	end;	  
  
  case 'drawb' % Draw background ******************************************************
    % Redraw EEG and change position

    ax0 = findobj('tag','backeeg','parent',gcf); % axes handle
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
        
    g = get(gcf,'UserData');  % Data (Note: this could also be global)

    % Plot data and update axes
    axes(ax0);
	cla;
	hold on;
	% plot rejected windows
	if g.trialstag ~= -1
		multiplier = g.trialstag;	
	else
		multiplier = g.srate;
	end;		
   	lowlim = round(g.time*multiplier+1);
   	highlim = round(min((g.time+g.winlength)*multiplier));
  	displaymenu = findobj('tag','displaymenu','parent',gcf);
    if ~isempty(g.winrej) & g.winstatus
    	for tpmi = 1:size(g.winrej,1) % scan rows
			if (g.winrej(tpmi,1) >= lowlim & g.winrej(tpmi,1) <= highlim) | ...
				(g.winrej(tpmi,2) >= lowlim & g.winrej(tpmi,2) <= highlim)	 
	 			h = patch([g.winrej(tpmi,1)-lowlim g.winrej(tpmi,2)-lowlim ...
	 				g.winrej(tpmi,2)-lowlim g.winrej(tpmi,1)-lowlim], ...
	 				[0 0 1 1], ...
	 				[g.winrej(tpmi,3) g.winrej(tpmi,4) g.winrej(tpmi,5)]);  
				set(h, 'EdgeColor', get(h, 'facecolor')) 
   			end;	
    	end;
    end;
    		
	% plot tags
	% ---------
    %if trialtag(1) ~= -1 & displaystatus % put tags at arbitrary places
    % 	for tmptag = trialtag
	%		if tmptag >= lowlim & tmptag <= highlim
	%			plot([tmptag-lowlim tmptag-lowlim], [0 1], 'b--');
   	%		end;	
    %	end;
    %end;		
    if g.trialstag(1) ~= -1
    	alltag = [];
       	for tmptag = lowlim:highlim
    		if mod(tmptag-1, g.trialstag) == 0
				plot([tmptag-lowlim-1 tmptag-lowlim-1], [0 1], 'b--');
				alltag = [ alltag tmptag ];
   			end;	
    	end;
    	tagnum = (alltag-1)/g.trialstag;
     	set(ax0,'XTickLabel', tagnum,'YTickLabel', [],...
		'Xlim',[0 g.winlength*multiplier],...
		'XTick',alltag-lowlim, 'YTick',[], 'tag','backeeg');
		axes(ax1);

		tagpos  = [];
		tagtext = [];
		alltag = [ alltag(1)-g.trialstag alltag alltag(end)+g.trialstag ];
		for i=1:length(alltag)-1;
			tagpos  = [ tagpos linspace(alltag(i), alltag(i+1), 5) ];
			tagpos  = tagpos(1:end-1);
			tagtext = [ tagtext linspace(g.limits(1), g.limits(2), 5) ];
			tagtext  = tagtext(1:end-1);
		end;
     	set(ax1,'XTickLabel', tagtext,'XTick', tagpos-lowlim);
			
    else
     	set(ax0,'XTickLabel', [],'YTickLabel', [],...
		'Xlim',[0 g.winlength*multiplier],...
		'XTick',[], 'YTick',[], 'tag','backeeg');

		axes(ax1);
    	set(ax1,'XTickLabel', num2str((g.time:DEFAULT_GRID_SPACING:g.time+g.winlength)'),...
		'XTick',[0:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier])
    end;
    		
    axes(ax1)	

  case 'draws'
    % Redraw EEG and change scale

    ax1 = findobj('tag','eegaxis','parent',gcf);         % axes handle
    g = get(gcf,'UserData');  
    data = get(ax1, 'userdata');
    ESpacing = findobj('tag','ESpacing','parent',gcf);   % ui handle
    EPosition = findobj('tag','EPosition','parent',gcf); % ui handle
    g.time    = str2num(get(EPosition,'string'));  
    g.spacing = str2num(get(ESpacing,'string'));  
    
    orgspacing= g.spacing;
    if p1 == 1
      	g.spacing= g.spacing+ 0.1*orgspacing; % increase g.spacing(5%)
    	elseif p1 == 2
      		g.spacing= max(0,g.spacing-0.1*orgspacing); % decrease g.spacing(5%)
    end
    if round(g.spacing) == 0
        maxindex = min(10000, g.frames);  
        g.spacing = 0.01*max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
    end;

    set(ESpacing,'string',num2str(g.spacing,4))  % update edit box
    set(gcf, 'userdata', g);
	eegplot('drawp', 0);
    set(ax1,'YLim',[0 (g.chans+1)*g.spacing],...
	'YTick',[0:g.spacing:g.chans*g.spacing])
    
    % update scaling eye if it exists
    eyeaxes = findobj('tag','eyeaxes','parent',gcf);
    if ~isempty(eyeaxes)
      eyetext = findobj('type','text','parent',eyeaxes,'tag','thescale');
      set(eyetext,'string',num2str(g.spacing,4))
    end
	return;

  case 'window'
    % get new window length with dialog box
    g = get(gcf,'UserData');
	result       = inputdlg( { fastif(g.trialstag==-1,'Enter new window length(secs):', 'Enter number of epoch(s):') }, 'Change window length', 1,  { num2str(g.winlength) });
	if size(result,1) == 0 return; end;

	g.winlength = eval(result{1}); 
	set(gcf, 'UserData', g);
	eegplot('drawp',0);	
	return;
    
  case 'loadelect'
	[inputname,inputpath] = uigetfile('*','Electrode File');
	if inputname == 0 return; end;
	if ~exist([ inputpath inputname ])
		error('no such file');
	end;

	AXH0 = findobj('tag','eegaxis','parent',gcf);
	eegplot('setelect',[ inputpath inputname ],AXH0);
	return;
  
  case 'setelect'
    % Set electrodes    
    eloc_file = p1;
    axeshand = p2;
    outvar1 = 1;
    if isempty(eloc_file)
      outvar1 = 0;
      return
    end
    
	[tmp YLabels] = readlocs(eloc_file);
	YLabels = strvcat(YLabels);
    
    YLabels = flipud(str2mat(YLabels,' '));
    set(axeshand,'YTickLabel',YLabels)
  
  case 'title'
    % Get new title
     eegaxis = findobj('tag','eegaxis','parent', gcf);
    oldtitleh = get(eegaxis,'title');
    oldtitle = get(oldtitleh,'string');

	result       = inputdlg( { 'Enter new title:' }, 'Change title', 1,  { oldtitle });
	size_result  = size( result );
	if size_result(1) == 0 return; end;

	set(oldtitleh, 'string', result{1});	
	return;

  case 'scaleeye'
    % Turn scale I on/off
    obj = p1;
    figh = p2;
    % figh = get(obj,'Parent');
    toggle = get(obj,'checked');
    
    if strcmp(toggle,'on')
      eyeaxes = findobj('tag','eyeaxes','parent',figh);
      children = get(eyeaxes,'children');
      delete(children)
      set(obj,'checked','off')
    elseif strcmp(toggle,'off')
      eyeaxes = findobj('tag','eyeaxes','parent',figh);
      
      ESpacing = findobj('tag','ESpacing','parent',figh);
      g.spacing= str2num(get(ESpacing,'string'));
      
      axes(eyeaxes)
      YLim = get(eyeaxes,'Ylim');
      Xl = [.35 .65 .5 .5 .35 .65];
      Yl = [g.spacing*2 g.spacing*2 g.spacing*2 g.spacing*1 g.spacing*1 g.spacing*1];
      line(Xl,Yl,'color',DEFAULT_AXIS_COLOR,'clipping','off',...
 	'tag','eyeline')
      text(.5,YLim(2)/23+Yl(1),num2str(g.spacing,4),...
	'HorizontalAlignment','center','FontSize',10,...
	'tag','thescale')
      if strcmp(YAXIS_NEG,'off')
        text(Xl(2)+.1,Yl(1),'+','HorizontalAlignment','left',...
	    'verticalalignment','middle', 'tag', 'thescale')
        text(Xl(2)+.1,Yl(4),'-','HorizontalAlignment','left',...
	    'verticalalignment','middle', 'tag', 'thescale')
      else
        text(Xl(2)+.1,Yl(4),'+','HorizontalAlignment','left',...
	    'verticalalignment','middle', 'tag', 'thescale')
        text(Xl(2)+.1,Yl(1),'-','HorizontalAlignment','left',...
	    'verticalalignment','middle', 'tag', 'thescale')
      end
      if ~isempty(SPACING_UNITS_STRING)
        text(.5,-YLim(2)/23+Yl(4),SPACING_UNITS_STRING,...
	    'HorizontalAlignment','center','FontSize',10, 'tag', 'thescale')
      end
      set(obj,'checked','on')
    end
    
  case 'noui'
      eegplot( varargin{:} );

      % suppres menu bar
      set(gcf, 'menubar', 'figure');

      % find button and text
      obj = findobj(gcf, 'style', 'pushbutton'); delete(obj);
      obj = findobj(gcf, 'style', 'edit'); delete(obj);
      obj = findobj(gcf, 'style', 'text'); 
      objscale = findobj(obj, 'tag', 'thescale');
      delete(setdiff(obj, objscale));
 
  otherwise
      error(['Error - invalid eegplot() parameter: ',data])
  end  
end

