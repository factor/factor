! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!

IN: id3

USING: kernel io math arrays sequences words namespaces prettyprint strings interpreter ;

TUPLE: tag header frames ;
TUPLE: header version revision flags size extended-header ;
TUPLE: frame id size flags data ;
TUPLE: extended-header size flags update crc restrictions ;

: debug-stream ( msg -- )
!  global [ . flush ] bind ;
  drop ;

: >hexstring ( str -- hex )
  >array [ >hex 2 CHAR: 0 pad-left ] map concat ;

: bit-set? ( int n -- ? ) neg shift odd? ;

: good-frame-id? ( id -- ? )
  [ [ LETTER? ] keep digit? or ] all? ;

! 4 byte syncsafe integer (28 effective bits)
: >syncsafe ( seq -- int )
  0 [ >r 7 shift r> bitor ] reduce ;

: read-size ( -- size )
  4 read >syncsafe ; 

: read-frame-id ( -- id )
  4 read ;

: read-frame-flags ( -- flags )
  2 read ;

: read-frame-size ( -- size )
  4 read dup debug-stream be> ;

: text-frame? ( id -- ? )
  "T" head? ;

: read-text ( size -- text )
  read1 drop read ;

: read-frame-data ( id size -- data )
  swap text-frame? [ read-text ] [ read ] if ;

: (read-frame) ( id -- frame )
  read-frame-size dup debug-stream read-frame-flags pick pick read-frame-data <frame> ;

: read-frame ( -- frame/f )
  read-frame-id dup debug-stream dup good-frame-id? [ (read-frame) ] [ drop f ] if ;

: (read-frames) ( vector -- frames )
  read-frame [ over push (read-frames) ] when* ;

: read-frames ( -- frames )
  V{ } clone (read-frames) ;

: read-eh-flags ( -- flags )
  read1 read le> ;
  
: read-eh-data ( size -- data )
  6 - read ;

: read-crc ( flags -- crc )
  5 bit-set? [ read1 read >syncsafe ] [ f ] if ; 

: tag-is-update? ( flags -- ? )
  6 bit-set? dup [ read1 drop ] [ ] if ;

: (read-tag-restrictions) ( -- restrictions )
  read1 dup read le> ; 

: read-tag-restrictions ( flags -- restrictions/f )
  4 bit-set? [ (read-tag-restrictions) ] [ f ] if ;

: (read-extended-header) ( -- extended-header )
  read-size read-eh-flags dup tag-is-update? over dup
  read-crc swap read-tag-restrictions <extended-header> ;

: read-extended-header ( flags -- extended-header/f )
  6 bit-set? [ (read-extended-header) ] [ f ] if ;

: read-header ( version -- header )
  read1 read1 read-size over read-extended-header <header> ;

: (read-id3v2) ( version -- tag )
  read-header read-frames <tag> ;

: supported-version? ( version -- ? )
  [ 3 4 ] member? ;

: read-id3v2 ( -- tag/f )
  read1 dup supported-version?
  [ (read-id3v2) ] [ drop f ] if ;

: id3v2? ( -- ? )
  3 read "ID3" = ;

: read-tag ( stream -- tag/f )
  id3v2? [ read-id3v2 ] [ f ] if ;

: id3v2 ( filename -- tag/f )
  <file-reader> [ read-tag ] with-stream ;

: append-path ( path files -- paths )
  [ path+ ] map-with ;

: get-paths ( dir -- paths )
  dup directory append-path ;

: (walk-dir) ( path -- )
  dup directory? [ get-paths dup % [ (walk-dir) ] each ] [ drop ] if ;

: walk-dir ( path -- seq )
  [ (walk-dir) ] { } make ;

: file? ( path -- ? )
  stat 3drop not ;

: files ( paths -- files )
  [ file? ] subset ;

: mp3? ( path -- ? )
  ".mp3" tail? ;
  
: mp3s ( paths -- mp3s )
  [ mp3? ] subset ;

: id3? ( file -- ? )
  <file-reader> [ id3v2? ] with-stream ;

: id3s ( files -- id3s )
  [ id3? ] subset ;

