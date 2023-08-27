! Copyright (C) 2023 Aleksander Sabak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
kernel math sequences sets splitting strings.parser vectors ;
IN: brain-flak


ERROR: unclosed-brain-flak-expression program ;
ERROR: mismatched-brain-flak-brackets program ;
ERROR: leftover-program-after-compilation program leftover ;


TUPLE: brain-flak
    { active vector }
    { inactive vector }
    { total integer } ;

: <brain-flak> ( seq -- state )
    V{ } [ clone-like ] [ clone ] bi 0 brain-flak boa ;


<PRIVATE

: matches ( a b -- ? )
    { { CHAR: ( CHAR: ) }
      { CHAR: [ CHAR: ] }
      { CHAR: { CHAR: } }
      { CHAR: < CHAR: > }
      { CHAR: ) CHAR: ( }
      { CHAR: ] CHAR: [ }
      { CHAR: } CHAR: { }
      { CHAR: > CHAR: < } } at = ;

: glue ( state n -- state' ) over total>> + >>total ;

: nested-call ( state q: ( s -- s' ) -- previous-total state' )
    [ [ total>> ] [ 0 >>total ] bi ] dip call( s -- s ) ; inline
!   [ [ total>> ] [ 0 >>total ] bi ] dip call ; inline
!   TODO: replace when issue #2807 is resolved
!   https://github.com/factor/factor/issues/2807

: (()) ( state -- state' ) 1 glue ;

: ([]) ( state -- state' ) dup active>> length glue ;

: ({}) ( state -- state' )
    dup active>> [ pop glue ] unless-empty ;

: (<>) ( state -- state' )
    dup [ active>> ] [ inactive>> ] bi
    [ >>inactive ] [ >>active ] bi* ;

: ()) ( state quot: ( state -- state' ) -- state'' )
    nested-call dup [ total>> ] [ active>> ] bi push
    swap glue ; inline

: (]) ( state quot: ( state -- state' ) -- state'' )
    nested-call [ neg ] change-total swap glue ; inline

: (}) ( state quot: ( state -- state' ) -- state'' )
    [ dup active>> { [ empty? ] [ last 0 = ] } 1|| ]
    swap until ; inline

: (>) ( state quot: ( state -- state' ) -- state'' )
    nested-call swap >>total ; inline

: compile-bf-subexpr ( vec string-like -- vec string-like )
    [ { { [ dup empty? ] [ f ] }
        { [ dup first ")]}>" in? ] [ f ] }
        { [ "()" ?head-slice ] [ [ \ (()) suffix! ] dip t ] }
        { [ "[]" ?head-slice ] [ [ \ ([]) suffix! ] dip t ] }
        { [ "{}" ?head-slice ] [ [ \ ({}) suffix! ] dip t ] }
        { [ "<>" ?head-slice ] [ [ \ (<>) suffix! ] dip t ] }
        [ 0 <vector> swap [ rest-slice ] [ first ] bi
            [ compile-bf-subexpr [ [ ] clone-like suffix! ] dip
                [ dup empty?
                    [ dup seq>> unclosed-brain-flak-expression ]
                    [ rest-slice ] if ] [ ?first ] bi ] dip
            over matches
            [ over seq>> mismatched-brain-flak-brackets ] unless
            { { CHAR: ) [ [ \ ()) suffix! ] dip ] }
              { CHAR: ] [ [ \ (]) suffix! ] dip ] }
              { CHAR: } [ [ \ (}) suffix! ] dip ] }
              { CHAR: > [ [ \ (>) suffix! ] dip ] } } case t ]
      } cond ] loop ;

PRIVATE>

: with-brain-flak ( ..A seq q: ( ..A s -- ..B s' ) -- ..B seq' )
    swap [ <brain-flak> swap call active>> ] keep
    clone-like ; inline

: compile-brain-flak ( string -- quote: ( state -- state' ) )
    dup [ "()[]{}<>" in? ] filter
    V{ } clone swap compile-bf-subexpr
    [ nip ] [ swapd leftover-program-after-compilation ]
    if-empty [ ] clone-like ;

SYNTAX: b-f" parse-string compile-brain-flak append! ;
