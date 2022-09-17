! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple 
combinators combinators.smart compiler.units debugger effects io
io.streams.string kernel listener locals locals.rewrite
locals.types math math.statistics namespaces quotations
sequences sequences.deep sets skov.basis.code splitting
ui.gadgets.panes vocabs.parser ;

FROM: skov.basis.code => call ;
QUALIFIED: words
QUALIFIED: vocabs
IN: skov.basis.code.execution

: effect ( def -- effect )
    [ introduces [ name>> empty? ] reject ] [ returns ] bi
    [ [ factor-name ] map members >array ] bi@ <effect> ;

: set-ids ( seq -- )
    [ name>> ] collect-by [ 
        [ drop empty? ]
        [ [ "x" <local> >>id ] map 2drop ]
        [ [ <local> ] dip [ id<< ] with each ] smart-if
    ] assoc-each ;

: set-input-ids ( word -- word )
    dup introduces set-ids ;

: set-link-ids ( word -- word )
    dup links set-ids ;

:: process-simple-variadic ( call -- seq )
    call arity 1 - [ call target>> ] replicate ;

:: process-comparison-variadic ( call -- seq )
    call arity 2 = [ call target>> 1array ]
    [ \ dupd call target>> \ -rot 3array
      call arity 3 -
      [ \ dupd suffix call target>> suffix \ swapd suffix \ and suffix \ -rot suffix ] times
      call target>> suffix \ and suffix ] if ;

:: process-sequence-variadic ( call -- seq )
    call arity
    call name>> "1" ?head drop CHAR: n prefix [ search ] with-interactive-vocabs
    2array ;

: process-quotation-call ( call -- seq )
    arity 1 - [ "x" ] replicate "o" 1array <effect> \ call-effect 2array ;

: process-variadic ( call -- word/seq )
    { { [ dup name>> "call" = ] [ process-quotation-call ] }
      { [ dup simple-variadic? ] [ process-simple-variadic ] }
      { [ dup comparison-variadic? ] [ process-comparison-variadic ] }
      { [ dup sequence-variadic? ] [ process-sequence-variadic ] }
      [ target>> ]
    } cond ;

GENERIC: transform ( node -- compiler-node )

:: transform-quotation ( node -- compiler-node )
    node transform node quoted-node?
    [ node own-introduces [ name>> empty? ] filter [ transform ] map
      swap flatten >quotation <lambda> ] when ;

M: introduce transform
    id>> ;

M: text transform
    name>> ;

M: getter transform
    id>> ;

M: setter transform
    [ contents>> [ transform-quotation ] map ] [ id>> <def> ] bi 2array ;

M: call transform
    [ contents>> [ transform-quotation ] map ] [ process-variadic ] bi 2array ;

M: return transform
    contents>> [ transform-quotation ] map ;

M: word transform
    set-input-ids set-link-ids
    [ introduces [ name>> empty? ] reject [ transform ] map members ]
    [ contents>> [ transform-quotation ] map flatten >quotation ] bi <lambda> ;

:: set-recursion ( word lambda -- lambda )
    lambda [ recursion 1array word 1array replace 
    dup [ lambda? ] filter [ word swap set-recursion ] map drop ] change-body ;

:: try-definition ( quot def -- )
    [ def f >>defined? quot with-compilation-unit t >>defined? drop ] try ; inline

: interactive? ( vocab-name -- ? )
    interactive-vocabs get-global member? ;

: add-interactive-vocab ( vocab-name -- )
    [ interactive? not ] 
    [ interactive-vocabs [ swap suffix ] change-global ] smart-when* ;

: remove-interactive-vocab ( vocab-name -- )
    interactive-vocabs [ remove ] change-global ;

GENERIC: define ( def -- )

M:: vocab define ( def -- )
    def path [ vocabs:create-vocab def target<< ] [ add-interactive-vocab ] bi ;

M:: word define ( def -- )
    [ def factor-name
      def path words:create-word dup dup def target<<
      def transform set-recursion rewrite-closures first
      def effect words:define-declared
    ] def try-definition ;

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ]
    [ target>> f pane new-pane dup swapd <pane-stream> [ execute( -- ) ] with-output-stream ]
    [ save-result ] tri ;
