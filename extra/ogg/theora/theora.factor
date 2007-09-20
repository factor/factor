! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel system combinators alien alien.syntax ;
IN: ogg.theora

: load-theora-library ( -- )
    "theora" {
        { [ win32? ]  [ "libtheora.dll" ] }
        { [ macosx? ] [ "libtheora.0.dylib" ] }
        { [ unix? ]   [ "libtheora.so" ] }
    } cond "cdecl" add-library ; parsing

load-theora-library

LIBRARY: theora

C-STRUCT: yuv_buffer
    { "int" "y_width" }
    { "int" "y_height" }
    { "int" "y_stride" }
    { "int" "uv_width" }
    { "int" "uv_height" }
    { "int" "uv_stride" }
    { "void*" "y" }
    { "void*" "u" }
    { "void*" "v" } ;

: OC_CS_UNSPECIFIED ( -- number ) 0 ; inline
: OC_CS_ITU_REC_470M ( -- number ) 1 ; inline
: OC_CS_ITU_REC_470BG ( -- number ) 2 ; inline
: OC_CS_NSPACES ( -- number ) 3 ; inline

TYPEDEF: int theora_colorspace 

: OC_PF_420 ( -- number ) 0 ; inline
: OC_PF_RSVD ( -- number ) 1 ; inline
: OC_PF_422 ( -- number ) 2 ; inline
: OC_PF_444 ( -- number ) 3 ; inline

TYPEDEF: int theora_pixelformat

C-STRUCT: theora_info
    { "uint" "width" }
    { "uint" "height" }
    { "uint" "frame_width" }
    { "uint" "frame_height" }
    { "uint" "offset_x" }
    { "uint" "offset_y" }
    { "uint" "fps_numerator" }
    { "uint" "fps_denominator" }
    { "uint" "aspect_numerator" }
    { "uint" "aspect_denominator" }
    { "theora_colorspace" "colorspace" }
    { "int" "target_bitrate" }
    { "int" "quality" }
    { "int" "quick_p" }
    { "uchar" "version_major" }
    { "uchar" "version_minor" } 
    { "uchar" "version_subminor" }
    { "void*" "codec_setup" }
    { "int" "dropframes_p" }
    { "int" "keyframe_auto_p" }
    { "uint" "keyframe_frequency" }
    { "uint" "keyframe_frequency_force" }
    { "uint" "keyframe_data_target_bitrate" }
    { "int" "keyframe_auto_threshold" }
    { "uint" "keyframe_mindistance" }
    { "int" "noise_sensitivity" }
    { "int" "sharpness" }
    { "theora_pixelformat" "pixelformat" } ;

C-STRUCT: theora_state
    { "theora_info*" "i" }
    { "longlong" "granulepos" }
    { "void*" "internal_encode" }
    { "void*" "internal_decode" } ;

C-STRUCT: theora_comment
    { "char**" "user_comments" }
    { "int*" "comment_lengths" }
    { "int" "comments" }
    { "char*" "vendor" } ;

: OC_FAULT ( -- number ) -1 ; inline
: OC_EINVAL ( -- number ) -10 ; inline
: OC_DISABLED ( -- number ) -11 ; inline
: OC_BADHEADER ( -- number ) -20 ; inline
: OC_NOTFORMAT ( -- number ) -21 ; inline
: OC_VERSION ( -- number ) -22 ; inline
: OC_IMPL ( -- number ) -23 ; inline
: OC_BADPACKET ( -- number ) -24 ; inline
: OC_NEWPACKET ( -- number ) -25 ; inline
: OC_DUPFRAME ( -- number ) 1 ; inline

FUNCTION: char* theora_version_string ( ) ;
FUNCTION: uint theora_version_number ( ) ;
FUNCTION: int theora_encode_init ( theora_state* th, theora_info* ti ) ;
FUNCTION: int theora_encode_YUVin ( theora_state* t, yuv_buffer* yuv ) ;
FUNCTION: int theora_encode_packetout ( theora_state* t, int last_p, ogg_packet* op ) ;
FUNCTION: int theora_encode_header ( theora_state* t, ogg_packet* op ) ;
FUNCTION: int theora_encode_comment ( theora_comment* tc, ogg_packet* op ) ;
FUNCTION: int theora_encode_tables ( theora_state* t, ogg_packet* op ) ;
FUNCTION: int theora_decode_header ( theora_info* ci, theora_comment* cc, ogg_packet* op ) ;
FUNCTION: int theora_decode_init ( theora_state* th, theora_info* c ) ;
FUNCTION: int theora_decode_packetin ( theora_state* th, ogg_packet* op ) ;
FUNCTION: int theora_decode_YUVout ( theora_state* th, yuv_buffer* yuv ) ;
FUNCTION: int theora_packet_isheader ( ogg_packet* op ) ;
FUNCTION: int theora_packet_iskeyframe ( ogg_packet* op ) ;
FUNCTION: int theora_granule_shift ( theora_info* ti ) ;
FUNCTION: longlong theora_granule_frame ( theora_state* th, longlong granulepos ) ;
FUNCTION: double theora_granule_time ( theora_state* th, longlong granulepos ) ;
FUNCTION: void theora_info_init ( theora_info* c ) ;
FUNCTION: void theora_info_clear ( theora_info* c ) ;
FUNCTION: void theora_clear ( theora_state* t ) ;
FUNCTION: void theora_comment_init ( theora_comment* tc ) ;
FUNCTION: void theora_comment_add ( theora_comment* tc, char* comment ) ;
FUNCTION: void theora_comment_add_tag ( theora_comment* tc, char* tag, char* value ) ;
FUNCTION: char* theora_comment_query ( theora_comment* tc, char* tag, int count ) ;
FUNCTION: int   theora_comment_query_count ( theora_comment* tc, char* tag ) ;
FUNCTION: void  theora_comment_clear ( theora_comment* tc ) ;
