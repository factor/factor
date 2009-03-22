! Copyright (C) 2008 Alfredo Beaumont
! See http://factorcode.org/license.txt for BSD license.

! Emacs Etags generator
! Alfredo Beaumont <alfredo.beaumont@gmail.com>
USING: kernel sequences sorting assocs words prettyprint ctags
io.encodings.ascii io.files math math.parser namespaces make
strings shuffle io.backend arrays present ;
IN: ctags.etags

: etag-at ( key hash -- vector )
  at [ V{ } clone ] unless* ;

: etag-vector ( alist hash -- vector )
  [ ctag-path ] dip etag-at ;

: etag-pair ( ctag -- seq )
  dup [
    first ,
    second second ,
  ] { } make ;

: etag-add ( ctag hash -- )
  [ etag-vector ] 2keep [
    [ etag-pair ] [ ctag-path ] bi [ suffix ] dip
  ] dip set-at ;
    
: etag-hash ( seq -- hash )
  H{ } clone swap [ swap [ etag-add ] keep ] each ;

: lines>bytes ( seq n -- bytes )
  head 0 [ length 1+ + ] reduce ;

: file>lines ( path -- lines )
  ascii file-lines ;

: etag ( lines seq -- str )
  [
    dup first present %
    1 HEX: 7f <string> %
    second dup number>string %
    1 CHAR: , <string> %
    1- lines>bytes number>string %
  ] "" make ;

: etag-length ( vector -- n )
  0 [ length + ] reduce ;

: (etag-header) ( n path -- str )
  [
    %
    1 CHAR: , <string> %
    number>string %
  ] "" make ;

: etag-header ( vec1 n resource -- vec2 )
  normalize-path (etag-header) prefix
  1 HEX: 0c <string> prefix ;

: etag-strings ( alist -- seq )
  { } swap [
    [
      [ first file>lines ]
      [ second ] bi
      [ etag ] with map
      dup etag-length
    ] keep first 
    etag-header append
  ] each ;

: etags-write ( alist path -- )
  [ etag-strings ] dip ascii set-file-lines ; 

: etags ( path -- )
  [ (ctags) sort-values etag-hash >alist ] dip etags-write ;