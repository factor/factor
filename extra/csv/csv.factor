! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.

! Simple CSV Parser
! Phil Dawes phil@phildawes.net

USING: kernel sequences io namespaces combinators unicode.categories vars ;
IN: csv

DEFER: quoted-field

VAR: delimiter

! trims whitespace from either end of string
: trim-whitespace ( str -- str )
  [ blank? ] trim ; inline

: skip-to-field-end ( -- endchar )
  "\n" delimiter> suffix read-until nip ; inline
  
: not-quoted-field ( -- endchar )
  "\"\n" delimiter> suffix read-until   ! "
  dup
  { { CHAR: "     [ drop drop quoted-field ] }  ! " 
    { delimiter> [ swap trim-whitespace % ] } 
    { CHAR: \n    [ swap trim-whitespace % ] }    
    { f           [ swap trim-whitespace % ] }       ! eof
  } case ;
  
: maybe-escaped-quote ( -- endchar )
  read1 dup 
  { { CHAR: "    [ , quoted-field ] }  ! " is an escaped quote
    { delimiter> [ ] }                 ! end of quoted field 
    { CHAR: \n   [ ] }
    [ 2drop skip-to-field-end ]       ! end of quoted field + padding
  } case ;
  
: quoted-field ( -- endchar )
  "\"" read-until                                 ! "
  drop % maybe-escaped-quote ;

: field ( -- sep string )
  [ not-quoted-field ] "" make  ; ! trim-whitespace

: (row) ( -- sep )
  field , 
  dup delimiter> = [ drop (row) ] when ;

: row ( -- eof? array[string] )
  [ (row) ] { } make ;

: append-if-row-not-empty ( row -- )
  dup { "" } = [ drop ] [ , ] if ;

: (csv) ( -- )
  row append-if-row-not-empty
  [ (csv) ] when ;

: init-vars ( -- )
  delimiter> [ CHAR: , >delimiter ] unless ; inline
  
: csv-row ( stream -- row )
  init-vars
  [ row nip ] with-input-stream ;

: csv ( stream -- rows )
  init-vars
  [ [ (csv) ] { } make ] with-input-stream ;

: with-delimiter ( char quot -- )
  delimiter swap with-variable ; inline
