
USING: kernel sequences quotations assocs math math.parser
       combinators.cleave combinators.lib vars lsys.strings ;

IN: lsys.strings.interpret

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: command-table

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: exec-command ( string -- ) command-table> at >quotation call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: command ( string -- command ) 1 head ;

: parameter ( string -- parameter )
  [ drop 2 ] [ length 1- ] [ ] tri subseq string>number ;

: exec-command* ( string -- )
  [ parameter ] [ command ] bi
  command-table> at dup
  [ 1 tail* call ] [ 3drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (interpret) ( slice -- )
  { { [ empty? ]     [ drop ] }
    { [ has-param? ] [ next+rest* [ exec-command* ] [ (interpret) ] bi* ] }
    { [ t ]          [ next+rest  [ exec-command  ] [ (interpret) ] bi* ] } }
  switch ;

: interpret ( string -- ) <flat-slice> (interpret) ;
