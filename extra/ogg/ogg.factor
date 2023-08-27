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
    system
;
IN: ogg

<<
"ogg" {
    { [ os windows? ]  [ "ogg.dll" ] }
    { [ os macosx? ] [ "libogg.dylib" ] }
    { [ os unix? ]   [ "libogg.so" ] }
} cond cdecl add-library

"ogg" deploy-library
>>

LIBRARY: ogg

STRUCT: oggpack-buffer
    { endbyte long }
    { endbit int   }
    { buffer uchar* }
    { ptr uchar* }
    { storage long } ;

STRUCT: ogg-page
    {  header uchar* }
    {  header_len long }
    {  body uchar* }
    {  body_len long } ;

STRUCT: ogg-stream-state
    {  body_data uchar* }
    {  body_storage long }
    {  body_fill long }
    {  body_returned long }
    {  lacing_vals int* }
    {  granule_vals longlong* }
    {  lacing_storage long }
    {  lacing_fill long }
    {  lacing_packet long }
    {  lacing_returned long }
    {  header { uchar 282 } }
    {  header_fill int }
    {  e_o_s int }
    {  b_o_s int }
    {  serialno long  }
    {  pageno long }
    {  packetno longlong }
    {  granulepos longlong } ;

STRUCT: ogg-packet
    {  packet uchar* }
    {  bytes long }
    {  b_o_s long }
    {  e_o_s long }
    {  granulepos longlong }
    {  packetno longlong } ;

STRUCT: ogg-sync-state
    { data uchar* }
    { storage int }
    { fill int }
    { returned int }
    { unsynced int }
    { headerbytes int }
    { bodybytes int } ;

FUNCTION: void oggpack_writeinit ( oggpack-buffer* b )
FUNCTION: void  oggpack_writetrunc ( oggpack-buffer* b, long bits )
FUNCTION: void  oggpack_writealign ( oggpack-buffer* b )
FUNCTION: void  oggpack_writecopy ( oggpack-buffer* b, void* source, long bits )
FUNCTION: void  oggpack_reset ( oggpack-buffer* b )
FUNCTION: void  oggpack_writeclear ( oggpack-buffer* b )
FUNCTION: void  oggpack_readinit ( oggpack-buffer* b, uchar* buf, int bytes )
FUNCTION: void  oggpack_write ( oggpack-buffer* b, ulong value, int bits )
FUNCTION: long  oggpack_look ( oggpack-buffer* b, int bits )
FUNCTION: long  oggpack_look1 ( oggpack-buffer* b )
FUNCTION: void  oggpack_adv ( oggpack-buffer* b, int bits )
FUNCTION: void  oggpack_adv1 ( oggpack-buffer* b )
FUNCTION: long  oggpack_read ( oggpack-buffer* b, int bits )
FUNCTION: long  oggpack_read1 ( oggpack-buffer* b )
FUNCTION: long  oggpack_bytes ( oggpack-buffer* b )
FUNCTION: long  oggpack_bits ( oggpack-buffer* b )
FUNCTION: uchar* oggpack_get_buffer ( oggpack-buffer* b )
FUNCTION: void  oggpackB_writeinit ( oggpack-buffer* b )
FUNCTION: void  oggpackB_writetrunc ( oggpack-buffer* b, long bits )
FUNCTION: void  oggpackB_writealign ( oggpack-buffer* b )
FUNCTION: void  oggpackB_writecopy ( oggpack-buffer* b, void* source, long bits )
FUNCTION: void  oggpackB_reset ( oggpack-buffer* b )
FUNCTION: void  oggpackB_writeclear ( oggpack-buffer* b )
FUNCTION: void  oggpackB_readinit ( oggpack-buffer* b, uchar* buf, int bytes )
FUNCTION: void  oggpackB_write ( oggpack-buffer* b, ulong value, int bits )
FUNCTION: long  oggpackB_look ( oggpack-buffer* b, int bits )
FUNCTION: long  oggpackB_look1 ( oggpack-buffer* b )
FUNCTION: void  oggpackB_adv ( oggpack-buffer* b, int bits )
FUNCTION: void  oggpackB_adv1 ( oggpack-buffer* b )
FUNCTION: long  oggpackB_read ( oggpack-buffer* b, int bits )
FUNCTION: long  oggpackB_read1 ( oggpack-buffer* b )
FUNCTION: long  oggpackB_bytes ( oggpack-buffer* b )
FUNCTION: long  oggpackB_bits ( oggpack-buffer* b )
FUNCTION: uchar* oggpackB_get_buffer ( oggpack-buffer* b )
FUNCTION: int      ogg_stream_packetin ( ogg-stream-state* os, ogg-packet* op )
FUNCTION: int      ogg_stream_pageout ( ogg-stream-state* os, ogg-page* og )
FUNCTION: int      ogg_stream_flush ( ogg-stream-state* os, ogg-page* og )
FUNCTION: int      ogg_sync_init ( ogg-sync-state* oy )
FUNCTION: int      ogg_sync_clear ( ogg-sync-state* oy )
FUNCTION: int      ogg_sync_reset ( ogg-sync-state* oy )
FUNCTION: int   ogg_sync_destroy ( ogg-sync-state* oy )

FUNCTION: void* ogg_sync_buffer ( ogg-sync-state* oy, long size )
FUNCTION: int      ogg_sync_wrote ( ogg-sync-state* oy, long bytes )
FUNCTION: long     ogg_sync_pageseek ( ogg-sync-state* oy, ogg-page* og )
FUNCTION: int      ogg_sync_pageout ( ogg-sync-state* oy, ogg-page* og )
FUNCTION: int      ogg_stream_pagein ( ogg-stream-state* os, ogg-page* og )
FUNCTION: int      ogg_stream_packetout ( ogg-stream-state* os, ogg-packet* op )
FUNCTION: int      ogg_stream_packetpeek ( ogg-stream-state* os, ogg-packet* op )
FUNCTION: int      ogg_stream_init ( ogg-stream-state* os, int serialno )
FUNCTION: int      ogg_stream_clear ( ogg-stream-state* os )
FUNCTION: int      ogg_stream_reset ( ogg-stream-state* os )
FUNCTION: int      ogg_stream_reset_serialno ( ogg-stream-state* os, int serialno )
FUNCTION: int      ogg_stream_destroy ( ogg-stream-state* os )
FUNCTION: int      ogg_stream_eos ( ogg-stream-state* os )
FUNCTION: void     ogg_page_checksum_set ( ogg-page* og )
FUNCTION: int      ogg_page_version ( ogg-page* og )
FUNCTION: int      ogg_page_continued ( ogg-page* og )
FUNCTION: int      ogg_page_bos ( ogg-page* og )
FUNCTION: int      ogg_page_eos ( ogg-page* og )
FUNCTION: longlong  ogg_page_granulepos ( ogg-page* og )
FUNCTION: int      ogg_page_serialno ( ogg-page* og )
FUNCTION: long     ogg_page_pageno ( ogg-page* og )
FUNCTION: int      ogg_page_packets ( ogg-page* og )
FUNCTION: void     ogg_packet_clear ( ogg-packet* op )
