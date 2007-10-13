
USING: kernel sbufs strings sequences assocs math
       combinators.lib vars lsys.strings ;

IN: lsys.strings.rewrite

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: rules

: lookup ( str -- str ) [ 1 head rules> at ] [ ] bi or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: accum

: push-next ( next -- ) lookup accum> push-all ;

: (rewrite) ( slice -- )
  { { [ empty? ]     [ drop ] }
    { [ has-param? ] [ next+rest* [ push-next ] [ (rewrite) ] bi* ] }
    { [ t ]	     [ next+rest  [ push-next ] [ (rewrite) ] bi* ] } }
  switch ;

: rewrite ( string -- string )
  dup length 10 * <sbuf> >accum
  <flat-slice> (rewrite)
  accum> >string ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: result

: iterate ( -- ) result> rewrite >result ;

: iterations ( n -- ) [ iterate ] times ;
