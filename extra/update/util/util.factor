
USING: kernel classes strings quotations words math math.parser arrays
       combinators.smart
       accessors
       system prettyprint splitting
       sequences combinators sequences.deep
       io
       io.launcher
       io.encodings.utf8
       calendar
       calendar.format ;

IN: update.util

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: to-strings

: to-string ( obj -- str )
  dup class
    {
      { \ string    [ ] }
      { \ quotation [ call( -- string ) ] }
      { \ word      [ execute( -- string ) ] }
      { \ fixnum    [ number>string ] }
      { \ array     [ to-strings concat ] }
    }
  case ;

: to-strings ( seq -- str )
  dup [ string? ] all?
    [ ]
    [ [ to-string ] map flatten ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cpu- ( -- cpu ) cpu unparse "." split "-" join ;

: platform ( -- string ) { [ os unparse ] cpu- } to-strings "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: branch-name ( -- string ) "clean-" platform append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gnu-make ( -- string )
  os { freebsd openbsd netbsd } member? [ "gmake" ] [ "make" ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-id ( -- id )
  { "git" "show" } utf8 <process-reader> [ readln ] with-input-stream
  " " split second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: datestamp ( -- string )
  now
  [ { [ year>> ] [ month>> ] [ day>> ] [ hour>> ] [ minute>> ] } cleave ] output>array
  [ pad-00 ] map "-" join ;
