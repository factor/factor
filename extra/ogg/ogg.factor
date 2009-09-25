! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
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
    { [ os winnt? ]  [ "ogg.dll" ] }
    { [ os macosx? ] [ "libogg.0.dylib" ] }
    { [ os unix? ]   [ "libogg.so" ] }
} cond "cdecl" add-library
>>

LIBRARY: ogg

STRUCT: oggpack_buffer
    { endbyte long }
    { endbit int   }
    { buffer uchar* }
    { ptr uchar* }
    { storage long } ;

STRUCT: ogg_page
    {  header uchar* }
    {  header_len long }
    {  body uchar* }
    {  body_len long } ;

STRUCT: ogg_stream_state
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

STRUCT: ogg_packet
    {  packet uchar* }
    {  bytes long }
    {  b_o_s long }
    {  e_o_s long }
    {  granulepos longlong }
    {  packetno longlong } ;

STRUCT: ogg_sync_state
    { data uchar* }
    { storage int }
    { fill int }  
    { returned int }
    { unsynced int }
    { headerbytes int }
    { bodybytes int } ;

FUNCTION: void oggpack_writeinit ( oggpack_buffer* b ) ;
FUNCTION: void  oggpack_writetrunc ( oggpack_buffer* b, long bits ) ;
FUNCTION: void  oggpack_writealign ( oggpack_buffer* b) ;
FUNCTION: void  oggpack_writecopy ( oggpack_buffer* b, void* source, long bits ) ;
FUNCTION: void  oggpack_reset ( oggpack_buffer* b ) ;
FUNCTION: void  oggpack_writeclear ( oggpack_buffer* b ) ;
FUNCTION: void  oggpack_readinit ( oggpack_buffer* b, uchar* buf, int bytes ) ;
FUNCTION: void  oggpack_write ( oggpack_buffer* b, ulong value, int bits ) ;
FUNCTION: long  oggpack_look ( oggpack_buffer* b, int bits ) ;
FUNCTION: long  oggpack_look1 ( oggpack_buffer* b ) ;
FUNCTION: void  oggpack_adv ( oggpack_buffer* b, int bits ) ;
FUNCTION: void  oggpack_adv1 ( oggpack_buffer* b ) ;
FUNCTION: long  oggpack_read ( oggpack_buffer* b, int bits ) ;
FUNCTION: long  oggpack_read1 ( oggpack_buffer* b ) ;
FUNCTION: long  oggpack_bytes ( oggpack_buffer* b ) ;
FUNCTION: long  oggpack_bits ( oggpack_buffer* b ) ;
FUNCTION: uchar* oggpack_get_buffer ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_writeinit ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_writetrunc ( oggpack_buffer* b, long bits ) ;
FUNCTION: void  oggpackB_writealign ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_writecopy ( oggpack_buffer* b, void* source, long bits ) ;
FUNCTION: void  oggpackB_reset ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_writeclear ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_readinit ( oggpack_buffer* b, uchar* buf, int bytes ) ;
FUNCTION: void  oggpackB_write ( oggpack_buffer* b, ulong value, int bits ) ;
FUNCTION: long  oggpackB_look ( oggpack_buffer* b, int bits ) ;
FUNCTION: long  oggpackB_look1 ( oggpack_buffer* b ) ;
FUNCTION: void  oggpackB_adv ( oggpack_buffer* b, int bits ) ;
FUNCTION: void  oggpackB_adv1 ( oggpack_buffer* b ) ;
FUNCTION: long  oggpackB_read ( oggpack_buffer* b, int bits ) ;
FUNCTION: long  oggpackB_read1 ( oggpack_buffer* b ) ;
FUNCTION: long  oggpackB_bytes ( oggpack_buffer* b ) ;
FUNCTION: long  oggpackB_bits ( oggpack_buffer* b ) ;
FUNCTION: uchar* oggpackB_get_buffer ( oggpack_buffer* b ) ;
FUNCTION: int      ogg_stream_packetin ( ogg_stream_state* os, ogg_packet* op ) ;
FUNCTION: int      ogg_stream_pageout ( ogg_stream_state* os, ogg_page* og ) ;
FUNCTION: int      ogg_stream_flush ( ogg_stream_state* os, ogg_page* og ) ;
FUNCTION: int      ogg_sync_init ( ogg_sync_state* oy ) ;
FUNCTION: int      ogg_sync_clear ( ogg_sync_state* oy ) ;
FUNCTION: int      ogg_sync_reset ( ogg_sync_state* oy ) ;
FUNCTION: int   ogg_sync_destroy ( ogg_sync_state* oy ) ;

FUNCTION: void* ogg_sync_buffer ( ogg_sync_state* oy, long size ) ;
FUNCTION: int      ogg_sync_wrote ( ogg_sync_state* oy, long bytes ) ;
FUNCTION: long     ogg_sync_pageseek ( ogg_sync_state* oy, ogg_page* og ) ;
FUNCTION: int      ogg_sync_pageout ( ogg_sync_state* oy, ogg_page* og ) ;
FUNCTION: int      ogg_stream_pagein ( ogg_stream_state* os, ogg_page* og ) ;
FUNCTION: int      ogg_stream_packetout ( ogg_stream_state* os, ogg_packet* op ) ;
FUNCTION: int      ogg_stream_packetpeek ( ogg_stream_state* os, ogg_packet* op ) ;
FUNCTION: int      ogg_stream_init (ogg_stream_state* os, int serialno ) ;
FUNCTION: int      ogg_stream_clear ( ogg_stream_state* os ) ;
FUNCTION: int      ogg_stream_reset ( ogg_stream_state* os ) ;
FUNCTION: int      ogg_stream_reset_serialno ( ogg_stream_state* os, int serialno ) ;
FUNCTION: int      ogg_stream_destroy ( ogg_stream_state* os ) ;
FUNCTION: int      ogg_stream_eos ( ogg_stream_state* os ) ;
FUNCTION: void     ogg_page_checksum_set ( ogg_page* og ) ;
FUNCTION: int      ogg_page_version ( ogg_page* og ) ;
FUNCTION: int      ogg_page_continued ( ogg_page* og ) ;
FUNCTION: int      ogg_page_bos ( ogg_page* og ) ;
FUNCTION: int      ogg_page_eos ( ogg_page* og ) ;
FUNCTION: longlong  ogg_page_granulepos ( ogg_page* og ) ;
FUNCTION: int      ogg_page_serialno ( ogg_page* og ) ;
FUNCTION: long     ogg_page_pageno ( ogg_page* og ) ;
FUNCTION: int      ogg_page_packets ( ogg_page* og ) ;
FUNCTION: void     ogg_packet_clear ( ogg_packet* op ) ;

