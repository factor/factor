
USING: kernel combinators math math.parser assocs sequences quotations vars ;

IN: lsys.strings

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lindenmayer string rewriting
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Maybe use an array instead of a quot in the work of segment

VAR: rules

: segment ( str -- seq )
{ { [ dup "" = ] [ drop [ ] ] }
  { [ dup length 1 = ] [ 1quotation ] }
  { [ 1 over nth CHAR: ( = ]
    [ CHAR: ) over index 1 +		! str i
      2dup head				! str i head
      -rot tail				! head tail
      segment swap add* ] }
  { [ t ] [ dup 1 head swap 1 tail segment swap add* ] } }
cond ;

: lookup ( str -- str ) dup 1 head rules> at dup [ nip ] [ drop ] if ;

: rewrite ( str -- str ) segment [ lookup ] map concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: result

: iterate ( -- ) result> rewrite >result ;

: iterations ( n -- ) [ iterate ] times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lindenmayer string interpretation
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: command-table

: segment-command ( seg -- command ) 1 head ;

: segment-parameter ( seg -- parameter )
dup length 1 - 2 swap rot subseq string>number ;

: segment-parts ( seg -- param command )
dup segment-parameter swap segment-command ;

: exec-command ( str -- ) command-table> at dup [ call ] [ drop ] if ;

: exec-command-with-param ( param command -- )
command-table> at dup [ peek 1quotation call ] [ 2drop ] if ;

: (interpret) ( seg -- )
dup length 1 =
[ exec-command ] [ segment-parts exec-command-with-param ] if ;

: interpret ( str -- ) segment [ (interpret) ] each ;
