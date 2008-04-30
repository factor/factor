! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.

! Simple CSV Parser
! Phil Dawes phil@phildawes.net

USING: kernel sequences io namespaces combinators
unicode.categories ;
IN: csv

DEFER: quoted-field

! trims whitespace from either end of string
: trim-whitespace ( str -- str )
  [ blank? ] trim ; inline

: skip-to-field-end ( -- endchar )
  ",\n" read-until nip ; inline
  
: not-quoted-field ( -- endchar )
  ",\"\n" read-until   ! "
  dup
  { { CHAR: "   [ drop drop quoted-field ] }  ! " 
    { CHAR: ,   [ swap trim-whitespace % ] } 
    { CHAR: \n  [ swap trim-whitespace % ] }    
    { f         [ swap trim-whitespace % ] }       ! eof
  } case ;
  
: maybe-escaped-quote ( -- endchar )
  read1 dup 
  { { CHAR: "   [ , quoted-field ] }  ! " is an escaped quote
    { CHAR: ,   [ ] }                 ! end of quoted field 
    [ 2drop skip-to-field-end ]       ! end of quoted field + padding
  } case ;
  
: quoted-field ( -- endchar )
  "\"" read-until                                 ! "
  drop % maybe-escaped-quote ;

: field ( -- sep string )
  [ not-quoted-field ] "" make  ; ! trim-whitespace

: (row) ( -- sep )
  field , 
  dup CHAR: , = [ drop (row) ] when ;

: row ( -- eof? array[string] )
  [ (row) ] { } make ;

: append-if-row-not-empty ( row -- )
  dup { "" } = [ drop ] [ , ] if ;

: (csv) ( -- )
  row append-if-row-not-empty
  [ (csv) ] when ;

: csv-row ( stream -- row )
  [ row nip ] with-stream ;

: csv ( stream -- rows )
  [ [ (csv) ] { } make ] with-stream ;
