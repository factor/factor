! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii io io.encodings.ascii io.files present kernel strings 
math math.parser unicode.case sequences combinators 
accessors namespaces prettyprint vectors ;

IN: printf 

! FIXME: Handle invalid formats properly.
! FIXME: Handle incomplete formats properly.
! FIXME: Deal only with CHAR rather than converting to { CHAR } ?
! FIXME: Understand intermediate allocations that are happening...

TUPLE: state type pad align width decimals neg loop ;

SYMBOL: current

SYMBOL: args

<PRIVATE

: start-% ( -- )
    state new 
      CHAR: s >>type
      CHAR: \s >>pad
      CHAR: r >>align
      0 >>width
      -1 >>decimals
      f >>neg
      CHAR: % >>loop
    current set ;

: stop-% ( -- ) 
    current off ;

: render ( s -- s )  
    >vector

    current get decimals>> 0 >= current get type>> CHAR: f = and
      [ CHAR: . swap dup rot swap index current get decimals>> + 1 + dup rot swap
        CHAR: 0 pad-right swap 0 swap rot <slice> ] when

    current get align>> CHAR: l = 

        [ current get neg>> [ { CHAR: - } prepend ] when 
          current get width>> CHAR: \s pad-right ]

        [ current get pad>> CHAR: \s = 
            [ current get neg>> [ { CHAR: - } prepend ] when 
              current get width>> current get pad>> pad-left ] 
            [ current get width>> current get neg>> [ 1 - ] when
              current get pad>> pad-left
              current get neg>> [ { CHAR: - } prepend ] when ] if
        ] if 

    current get decimals>> 0 >= current get type>> CHAR: f = not and
      [ current get align>> CHAR: l =
          [ current get decimals>> CHAR: \s pad-right ]
          [ current get decimals>> current get pad>> pad-left ] if
        current get decimals>> head-slice ] when
    >string ;

: loop-% ( c -- s ) 
    current get swap
    {
      { CHAR: % [ drop stop-% "%" ] }
      { CHAR: ' [ CHAR: ' >>loop drop "" ] }
      { CHAR: . [ CHAR: . >>loop 0 >>decimals drop "" ] }
      { CHAR: - [ CHAR: l >>align drop "" ] }
      { CHAR: 0 [ dup width>> 0 = [ CHAR: 0 >>pad ] when 
                  [ 10 * 0 + ] change-width drop "" ] } 
      { CHAR: 1 [ [ 10 * 1 + ] change-width drop "" ] } 
      { CHAR: 2 [ [ 10 * 2 + ] change-width drop "" ] } 
      { CHAR: 3 [ [ 10 * 3 + ] change-width drop "" ] } 
      { CHAR: 4 [ [ 10 * 4 + ] change-width drop "" ] } 
      { CHAR: 5 [ [ 10 * 5 + ] change-width drop "" ] } 
      { CHAR: 6 [ [ 10 * 6 + ] change-width drop "" ] } 
      { CHAR: 7 [ [ 10 * 7 + ] change-width drop "" ] } 
      { CHAR: 8 [ [ 10 * 8 + ] change-width drop "" ] } 
      { CHAR: 9 [ [ 10 * 9 + ] change-width drop "" ] } 
      { CHAR: d [ CHAR: d >>type drop
                  args get pop >fixnum 
                  dup 0 < [ current get t >>neg drop ] when 
                  abs present render stop-% ] }
      { CHAR: f [ CHAR: f >>type drop
                  args get pop >float 
                  dup 0 < [ current get t >>neg drop ] when 
                  abs present render stop-% ] }
      { CHAR: s [ CHAR: s >>type drop 
                  args get pop present render stop-% ] }
      { CHAR: c [ CHAR: c >>type 1 >>width drop 
                  1 args get pop <string> stop-% ] }
      { CHAR: x [ CHAR: x >>type drop 
                  args get pop >hex present render stop-% ] }
      { CHAR: X [ CHAR: X >>type drop 
                  args get pop >hex present >upper render stop-% ] }
      [ drop drop stop-% "" ]
    } case ;

: loop-. ( c -- s )
    dup digit? current get swap
      [ swap CHAR: 0 - swap [ 10 * + ] change-decimals drop "" ] 
      [ CHAR: % >>loop drop loop-% ] if ;

: loop-' ( c -- s ) 
    current get swap >>pad CHAR: % >>loop drop "" ;

: loop- ( c -- s )
    dup CHAR: % = [ drop start-% "" ] [ 1 swap <string> ] if ;

: loop ( c -- s ) 
   current get 
     [ current get loop>> 
       { 
         { CHAR: % [ loop-% ] }
         { CHAR: ' [ loop-' ] }
         { CHAR: . [ loop-. ] }
         [ drop stop-% loop- ]              ! FIXME: RAISE ERROR
       } case ] 
     [ loop- ] if ;

PRIVATE>

: sprintf ( fmt args -- str ) 
    [ >vector reverse args set
      V{ } swap [ loop append ] each >string ] with-scope ;

: printf ( fmt args -- ) 
    sprintf print ;

: fprintf ( path fmt args -- ) 
    rot ascii [ sprintf write flush ] with-file-appender ;


