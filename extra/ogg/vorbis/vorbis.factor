! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel system combinators alien alien.syntax ;
IN: ogg.vorbis

: load-vorbis-library ( -- )
    "vorbis" {
        { [ win32? ]  [ "vorbis.dll" ] }
        { [ macosx? ] [ "libvorbis.0.dylib" ] }
        { [ unix? ]   [ "libvorbis.so" ] }
    } cond "cdecl" add-library ; parsing

load-vorbis-library

LIBRARY: vorbis

C-STRUCT: vorbis_info 
    { "int" "version" }
    { "int" "channels" }
    { "long" "rate" }
    { "long" "bitrate_upper" }
    { "long" "bitrate_nominal" }
    { "long" "bitrate_lower" }
    { "long" "bitrate_window" }
    { "void*" "codec_setup"} 
    ;

C-STRUCT: vorbis_dsp_state
    { "int" "analysisp" }
    { "vorbis_info*" "vi" }
    { "float**" "pcm" }
    { "float**" "pcmret" }
    { "int" "pcm_storage" }
    { "int" "pcm_current" }
    { "int" "pcm_returned" }
    { "int" "preextrapolate" }
    { "int" "eofflag" }
    { "long" "lW" }
    { "long" "W" }
    { "long" "nW" }
    { "long" "centerW" }
    { "longlong" "granulepos" }
    { "longlong" "sequence" }
    { "longlong" "glue_bits" }
    { "longlong" "time_bits" }
    { "longlong" "floor_bits" }
    { "longlong" "res_bits" }
    { "void*" "backend_state" }
    ;

C-STRUCT: alloc_chain
    { "void*" "ptr" }
    { "void*" "next" }
    ;

C-STRUCT: vorbis_block
    { "float**" "pcm" }
    { "oggpack_buffer" "opb" }
    { "long" "lW" }
    { "long" "W" }
    { "long" "nW" }
    { "int" "pcmend" }
    { "int" "mode" }
    { "int" "eofflag" }
    { "longlong" "granulepos" }
    { "longlong" "sequence" }
    { "vorbis_dsp_state*" "vd" }
    { "void*" "localstore" }
    { "long" "localtop" }
    { "long" "localalloc" }
    { "long" "totaluse" }
    { "alloc_chain*" "reap" }
    { "long" "glue_bits" }
    { "long" "time_bits" }
    { "long" "floor_bits" }
    { "long" "res_bits" }
    { "void*" "internal" }
    ;

C-STRUCT: vorbis_comment
    { "char**" "usercomments" }
    { "int*" "comment_lengths" }
    { "int" "comments" }
    { "char*" "vendor" }
    ;

FUNCTION: void     vorbis_info_init ( vorbis_info* vi ) ;
FUNCTION: void     vorbis_info_clear ( vorbis_info* vi ) ;
FUNCTION: int      vorbis_info_blocksize ( vorbis_info* vi, int zo ) ;
FUNCTION: void     vorbis_comment_init ( vorbis_comment* vc ) ;
FUNCTION: void     vorbis_comment_add ( vorbis_comment* vc, char* comment ) ;
FUNCTION: void     vorbis_comment_add_tag ( vorbis_comment* vc, char* tag, char* contents ) ;
FUNCTION: char*    vorbis_comment_query ( vorbis_comment* vc, char* tag, int count ) ;
FUNCTION: int      vorbis_comment_query_count ( vorbis_comment* vc, char* tag ) ;
FUNCTION: void     vorbis_comment_clear ( vorbis_comment* vc ) ;
FUNCTION: int      vorbis_block_init ( vorbis_dsp_state* v, vorbis_block* vb ) ;
FUNCTION: int      vorbis_block_clear ( vorbis_block* vb ) ;
FUNCTION: void     vorbis_dsp_clear ( vorbis_dsp_state* v ) ;
FUNCTION: double   vorbis_granule_time ( vorbis_dsp_state* v, longlong granulepos ) ;
FUNCTION: int      vorbis_analysis_init ( vorbis_dsp_state* v, vorbis_info* vi ) ;
FUNCTION: int      vorbis_commentheader_out ( vorbis_comment* vc, ogg_packet* op ) ;
FUNCTION: int      vorbis_analysis_headerout ( vorbis_dsp_state* v,
					  vorbis_comment* vc,
					  ogg_packet* op,
					  ogg_packet* op_comm,
					  ogg_packet* op_code ) ;
FUNCTION: float**  vorbis_analysis_buffer ( vorbis_dsp_state* v, int vals ) ;
FUNCTION: int      vorbis_analysis_wrote ( vorbis_dsp_state* v, int vals ) ;
FUNCTION: int      vorbis_analysis_blockout ( vorbis_dsp_state* v, vorbis_block* vb ) ;
FUNCTION: int      vorbis_analysis ( vorbis_block* vb, ogg_packet* op ) ;
FUNCTION: int      vorbis_bitrate_addblock ( vorbis_block* vb ) ;
FUNCTION: int      vorbis_bitrate_flushpacket ( vorbis_dsp_state* vd,
					   ogg_packet* op ) ;
FUNCTION: int      vorbis_synthesis_headerin ( vorbis_info* vi, vorbis_comment* vc,
					  ogg_packet* op ) ;
FUNCTION: int      vorbis_synthesis_init ( vorbis_dsp_state* v, vorbis_info* vi ) ;
FUNCTION: int      vorbis_synthesis_restart ( vorbis_dsp_state* v ) ;
FUNCTION: int      vorbis_synthesis ( vorbis_block* vb, ogg_packet* op ) ;
FUNCTION: int      vorbis_synthesis_trackonly ( vorbis_block* vb, ogg_packet* op ) ;
FUNCTION: int      vorbis_synthesis_blockin ( vorbis_dsp_state* v, vorbis_block* vb ) ;
FUNCTION: int      vorbis_synthesis_pcmout ( vorbis_dsp_state* v, float*** pcm ) ;
FUNCTION: int      vorbis_synthesis_lapout ( vorbis_dsp_state* v, float*** pcm ) ;
FUNCTION: int      vorbis_synthesis_read ( vorbis_dsp_state* v, int samples ) ;
FUNCTION: long     vorbis_packet_blocksize ( vorbis_info* vi, ogg_packet* op ) ;
FUNCTION: int      vorbis_synthesis_halfrate ( vorbis_info* v, int flag ) ;
FUNCTION: int      vorbis_synthesis_halfrate_p ( vorbis_info* v ) ;

: OV_FALSE ( -- number ) -1 ; inline
: OV_EOF ( -- number ) -2 ; inline
: OV_HOLE ( -- number ) -3 ; inline
: OV_EREAD ( -- number ) -128 ; inline
: OV_EFAULT ( -- number ) -129 ; inline
: OV_EIMPL ( -- number ) -130 ; inline
: OV_EINVAL ( -- number ) -131 ; inline
: OV_ENOTVORBIS ( -- number ) -132 ; inline
: OV_EBADHEADER ( -- number ) -133 ; inline
: OV_EVERSION ( -- number ) -134 ; inline
: OV_ENOTAUDIO ( -- number ) -135 ; inline
: OV_EBADPACKET ( -- number ) -136 ; inline
: OV_EBADLINK ( -- number ) -137 ; inline
: OV_ENOSEEK ( -- number ) -138 ; inline
