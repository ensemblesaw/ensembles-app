/*
  Copyright (C) 2013  Roman Soumin
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  - Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/

[CCode (cprefix = "Pm", lower_case_cprefix = "", cheader_filename = "portmidi.h")]
namespace PortMidi {

	public struct DeviceID: int {}
	public struct Timestamp: long {}

	[CCode (cname = "pmNoDevice")]
	public const DeviceID NO_DEVICE;

	[Compact]
	public class DeviceInfo {
		[CCode (cname = "Pm_GetDeviceInfo")]
		public static unowned DeviceInfo from_id(DeviceID id);
		[CCode (cname = "structVersion")]
		public int struct_version;
		public string interf;
		public string name;
		public bool input;
		public bool output;
		public bool opened;
	}

	public enum Error {
		[CCode (cname = "FALSE")] FALSE,
		[CCode (cname = "TRUE")] TRUE,
		[CCode (cname = "pmNoError")] NO_ERROR,
		[CCode (cname = "pmNoData")] NO_DATA,
		[CCode (cname = "pmGotData")] GOT_DATA,
		[CCode (cname = "pmHostError")] HOST_ERROR,
		[CCode (cname = "pmInvalidDeviceId")] INVALID_DEVICE_ID,
		[CCode (cname = "pmInsufficientMemory")] INSUFFICIENT_MEMORY,
		[CCode (cname = "pmBufferTooSmall")] BUFFER_TOO_SMALL,
		[CCode (cname = "pmBufferOverflow")] BUFFER_OVERFLOW,
		[CCode (cname = "pmBadPtr")] BAD_PTR,
		[CCode (cname = "pmBadData")] BAD_DATA,
		[CCode (cname = "pmInternalError")] INTERNAL_ERROR,
		[CCode (cname = "pmBufferMaxSize")] BUFFER_MAX_SIZE
	}

	public struct Message: long {
		[CCode (cname = "Pm_Message")]
		public Message(int status, int data1, int data2);
		[CCode (cname = "Pm_MessageStatus")]
		public int status();
		[CCode (cname = "Pm_MessageData1")]
		public int data1();
		[CCode (cname = "Pm_MessageData2")]
		public int data2();
	}

	public struct Event {
		Message   message;
		Timestamp timestamp;
	}

	[Compact]
	[CCode (free_function = "Pm_Close")]
	class Stream {
		public struct Filters: ulong {}

		[CCode (cname = "PM_FILT_ACTIVE")]
		public const Filters FILT_ACTIVE;
	 	[CCode (cname = "PM_FILT_SYSEX")]
	 	public const Filters FILT_SYSEX;
	 	[CCode (cname = "PM_FILT_CLOCK")]
	 	public const Filters FILT_CLOCK;
	 	[CCode (cname = "PM_FILT_PLAY")]
	 	public const Filters FILT_PLAY;
	 	[CCode (cname = "PM_FILT_TICK")]
	 	public const Filters FILT_TICK;
	 	[CCode (cname = "PM_FILT_FD")]
	 	public const Filters FILT_FD;
	 	[CCode (cname = "PM_FILT_UNDEFINED")]
	 	public const Filters FILT_UNDEFINED;
	 	[CCode (cname = "PM_FILT_RESET")]
	 	public const Filters FILT_RESET;
	 	[CCode (cname = "PM_FILT_REALTIME")]
	 	public const Filters FILT_REALTIME;
	 	[CCode (cname = "PM_FILT_NOTE")]
	 	public const Filters FILT_NOTE;
	 	[CCode (cname = "PM_FILT_CHANNEL_AFTERTOUCH")]
	 	public const Filters FILT_CHANNEL_AFTERTOUCH;
	 	[CCode (cname = "PM_FILT_POLY_AFTERTOUCH")]
	 	public const Filters FILT_POLY_AFTERTOUCH;
	 	[CCode (cname = "PM_FILT_AFTERTOUCH")]
	 	public const Filters FILT_AFTERTOUCH;
	 	[CCode (cname = "PM_FILT_PROGRAM")]
	 	public const Filters PM_FILT_PROGRAM;
	 	[CCode (cname = "PM_FILT_CONTROL")]
	 	public const Filters FILT_CONTROL;
	 	[CCode (cname = "PM_FILT_PITCHBEND")]
	 	public const Filters FILT_PITCHBEND;
	 	[CCode (cname = "PM_FILT_MTC")]
	 	public const Filters FILT_MTC;
	 	[CCode (cname = "PM_FILT_SONG_POSITION")]
	 	public const Filters FILT_SONG_POSITION;
	 	[CCode (cname = "PM_FILT_SONG_SELECT")]
	 	public const Filters FILT_SONG_SELECT;
	 	[CCode (cname = "PM_FILT_TUNE")]
	 	public const Filters FILT_TUNE;
	 	[CCode (cname = "PM_FILT_SYSTEMCOMMON")]
	 	public const Filters FILT_SYSTEMCOMMON;

		public delegate Timestamp TimeProc();

		[CCode (cname = "Pm_OpenInput")]
		public static Error open_input(out Stream stream,
					DeviceID inputDevice,
					void* inputDriverInfo,
					long bufferSize,
					TimeProc? time_proc);

		[CCode (cname = "Pm_OpenOutput")]
		public static Error open_output(out Stream stream,
					DeviceID outputDevice,
					void* outputDriverInfo,
					long bufferSize,
					TimeProc? time_proc,
					long latency);

		[CCode (cname = "Pm_HasHostError")]
		bool has_host_error();

		[CCode (cname = "Pm_SetFilter")]
		public Error set_filter(Filters filters);

		[CCode (cname = "Pm_SetChannelMask")]
		public Error set_channel_mask(int mask);

		[CCode (cname = "Pm_Abort")]
		public Error abort();

		[CCode (cname = "Pm_Read")]
		public int read(Event[] buffer);

		[CCode (cname = "Pm_Poll")]
		public Error poll();

		[CCode (cname = "Pm_Write")]
		public Error write(Event[] buffer);

		[CCode (cname = "Pm_WriteShort")]
		public Error write_short(Timestamp when, long msg);

		[CCode (cname = "Pm_WriteSysEx")]
		public Error write_sys_ex(Timestamp when, string msg);
	}


	[CCode (cname = "Pm_Initialize")]
	public Error initialize();
	[CCode (cname = "Pm_Terminate")]
	public Error terminate();
	[CCode (cname = "Pm_GetErrorText")]
	public string get_error_text(Error errorNum);
	[CCode (cname = "Pm_CountDevices")]
	public int count_devices();
	[CCode (cname = "Pm_GetDefaultInputDeviceID")]
	public DeviceID get_default_input_device_id();
	[CCode (cname = "Pm_GetDefaultOutputDeviceID")]
	public DeviceID get_default_output_device_id();
	[CCode (cname = "Pm_Channel")]
	public int channel_mask(uint channel);
}
