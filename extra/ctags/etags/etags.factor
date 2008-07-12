! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Emacs Etags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>
USING: kernel sequences sorting assocs words prettyprint ctags
io.encodings.ascii io.files math math.parser namespaces strings locals
shuffle io.backend arrays ;
IN: ctags.etags

: ctag-path ( alist -- path )
  second first ;

: ctag-at ( key hash -- vector )
  at [ V{ } clone ] unless* ;

: ctag-hashvalue ( alist hash -- vector )
  [ ctag-path ] dip ctag-at ;

: ctag-value ( ctag -- seq )
  dup [ first , second second , ] { } make ;

: ctag-add ( ctag hash -- hash )
  [ ctag-hashvalue ] 2keep [
    dup ctag-path [ ctag-value suffix ] dip
  ] dip [ set-at ] keep ;
    
: ctag-hash ( seq -- hash )
  H{ } clone swap [ swap ctag-add ] each ;

: lines>bytes ( seq n -- bytes )
  head 0 [ length 1+ + ] reduce ;

: file>lines ( resource -- lines )
  ascii file-lines ;

: etag ( lines seq -- str )
  [
    dup first ?word-name %
    1 HEX: 7f <string> %
    second dup number>string %
    1 CHAR: , <string> %
    1- lines>bytes number>string %
  ] "" make ;

: etag-entry ( alist -- alist array )
  [ first ] keep swap [ file>lines ] keep 2array ;

: vector-length ( vector -- n )
  0 [ length + ] reduce ;

: <header> ( n path -- str )
  [
    %
    1 CHAR: , <string> %
    number>string %
  ] "" make ;

: etag-header ( vec1 n resource -- vec2 )
  normalize-path <header> prefix
  1 HEX: 0c <string> prefix ;

SYMBOL: resource    
: etag-strings ( alist -- seq )
  { } swap [
    etag-entry resource [
      second [
        resource get first swap etag
      ] map dup vector-length
      resource get second
    ] with-variable
    etag-header append
  ] each ;

: etags-write ( alist path -- )
  [ etag-strings ] dip ascii set-file-lines ; 

: etags ( path -- )
  (ctags) sort-values ctag-hash >alist swap etags-write ;