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
    ogg
    system
;
IN: ogg.theora

<<
"theoradec" {
    { [ os windows? ]  [ "theoradec.dll" ] }
    { [ os macosx? ] [ "libtheoradec.dylib" ] }
    { [ os unix? ]   [ "libtheoradec.so" ] }
} cond cdecl add-library

"theoraenc" {
    { [ os windows? ]  [ "theoraenc.dll" ] }
    { [ os macosx? ] [ "libtheoraenc.dylib" ] }
    { [ os unix? ]   [ "libtheoraenc.so" ] }
} cond cdecl add-library
>>

CONSTANT: TH-EFAULT      -1
CONSTANT: TH-EINVAL     -10
CONSTANT: TH-EBADHEADER -20
CONSTANT: TH-ENOTFORMAT -21
CONSTANT: TH-EVERSION   -22
CONSTANT: TH-EIMPL      -23
CONSTANT: TH-EBADPACKET -24
CONSTANT: TH-DUPFRAME     1

TYPEDEF: int th-colorspace
CONSTANT: TH-CS-UNSPECIFIED   0
CONSTANT: TH-CS-ITU-REC-470M  1
CONSTANT: TH-CS-ITU-REC-470BG 2
CONSTANT: TH-CS-NSPACES       3

TYPEDEF: int th-pixelformat
CONSTANT: TH-PF-RSVD     0
CONSTANT: TH-PF-422      1
CONSTANT: TH-PF-444      2
CONSTANT: TH-PF-NFORMATS 3

STRUCT: th-img-plane
    { width int }
    { height int }
    { stride int }
    { data uchar* }
;

TYPEDEF: th-img-plane[3] th-ycbcr-buffer

STRUCT: th-info
    { version-major uchar }
    { version-minor uchar }
    { version-subminor uchar }
    { frame-width uint }
    { frame-height uint }
    { pic-width uint }
    { pic-height uint }
    { pic-x uint }
    { pic-y uint }
    { fps-numerator uint }
    { fps-denominator uint }
    { aspect-numerator uint }
    { aspect-denominator uint }
    { colorspace th-colorspace }
    { pixel-fmt th-pixelformat }
    { target-bitrate int }
    { quality int }
    { keyframe-granule-shift int }
;

STRUCT: th-comment
    { user-comments c-string* }
    { comment-lengths int* }
    { comments int }
    { vendor c-string }
;

TYPEDEF: uchar[64] th-quant-base

STRUCT: th-quant-ranges
    { nranges int }
    { sizes int* }
    { base-matrices th-quant-base* }
;

STRUCT: th-quant-info
    { dc-scale { short 64 } }
    { ac-scale { short 64 } }
    { loop-filter-limits { uchar 64 } }
    { qi-ranges { th-quant-ranges 2 3 } }
;

CONSTANT: TH-NHUFFMANE-TABLES 80
CONSTANT: TH-NDCT-TOKENS 32

STRUCT: th-huff-code
    { pattern int }
    { nbits int }
;

LIBRARY: theoradec
FUNCTION: c-string th_version_string ( )
FUNCTION: uint th_version_number ( )
FUNCTION: longlong th_granule_frame ( void* encdec, longlong granpos )
FUNCTION: int th_packet_isheader ( ogg-packet* op )
FUNCTION: int th_packet_iskeyframe ( ogg-packet* op )
FUNCTION: void th_info_init ( th-info* info )
FUNCTION: void th_info_clear ( th-info* info )
FUNCTION: void th_comment_init ( th-comment* tc )
FUNCTION: void th_comment_add ( th-comment* tc, c-string comment )
FUNCTION: void th_comment_add_tag ( th-comment* tc, c-string tag, c-string value )
FUNCTION: c-string th_comment_query ( th-comment* tc, c-string tag, int count )
FUNCTION: int   th_comment_query_count ( th-comment* tc, c-string tag )
FUNCTION: void  th_comment_clear ( th-comment* tc )

CONSTANT: TH-ENCCTL-SET-HUFFMAN-CODES 0
CONSTANT: TH-ENCCTL-SET-QUANT-PARAMS 2
CONSTANT: TH-ENCCTL-SET-KEYFRAME-FREQUENCY-FORCE 4
CONSTANT: TH-ENCCTL-SET-VP3-COMPATIBLE 10
CONSTANT: TH-ENCCTL-GET-SPLEVEL-MAX 12
CONSTANT: TH-ENCCTL-SET-SPLEVEL 14
CONSTANT: TH-ENCCTL-SET-DUP-COUNT 18
CONSTANT: TH-ENCCTL-SET-RATE-FLAGS 20
CONSTANT: TH-ENCCTL-SET-RATE-BUFFER 22
CONSTANT: TH-ENCCTL-2PASS-OUT 24
CONSTANT: TH-ENCCTL-2PASS-IN 26
CONSTANT: TH-ENCCTL-SET-QUALITY 28
CONSTANT: TH-ENCCTL-SET-BITRATE 30

CONSTANT: TH-RATECTL-DROP-FRAMES 1
CONSTANT: TH-RATECTL-CAP-OVERFLOW 2
CONSTANT: TH-RATECTL-CAP-UNDERFOW 4

TYPEDEF: void* th-enc-ctx

LIBRARY: theoraenc
FUNCTION: th-enc-ctx* th_encode_alloc ( th-info* info )
FUNCTION: int th_encode_ctl ( th-enc-ctx* enc, int req, void* buf, int buf_sz )
FUNCTION: int th_encode_flushheader ( th-enc-ctx* enc, th-comment* comments, ogg-packet* op )
FUNCTION: int th_encode_ycbcr_in ( th-enc-ctx* enc, th-ycbcr-buffer ycbcr )
FUNCTION: int th_encode_packetout ( th-enc-ctx* enc, int last, ogg-packet* op )
FUNCTION: void th_encode_free ( th-enc-ctx* enc )

CONSTANT: TH-DECCTL-GET-PPLEVEL-MAX 1
CONSTANT: TH-DECCTL-SET-PPLEVEL 3
CONSTANT: TH-DECCTL-SET-GRANPOS 5
CONSTANT: TH-DECCTL-SET-STRIPE-CB 7
CONSTANT: TH-DECCTL-SET-TELEMETRY-MBMODE 9
CONSTANT: TH-DECCTL-SET-TELEMETRY-MV 11
CONSTANT: TH-DECCTL-SET-TELEMETRY-QI 13
CONSTANT: TH-DECCTL-SET-TELEMETRY-BITS 15

TYPEDEF: void* th-stripe-decoded-func

STRUCT: th-stripe-callback
    { ctx void* }
    { stripe-decoded th-stripe-decoded-func }
;

TYPEDEF: void* th-dec-ctx
TYPEDEF: void* th-setup-info

LIBRARY: theoradec
FUNCTION: int th_decode_headerin ( th-info* info, th-comment* tc, th-setup-info** setup, ogg-packet* op )
FUNCTION: th-dec-ctx* th_decode_alloc ( th-info* info, th-setup-info* setup )
FUNCTION: void th_setup_free ( th-setup-info* setup )
FUNCTION: int th_decode_ctl ( th-dec-ctx* dec, int req, void* buf, int buf_sz )
FUNCTION: int th_decode_packetin ( th-dec-ctx* dec, ogg-packet* op, longlong granpos )
FUNCTION: int th_decode_ycbcr_out ( th-dec-ctx* dec, th-ycbcr-buffer ycbcr )
FUNCTION: void th_decode_free ( th-dec-ctx* dec )
