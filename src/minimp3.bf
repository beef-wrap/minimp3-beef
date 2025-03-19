using System;
using System.Interop;

namespace minimp3;

public static class minimp3
{
	typealias size_t = uint;
	typealias char = c_char;
	typealias uint8_t = uint8;
	typealias uint16_t = uint16;
	typealias uint32_t = uint32;
	typealias uint64_t = uint64;
	typealias int16_t = int16;

	const c_int MINIMP3_MAX_SAMPLES_PER_FRAME = (1152 * 2);

	[CRepr]
	public struct mp3dec_frame_info_t
	{
		c_int frame_bytes, frame_offset, channels, hz, layer, bitrate_kbps;
	}

	[CRepr]
	public struct mp3dec_t
	{
		float[2][9 * 32] mdct_overlap;
		float[15 * 2 * 32] qmf_state;
		c_int reserv, free_format_bytes;
		c_uchar[4] header;
		c_uchar[511] reserv_buf;
	}

	[CLink] public static extern void mp3dec_init(mp3dec_t* dec);

#if !MINIMP3_FLOAT_OUTPUT
	typealias mp3d_sample_t = int16_t;
#else
	typealias mp3d_sample_t = float;
	[CLink] public static extern void mp3dec_f32_to_s16(float *in, int16_t *out, c_int num_samples);
#endif
	[CLink] public static extern c_int mp3dec_decode_frame(mp3dec_t* dec, uint8_t* mp3, c_int mp3_bytes, mp3d_sample_t* pcm, mp3dec_frame_info_t* info);
}