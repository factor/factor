! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
USING:
    alien
    alien.c-types
    alien.libraries
    alien.syntax
    classes.struct
    combinators
    kernel
    ogg
    system
;
IN: ogg.vorbis

<<
"vorbis" {
    { [ os windows? ]  [ "vorbis.dll" ] }
    { [ os macosx? ] [ "libvorbis.0.dylib" ] }
    { [ os unix? ]   [ "libvorbis.so" ] }
} cond cdecl add-library

"vorbis" deploy-library
>>

LIBRARY: vorbis

STRUCT: vorbis-info
    { version int  }
    { channels int }
    { rate long }
    { bitrate_upper long }
    { bitrate_nominal long }
    { bitrate_lower long }
    { bitrate_window long }
    { codec_setup void* }
    ;

STRUCT: vorbis-dsp-state
    { analysisp int }
    { vi vorbis-info* }
    { pcm float** }
    { pcmret float** }
    { pcm_storage int }
    { pcm_current int }
    { pcm_returned int }
    { preextrapolate int }
    { eofflag int }
    { lW long }
    { W long }
    { nW long }
    { centerW long }
    { granulepos longlong }
    { sequence longlong }
    { glue_bits longlong }
    { time_bits longlong }
    { floor_bits longlong }
    { res_bits longlong }
    { backend_state void* }
    ;

STRUCT: alloc-chain
    { ptr void* }
    { next void* }
    ;

STRUCT: vorbis-block
    { pcm float** }
    { opb oggpack-buffer }
    { lW long }
    { W long }
    { nW long }
    { pcmend int }
    { mode int }
    { eofflag int }
    { granulepos longlong }
    { sequence longlong }
    { vd vorbis-dsp-state* }
    { localstore void* }
    { localtop long }
    { localalloc long }
    { totaluse long }
    { reap alloc-chain* }
    { glue_bits long }
    { time_bits long }
    { floor_bits long }
    { res_bits long }
    { internal void* }
    ;

STRUCT: vorbis-comment
    { usercomments c-string* }
    { comment_lengths int* }
    { comments int }
    { vendor c-string }
    ;

FUNCTION: void     vorbis_info_init ( vorbis-info* vi )
FUNCTION: void     vorbis_info_clear ( vorbis-info* vi )
FUNCTION: int      vorbis_info_blocksize ( vorbis-info* vi, int zo )
FUNCTION: void     vorbis_comment_init ( vorbis-comment* vc )
FUNCTION: void     vorbis_comment_add ( vorbis-comment* vc, c-string comment )
FUNCTION: void     vorbis_comment_add_tag ( vorbis-comment* vc, c-string tag, c-string contents )
FUNCTION: c-string    vorbis_comment_query ( vorbis-comment* vc, c-string tag, int count )
FUNCTION: int      vorbis_comment_query_count ( vorbis-comment* vc, c-string tag )
FUNCTION: void     vorbis_comment_clear ( vorbis-comment* vc )
FUNCTION: int      vorbis_block_init ( vorbis-dsp-state* v, vorbis-block* vb )
FUNCTION: int      vorbis_block_clear ( vorbis-block* vb )
FUNCTION: void     vorbis_dsp_clear ( vorbis-dsp-state* v )
FUNCTION: double   vorbis_granule_time ( vorbis-dsp-state* v, longlong granulepos )
FUNCTION: int      vorbis_analysis_init ( vorbis-dsp-state* v, vorbis-info* vi )
FUNCTION: int      vorbis_commentheader_out ( vorbis-comment* vc, ogg-packet* op )
FUNCTION: int      vorbis_analysis_headerout ( vorbis-dsp-state* v,
                                          vorbis-comment* vc,
                                          ogg-packet* op,
                                          ogg-packet* op_comm,
                                          ogg-packet* op_code )
FUNCTION: float**  vorbis_analysis_buffer ( vorbis-dsp-state* v, int vals )
FUNCTION: int      vorbis_analysis_wrote ( vorbis-dsp-state* v, int vals )
FUNCTION: int      vorbis_analysis_blockout ( vorbis-dsp-state* v, vorbis-block* vb )
FUNCTION: int      vorbis_analysis ( vorbis-block* vb, ogg-packet* op )
FUNCTION: int      vorbis_bitrate_addblock ( vorbis-block* vb )
FUNCTION: int      vorbis_bitrate_flushpacket ( vorbis-dsp-state* vd,
                                           ogg-packet* op )
FUNCTION: int      vorbis_synthesis_headerin ( vorbis-info* vi, vorbis-comment* vc,
                                          ogg-packet* op )
FUNCTION: int      vorbis_synthesis_init ( vorbis-dsp-state* v, vorbis-info* vi )
FUNCTION: int      vorbis_synthesis_restart ( vorbis-dsp-state* v )
FUNCTION: int      vorbis_synthesis ( vorbis-block* vb, ogg-packet* op )
FUNCTION: int      vorbis_synthesis_trackonly ( vorbis-block* vb, ogg-packet* op )
FUNCTION: int      vorbis_synthesis_blockin ( vorbis-dsp-state* v, vorbis-block* vb )
FUNCTION: int      vorbis_synthesis_pcmout ( vorbis-dsp-state* v, float*** pcm )
FUNCTION: int      vorbis_synthesis_lapout ( vorbis-dsp-state* v, float*** pcm )
FUNCTION: int      vorbis_synthesis_read ( vorbis-dsp-state* v, int samples )
FUNCTION: long     vorbis_packet_blocksize ( vorbis-info* vi, ogg-packet* op )
FUNCTION: int      vorbis_synthesis_halfrate ( vorbis-info* v, int flag )
FUNCTION: int      vorbis_synthesis_halfrate_p ( vorbis-info* v )

CONSTANT: OV_FALSE -1
CONSTANT: OV_EOF -2
CONSTANT: OV_HOLE -3
CONSTANT: OV_EREAD -128
CONSTANT: OV_EFAULT -129
CONSTANT: OV_EIMPL -130
CONSTANT: OV_EINVAL -131
CONSTANT: OV_ENOTVORBIS -132
CONSTANT: OV_EBADHEADER -133
CONSTANT: OV_EVERSION -134
CONSTANT: OV_ENOTAUDIO -135
CONSTANT: OV_EBADPACKET -136
CONSTANT: OV_EBADLINK -137
CONSTANT: OV_ENOSEEK -138
