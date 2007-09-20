! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!
USING: alien alien.c-types alien.syntax combinators kernel math system ;
IN: mad

: load-mad-library ( -- )
  "mad" {
    { [ macosx? ] [ "libmad.0.dylib" ] }
    { [ unix? ] [ "libmad.so" ] }
    { [ windows? ] [ "mad.dll" ] }
  } cond "cdecl" add-library ; parsing

load-mad-library

LIBRARY: mad

TYPEDEF: int mad_fixed_t 
TYPEDEF: int mad_fixed64hi_t
TYPEDEF: uint mad_fixed64lo_t

TYPEDEF: int mad_flow
TYPEDEF: int mad_decoder_mode
TYPEDEF: int mad_error
TYPEDEF: int mad_layer
TYPEDEF: int mad_mode
TYPEDEF: int mad_emphasis

C-STRUCT: mad_timer_t 
    { "long" "seconds" }
    { "ulong" "fraction" }
;

C-STRUCT: mad_bitptr 
    { "uchar*" "byte" }
    { "short" "cache" }
    { "short" "left" }
;

C-STRUCT: mad_stream 
    { "uchar*" "buffer" }
    { "uchar*" "buffend" }
    { "long" "skiplen" }
    { "int" "sync" }
    { "ulong" "freerate" }
    { "uchar*" "this_frame" }
    { "uchar*" "next_frame" }
    { "mad_bitptr" "ptr" }
    { "mad_bitptr" "anc_ptr" }
    { "uchar*" "main_data" }
    { "int" "md_len" }
    { "int" "options" }
    { "mad_error" "error" }
;

C-STRUCT: struct_async 
    { "long" "pid" }
    { "int" "in" }
    { "int" "out" }
;

C-STRUCT: mad_header 
    { "mad_layer" "layer" }
    { "mad_mode" "mode" }
    { "int" "mode_extension" }
    { "mad_emphasis" "emphasis" }
    { "ulong" "bitrate" }
    { "uint" "samplerate" }
    { "ushort" "crc_check" }
    { "ushort" "crc_target" }
    { "int" "flags" }
    { "int" "private_bits" }
    { "mad_timer_t" "duration" }
;

C-STRUCT: mad_frame 
    { "mad_header" "header" }
    { "int" "options" }
    { { "mad_fixed_t" 2304 } "sbsample" }
    { "mad_fixed_t*" "overlap" }
;

C-STRUCT: mad_pcm 
    { "uint" "samplerate" }
    { "ushort" "channels" }
    { "ushort" "length" }
    { { "mad_fixed_t" 2304 } "samples" }
;

: mad_pcm-sample-left ( pcm int -- sample ) 
  swap mad_pcm-samples int-nth ;
: mad_pcm-sample-right ( pcm int -- sample ) 
  1152 + swap mad_pcm-samples int-nth ;

C-STRUCT: mad_synth 
    { { "mad_fixed_t" 1024 } "filter" }
    { "uint" "phase" }
    { "mad_pcm" "pcm" }
;

C-STRUCT: struct_sync 
    { "mad_stream" "stream" }
    { "mad_frame" "frame" }
    { "mad_synth" "synth" }
;

C-STRUCT: mad_decoder 
    { "mad_decoder_mode" "mode" }
    { "int" "options" }
    { "struct_async" "async" }
    { "struct_sync*" "sync" }
    { "void*" "cb_data" }
    { "void*" "input_func" }
    { "void*" "header_func" }
    { "void*" "filter_func" }
    { "void*" "output_func" }
    { "void*" "error_func" }
    { "void*" "message_func" }
;

: MAD_F_FRACBITS ( -- number ) 28 ; inline
: MAD_F_ONE HEX: 10000000 ;

: MAD_DECODER_MODE_SYNC  ( -- number ) HEX: 0 ; inline
: MAD_DECODER_MODE_ASYNC ( -- number ) HEX: 1 ; inline

: MAD_FLOW_CONTINUE ( -- number ) HEX:  0 ; inline
: MAD_FLOW_STOP     ( -- number ) HEX: 10 ; inline
: MAD_FLOW_BREAK    ( -- number ) HEX: 11 ; inline
: MAD_FLOW_IGNORE   ( -- number ) HEX: 20 ; inline

: MAD_ERROR_NONE            ( -- number ) HEX: 0 ; inline
: MAD_ERROR_BUFLEN          ( -- number ) HEX: 1 ; inline
: MAD_ERROR_BUFPTR          ( -- number ) HEX: 2 ; inline
: MAD_ERROR_NOMEM           ( -- number ) HEX: 31 ; inline
: MAD_ERROR_LOSTSYNC        ( -- number ) HEX: 101 ; inline
: MAD_ERROR_BADLAYER        ( -- number ) HEX: 102 ; inline
: MAD_ERROR_BADBITRATE      ( -- number ) HEX: 103 ; inline
: MAD_ERROR_BADSAMPLERATE   ( -- number ) HEX: 104 ; inline
: MAD_ERROR_BADEMPHASIS     ( -- number ) HEX: 105 ; inline
: MAD_ERROR_BADCRC          ( -- number ) HEX: 201 ; inline
: MAD_ERROR_BADBITALLOC     ( -- number ) HEX: 211 ; inline
: MAD_ERROR_BADSCALEFACTOR  ( -- number ) HEX: 221 ; inline
: MAD_ERROR_BADMODE         ( -- number ) HEX: 222 ; inline
: MAD_ERROR_BADFRAMELEN     ( -- number ) HEX: 231 ; inline
: MAD_ERROR_BADBIGVALUES    ( -- number ) HEX: 232 ; inline
: MAD_ERROR_BADBLOCKTYPE    ( -- number ) HEX: 233 ; inline
: MAD_ERROR_BADSCFSI        ( -- number ) HEX: 234 ; inline
: MAD_ERROR_BADDATAPTR      ( -- number ) HEX: 235 ; inline
: MAD_ERROR_BADPART3LEN     ( -- number ) HEX: 236 ; inline
: MAD_ERROR_BADHUFFTABLE    ( -- number ) HEX: 237 ; inline
: MAD_ERROR_BADHUFFDATA     ( -- number ) HEX: 238 ; inline
: MAD_ERROR_BADSTEREO       ( -- number ) HEX: 239 ; inline


FUNCTION: void mad_decoder_init ( mad_decoder* decoder, void* data, void* input_func, void* header_func, void* filter_func, void* output_func, void* error_func, void* message_func ) ; 
FUNCTION: int mad_decoder_run ( mad_decoder* decoder, mad_decoder_mode mode ) ;
FUNCTION: void mad_stream_buffer ( mad_stream* stream, uchar* start, ulong length ) ;

