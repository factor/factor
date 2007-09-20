! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
!

USING: arrays combinators io io.binary io.files io.utf16 kernel math math.parser namespaces sequences splitting strings assocs ;

IN: id3

TUPLE: tag header frames ;
C: <tag> tag

TUPLE: header version revision flags size extended-header ;
C: <header> header

TUPLE: frame id size flags data ;
C: <frame> frame

TUPLE: extended-header size flags update crc restrictions ;
C: <extended-header> extended-header

: debug-stream ( msg -- )
!  global [ . flush ] bind ;
  drop ;

: >hexstring ( str -- hex )
  >array [ >hex 2 CHAR: 0 pad-left ] map concat ;

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
  4 read be> ;

: text-frame? ( id -- ? )
  "T" head? ;

: read-text ( size -- text )
  read1 swap 1 - read swap 1 = [ decode-utf16 ] [ ] if
  "\0" ?tail drop ; ! remove null terminator

: read-popm ( size -- popm )
  read-text ; 

: read-frame-data ( id size -- data )
  swap
  {
    { [ dup text-frame? ] [ drop read-text ] }
    { [ "POPM" = ] [ read-popm ] }
    { [ t ] [ read ] }
  } cond ;

: (read-frame) ( id -- frame )
  read-frame-size read-frame-flags pick pick read-frame-data <frame> ;

: read-frame ( -- frame/f )
  read-frame-id dup good-frame-id? [ (read-frame) ] [ drop f ] if ;

: (read-frames) ( vector -- frames )
  read-frame [ over push (read-frames) ] when* ;

: read-frames ( -- frames )
  V{ } clone (read-frames) ;

: read-eh-flags ( -- flags )
  read1 read le> ;
  
: read-eh-data ( size -- data )
  6 - read ;

: read-crc ( flags -- crc )
  5 bit? [ read1 read >syncsafe ] [ f ] if ; 

: tag-is-update? ( flags -- ? )
  6 bit? dup [ read1 drop ] [ ] if ;

: (read-tag-restrictions) ( -- restrictions )
  read1 dup read le> ; 

: read-tag-restrictions ( flags -- restrictions/f )
  4 bit? [ (read-tag-restrictions) ] [ f ] if ;

: (read-extended-header) ( -- extended-header )
  read-size read-eh-flags dup tag-is-update? over dup
  read-crc swap read-tag-restrictions <extended-header> ;

: read-extended-header ( flags -- extended-header/f )
  6 bit? [ (read-extended-header) ] [ f ] if ;

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
  [ path+ ] curry* map ;

: get-paths ( dir -- paths )
  dup directory keys append-path ;

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

