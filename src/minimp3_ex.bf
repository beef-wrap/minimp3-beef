/*
	https://github.com/lieff/minimp3
	To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide.
	This software is distributed without any warranty.
	See <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

using System;
using System.Interop;

namespace minimp3;

extension minimp3
{
	/* flags for mp3dec_ex_open_* functions */
	const c_int MP3D_SEEK_TO_BYTE    = 0; /* mp3dec_ex_seek seeks to byte in stream */
	const c_int MP3D_SEEK_TO_SAMPLE  = 1; /* mp3dec_ex_seek precisely seeks to sample using index (created during duration calculation scan or when mp3dec_ex_seek called) */
	const c_int MP3D_DO_NOT_SCAN     = 2; /* do not scan whole stream for duration if vbrtag not found, mp3dec_ex_t::samples will be filled only if mp3dec_ex_t::vbr_tag_found == 1 */
#if MINIMP3_ALLOW_MONO_STEREO_TRANSITION
	const c_int MP3D_ALLOW_MONO_STEREO_TRANSITION =  4;
	const c_int MP3D_FLAGS_MASK = 7;
#else
	const c_int MP3D_FLAGS_MASK = 3;
#endif

	/* compile-time config */
	const c_int MINIMP3_PREDECODE_FRAMES = 2; /* frames to pre-decode and skip after seek (to fill internal structures) */
	/*const c_int MINIMP3_SEEK_IDX_LINEAR_SEARCH =*/ /* define to use linear index search instead of binary search on seek */
	const c_int MINIMP3_IO_SIZE = (128 * 1024); /* io buffer size for streaming functions, must be greater than MINIMP3_BUF_SIZE */
	const c_int MINIMP3_BUF_SIZE = (16 * 1024); /* buffer which can hold minimum 10 consecutive mp3 frames (~16KB) worst case */
	/*const c_int MINIMP3_SCAN_LIMIT = (256*1024)*/ /* how many bytes will be scanned to search first valid mp3 frame, to prevent stall on large non-mp3 files */
	const c_int MINIMP3_ENABLE_RING = 0; /* WIP enable hardware magic ring buffer if available, to make less input buffer memmove(s) in callback IO mode */

	/* return error codes */
	const c_int MP3D_E_PARAM =   -1;
	const c_int MP3D_E_MEMORY =  -2;
	const c_int MP3D_E_IOERROR = -3;
	const c_int MP3D_E_USER =    -4; /* can be used to stop processing from callbacks without indicating specific error */
	const c_int MP3D_E_DECODE =  -5; /* decode error which can't be safely skipped, such as sample rate, layer and channels change */

	[CRepr]
	public struct mp3dec_file_info_t
	{
		public mp3d_sample_t* buffer;
		public size_t samples; /* channels included, byte size = samples*sizeof(mp3d_sample_t) */
		public c_int channels, hz, layer, avg_bitrate_kbps;
	}

	[CRepr]
	public struct mp3dec_map_info_t
	{
		public uint8_t* buffer;
		public size_t size;
	}

	[CRepr]
	public struct mp3dec_frame_t
	{
		public uint64_t sample;
		public uint64_t offset;
	}

	[CRepr]
	public struct mp3dec_index_t
	{
		public mp3dec_frame_t* frames;
		public size_t num_frames, capacity;
	}

	public function size_t MP3D_READ_CB(void* buf, size_t size, void* user_data);
	public function c_int MP3D_SEEK_CB(uint64_t position, void* user_data);

	[CRepr]
	public struct mp3dec_io_t
	{
		public MP3D_READ_CB read;
		public void* read_data;
		public MP3D_SEEK_CB seek;
		public void* seek_data;
	}

	[CRepr]
	public struct mp3dec_ex_t
	{
		public mp3dec_t mp3d;
		public mp3dec_map_info_t file;
		public mp3dec_io_t* io;
		public mp3dec_index_t index;
		public uint64_t offset, samples, detected_samples, cur_sample, start_offset, end_offset;
		public mp3dec_frame_info_t info;
		public mp3d_sample_t[MINIMP3_MAX_SAMPLES_PER_FRAME] buffer;
		public size_t input_consumed, input_filled;
		public c_int is_file, flags, vbr_tag_found, indexes_built;
		public c_int free_format_bytes;
		public c_int buffer_samples, buffer_consumed, to_skip, start_delay;
		public c_int last_error;
	}

	public function c_int MP3D_ITERATE_CB(void* user_data, uint8_t* frame, c_int frame_size, c_int free_format_bytes, size_t buf_size, uint64_t offset, mp3dec_frame_info_t* info);
	public function c_int MP3D_PROGRESS_CB(void* user_data, size_t file_size, uint64_t offset, mp3dec_frame_info_t* info);

	/* detect mp3/mpa format */
	[CLink] public static extern c_int mp3dec_detect_buf(uint8_t* buf, size_t buf_size);
	[CLink] public static extern c_int mp3dec_detect_cb(mp3dec_io_t* io, uint8_t* buf, size_t buf_size);
	/* decode whole buffer block */
	[CLink] public static extern c_int mp3dec_load_buf(mp3dec_t* dec, uint8_t* buf, size_t buf_size, mp3dec_file_info_t* info, MP3D_PROGRESS_CB progress_cb, void* user_data);
	[CLink] public static extern c_int mp3dec_load_cb(mp3dec_t* dec, mp3dec_io_t* io, uint8_t* buf, size_t buf_size, mp3dec_file_info_t* info, MP3D_PROGRESS_CB progress_cb, void* user_data);
	/* iterate through frames */
	[CLink] public static extern c_int mp3dec_iterate_buf(uint8_t* buf, size_t buf_size, MP3D_ITERATE_CB callback, void* user_data);
	[CLink] public static extern c_int mp3dec_iterate_cb(mp3dec_io_t* io, uint8_t* buf, size_t buf_size, MP3D_ITERATE_CB callback, void* user_data);
	/* streaming decoder with seeking capability */
	[CLink] public static extern c_int mp3dec_ex_open_buf(mp3dec_ex_t* dec, uint8_t* buf, size_t buf_size, c_int flags);
	[CLink] public static extern c_int mp3dec_ex_open_cb(mp3dec_ex_t* dec, mp3dec_io_t* io, c_int flags);
	[CLink] public static extern void mp3dec_ex_close(mp3dec_ex_t* dec);
	[CLink] public static extern c_int mp3dec_ex_seek(mp3dec_ex_t* dec, uint64_t position);
	[CLink] public static extern size_t mp3dec_ex_read_frame(mp3dec_ex_t* dec, mp3d_sample_t** buf, mp3dec_frame_info_t* frame_info, size_t max_samples);
	[CLink] public static extern size_t mp3dec_ex_read(mp3dec_ex_t* dec, mp3d_sample_t* buf, size_t samples);
#if !MINIMP3_NO_STDIO
	/* stdio versions of file detect, load, iterate and stream */
	[CLink] public static extern c_int mp3dec_detect(char* file_name);
	[CLink] public static extern c_int mp3dec_load(mp3dec_t* dec, char* file_name, mp3dec_file_info_t* info, MP3D_PROGRESS_CB progress_cb, void* user_data);
	[CLink] public static extern c_int mp3dec_iterate(char* file_name, MP3D_ITERATE_CB callback, void* user_data);
	[CLink] public static extern c_int mp3dec_ex_open(mp3dec_ex_t* dec, char* file_name, c_int flags);

#if BF_PLATFORM_WINDOWS
	typealias wchar_t = c_wchar;

	[CLink] public static extern c_int mp3dec_detect_w(wchar_t* file_name);
	[CLink] public static extern c_int mp3dec_load_w(mp3dec_t* dec, wchar_t* file_name, mp3dec_file_info_t* info, MP3D_PROGRESS_CB progress_cb, void* user_data);
	[CLink] public static extern c_int mp3dec_iterate_w(wchar_t* file_name, MP3D_ITERATE_CB callback, void* user_data);
	[CLink] public static extern c_int mp3dec_ex_open_w(mp3dec_ex_t* dec, wchar_t* file_name, c_int flags);
#endif

#endif
}