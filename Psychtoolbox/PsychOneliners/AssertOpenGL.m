function AssertOpenGL
% AssertOpenGL
%
% Break and issue an error message if the installed Psychtoolbox is not
% based on OpenGL or Screen() is not working properly.
% To date there are four versions of the Psychtoolbox, each based on a
% different graphics library:
%
%  OS9: Psychtoolbox-2, based on Apple's QuickDraw.
%  Win: Psychtoolbox-2, based on Direct X and GDI.
%  Win: OpenGL for the ported OSX-Psychtoolbox, aka Psychtoolbox-3.
%  OSX: OpenGL for Psychtoolbox-3.
%  Linux: OpenGL for Psychtoolbox-3.
%
%  The Psychtoolboxes based on OpenGL are partially incompatible (see below)
%  with previous Psychtoolboxes.  A script which relies on the OpenGL
%  Psychtoolbox should call AssertOpenGL so that it will issue the
%  appropriate warning if a user tries to run it on a computer with a
%  non-OpenGL based Psychtoolbox installed.
%
%  OpenGL-based Psychtoolboxes are distinguised by the availability of these
%  functions:
%
%   Screen('Flip',...);
%   Screen('MakeTexture');
%   Screen('DrawTexture');
%
%
%  If you know you're using Psychtoolbox-3, then the most likely cause for
%  this error message is a problem in the configuration of your
%  Matlab/Octave + System setup, or in the Psychtoolbox installation.
%
%  Typically either the Screen MEX file can't be found or accessed, due to
%  some wrong Matlab/Octave path (Proper Screen file not in path), or due
%  to some permission issue (insufficient security access permissions -
%  typically found on MS-Windows systems), or the Screen MEX file can't be
%  loaded and initialized due to some missing or wrong system library on
%  your machine, e.g., the C runtime library is of an incompatible type.
%  Simply type the command "Screen" at the prompt to see if this may be an
%  issue.
%
%  In both cases, indicated by some "file not found" or "file could not by
%  accesses" or "invalid MEX file" error message, you may want to run the
%  SetupPsychtoolbox command again. This will either fix the problem for
%  you by reconfiguring Psychtoolbox, or it will provide more diagnostic
%  error and troubleshooting messages. Make also sure that you read the
%  troubleshooting tips in the "Download" and "Frequently asked questions"
%  sections of our Psychtoolbox Wiki at http://www.psychtoolbox.org
%
% See also: IsOSX, IsWin, IsLinux.

% HISTORY
% 7/10/04   awi     wrote it.
% 7/13/04   awi     Fixed documentation.
% 10/6/05   awi	    Note here cosmetic changes by dgp between 7/13/04 and 10/6/05
% 12/31/05  mk      Detection code modified to really query type of Screen command (OpenGL?)
%                   instead of OS type, as PTB-OpenGL is now available for Windows as well.
% 06/05/08  mk      Hopefully more diagnostic output message added.
% 05/25/11  mk      Update linker failure message on Octave+Windows: Don't
%                   need ARVideo libraries anymore, but instead the
%                   GStreamer runtime.
% 03/24/12  mk      Add do_braindead_shortcircuit_evaluation() to avoid
%                   warnings on Octave 3.6 and later.
% 09/05/12  mk      Disable shortcircuit operator warning.
% 05/13/13  mk      Reenable short-circuit-operator warnings for Octave, as
%                   they shouldn't be needed anymore with our fixed M-Files.
% 08/07/19  mk      Update for 3.0.16 release: GStreamer 1.4+ on Linux, on Windows
%                   GStreamer 1.16+ MSVC build is mandatory on Octave *and* Matlab.
% 10/20/20  mk      Update for 3.0.17 release: GStreamer 1.8+ on Linux, on Windows
%                   GStreamer 1.18+ MSVC build is mandatory on Octave *and* Matlab.

% We put the detection code into a try-catch-end statement: The old Screen command on windows
% doesn't have a 'Version' subfunction, so it would exit to Matlab with an error.
% We catch this error in the catch-branch and output the "non-OpenGL" error message...
try
   % Query a Screen subfunction that only exists in the new Screen command If this is not
   % OpenGL PTB,we will get thrown into the catch-branch...
   value=Screen('Preference', 'SkipSyncTests'); %#ok<NASGU>
   return;
catch %#ok<*CTCH>
   fprintf('\n\n\nA very simple test call to the Screen() MEX file failed in AssertOpenGL, indicating\n');
   fprintf('that either Screen is totally dysfunctional, or you are trying to run your script on\n');
   fprintf('a system without Psychtoolbox-3 properly installed - or not installed at all.\n\n');

    %   if IsWin
    %      le = psychlasterror;
    %      if ~isempty(strfind(le.message, 'library or dependents')) && ~isempty(strfind(le.message, 'Screen.mex'))
    %         % Likely the required GStreamer 1.16+ MSVC runtimes aren't installed yet!
    %         fprintf('The most likely cause, based on the fact you are running on Octave under Windows\n');
    %         fprintf('and given this error message: %s\n', le.message);
    %         fprintf('is that the required GStreamer runtime libraries are not yet installed on your system.\n\n');
    %         fprintf('Please type ''help GStreamer'' and read the installation instructions carefully.\n');
    %         fprintf('After this one-time setup, the Screen command should work properly.\n\n');
    %         fprintf('If this has been ruled out as a reason for failure, the following could be the case:\n\n');
    %      end
    %   end

   if IsWin
      fprintf('On Windows you *must* install the MSVC build runtime of at least GStreamer 1.18.0\n');
      fprintf('or a later version. Screen() will not work with earlier versions, without GStreamer,\n');
      fprintf('or with the MinGW variants of the GStreamer runtime!\n');
      fprintf('Read ''help GStreamer'' for more info.\n\n');
   end

   if IsLinux
        fprintf('\n');
        fprintf('The Psychtoolbox on GNU/Linux needs the following 3rd party libraries\n');
        fprintf('in order to function correctly. If you get "Invalid MEX file errors",\n');
        fprintf('or similar fatal error messages, check if these are installed on your\n');
        fprintf('system and if they are missing, install them via your system specific\n');
        fprintf('software management tools:\n');
        fprintf('\n');
        fprintf('For Screen() and OpenGL support:\n\n');
        fprintf('* The OpenGL utility toolkit GLUT: glut, glut-3 or freeglut are typical provider packages in most Linux distributions.\n');
        fprintf('* GStreamer multimedia framework: At least version 1.8.0 of the core runtime and the gstreamer-base plugins.\n');
        fprintf('  For optimal performance and the full set of features use the latest available versions, atm. version 1.18 for HDR\n');
        fprintf('  support would be needed. You may need to install additional packages to play back all\n');
        fprintf('  common audio- and video file formats. See "help GStreamer".\n');
        fprintf('* libusb-1.0 USB low-level access library.\n');
        fprintf('* libdc1394 Firewire video capture library.\n');
        fprintf('* libraw1394 Firewire low-level access library.\n');
        fprintf('\n\n');
        fprintf('For PsychKinect() (See "help InstallKinect"):\n\n');
        fprintf('* libusb-1.0 USB low-level access library.\n');
        fprintf('* libfreenect-0.5: Kinect driver library version 0.5 or later.\n');
        fprintf('\n');
        fprintf('For PsychHID() support:\n\n');
        fprintf('* libusb-1.0 USB low-level access library.\n');
        fprintf('\n\n');
        fprintf('For PsychPortAudio() support:\n\n');
        fprintf('* libportaudio.so.2 Portaudio sound library.\n');
        fprintf('\n\n');
        fprintf('For Eyelink():\n\n');
        fprintf('* The Eyelink core libraries from the SR-Research download website.\n');
        fprintf('\n');
        fprintf('\n');
        fprintf('If you receive an installation failure soon, then please read the output of\n');
        fprintf('"help GStreamer" first and follow the installation instructions for GStreamer\n');
        fprintf('on Linux. Psychtoolbox''s Screen() command will not work without GStreamer!\n\n');

       if ~IsOctave
           s = psychlasterror;
           if ~isempty(strfind(s.message, 'gzopen64'))
               fprintf('YOU SEEM TO HAVE A MATLAB INSTALLATION WITH A BROKEN/OUTDATED libz library!\n');
               fprintf('This is the most likely cause for the error. You can either:\n');
               fprintf('- Upgrade to a more recent version of Matlab in the hope that this fixes the problem.\n');
               fprintf('- Or start Matlab from the commandline with the following command sequence as a workaround:\n\n');
               fprintf('  export LD_PRELOAD=/lib/libz.so.1 ; matlab & \n\n');
               fprintf('  If /lib/libz.so.1 doesn''t exist, try other locations like /usr/lib/libz.so.1 or other names\n');
               fprintf('  like /lib/libz.so, or /usr/lib/libz.so\n');
               fprintf('- A third option is to delete the libz.so library shipped with Matlab. Move away all\n');
               fprintf('  files starting with libz.so from the folder /bin/glnx86 inside the Matlab main folder.\n');
               fprintf('  This way, the linker can''t find Matlabs broken libz anymore and will use the system\n');
               fprintf('  libz and everything will be fine.\n');
               fprintf('\n');
               error('Matlab bug -- Outdated/Defective libz installed. Follow above workarounds.');
           end
       end
   end

   % Tried to execute old Screen command of old Win-PTB or MacOS9-PTB. This will tell user about non-OpenGL PTB.
   fprintf('This script or function is designated to run only on a Psychtoolbox based on OpenGL. Read "help  AssertOpenGL" for more info.\n\n');
   fprintf('A first more diagnostic test would be to simply type ''Screen'' in your Matlab/Octave console and check what its output is.\n\n');
   fprintf('\n\nThe returned error message by Matlab/Octave was:\n');
   ple;
   error('Problems detected in call to AssertOpenGL;');
end;
