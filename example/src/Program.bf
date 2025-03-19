using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Interop;
using System.Text;

using static minimp3.minimp3;

namespace example;

static class Program
{
	static int32 cb(void* user_data, uint file_size, uint64 offset, mp3dec_frame_info_t* info)
	{
		return 0;
	}

	static int Main(params String[] args)
	{
		mp3dec_t dec;
		mp3dec_file_info_t file_info;
		mp3dec_load(&dec, "sound.mp3", &file_info, => cb, null);
		return 0;
	}
}