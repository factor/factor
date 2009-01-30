! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.

! Simple CSV Parser
! Phil Dawes phil@phildawes.net

USING: kernel sequences io namespaces make
combinators unicode.categories ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

: delimiter> ( -- delimiter ) delimiter get ; inline
    
DEFER: quoted-field ( -- endchar )
    
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
  dup delimiter get = [ drop (row) ] when ;

: row ( -- eof? array[string] )
  [ (row) ] { } make ;

: append-if-row-not-empty ( row -- )
  dup { "" } = [ drop ] [ , ] if ;

: (csv) ( -- )
  row append-if-row-not-empty
  [ (csv) ] when ;
  
: csv-row ( stream -- row )
  [ row nip ] with-input-stream ;

: csv ( stream -- rows )
  [ [ (csv) ] { } make ] with-input-stream ;

: with-delimiter ( char quot -- )
  delimiter swap with-variable ; inline

: needs-escaping? ( cell -- ? )
  [ [ "\n\"" member? ] [ delimiter get = ] bi or ] any? ; inline

: escape-quotes ( cell -- cell' )
  [ [ dup , CHAR: " = [ CHAR: " , ] when ] each ] "" make ; inline

: enclose-in-quotes ( cell -- cell' )
  CHAR: " [ prefix ] [ suffix ] bi ; inline ! "
    
: escape-if-required ( cell -- cell' )
  dup needs-escaping? [ escape-quotes enclose-in-quotes ] when ; inline
    
: write-row ( row -- )
  [ delimiter get write1 ] [ escape-if-required write ] interleave nl ; inline
    
: write-csv ( rows stream -- )
  [ [ write-row ] each ] with-output-stream ;
