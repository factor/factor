! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple combinators
combinators.short-circuit compiler.units continuations
formatting io kernel lexer lists math multiline namespaces
parser prettyprint quotations sequences sequences.deep
sequences.generalizations sets splitting strings vectors words
words.symbol ;

IN: logic

SYMBOL: !!    ! cut operator         in prolog: !
SYMBOL: __    ! anonymous variable   in prolog: _
SYMBOL: ;;    ! disjunction, or      in prolog: ;
SYMBOL: \+    ! negation             in prolog: not, \+

<PRIVATE

<<
TUPLE: logic-pred name defs ;

: <pred> ( name -- pred )
    logic-pred new
        swap >>name
        V{ } clone >>defs ;

MIXIN: LOGIC-VAR
SINGLETON: NORMAL-LOGIC-VAR
SINGLETON: ANONYMOUSE-LOGIC-VAR
INSTANCE: NORMAL-LOGIC-VAR LOGIC-VAR
INSTANCE: ANONYMOUSE-LOGIC-VAR LOGIC-VAR

: logic-var? ( obj -- ? )
    dup symbol? [ get LOGIC-VAR? ] [ drop f ] if ; inline

SYMBOLS: *trace?* *trace-depth* ;

: define-logic-var ( name -- )
    create-word-in
    [ reset-generic ]
    [ define-symbol ]
    [ NORMAL-LOGIC-VAR swap set-global ] tri ;

: define-logic-pred ( name -- )
    create-word-in
    [ reset-generic ]
    [ define-symbol ]
    [ [ name>> <pred> ] keep set-global ] tri ;

PRIVATE>

: trace ( -- ) t *trace?* set-global ;

: notrace ( -- ) f *trace?* set-global ;

SYNTAX: LOGIC-VAR: scan-token define-logic-var ;

SYNTAX: LOGIC-VARS: ";" [ define-logic-var ] each-token ;

SYNTAX: LOGIC-PRED: scan-token define-logic-pred ;

SYNTAX: LOGIC-PREDS: ";" [ define-logic-pred ] each-token ;
>>

SYNTAX: %!
  "!%" parse-multiline-string drop ;

<PRIVATE

TUPLE: logic-goal pred args ;

: called-args ( args -- args' )
    [ dup callable? [ call( -- term ) ] when ] map ; inline

:: <goal> ( pred args -- goal )
    pred get args called-args logic-goal boa ; inline

: def>goal ( goal-def -- goal ) unclip swap <goal> ;

: normalize ( goal-def/defs -- goal-defs )
    dup {
        [ !! = ]
        [ ?first dup symbol? [ get logic-pred? ] [ drop f ] if ]
    } 1|| [ 1array ] when ;

TUPLE: logic-env table ;

: <env> ( -- env ) logic-env new H{ } clone >>table ; inline

:: env-put ( x pair env -- ) pair x env table>> set-at ; inline

: env-get ( x env -- pair/f ) table>> at ; inline

: env-delete ( x env -- ) table>> delete-at ; inline

: env-clear ( env -- ) table>> clear-assoc ; inline

: dereference ( term env -- term' env' )
    [ 2dup env-get [ 2nip first2 t ] [ f ] if* ] loop ; inline

PRIVATE>

M: logic-env at*
    dereference {
        { [ over logic-goal? ] [
            [ [ pred>> ] [ args>> ] bi ] dip at <goal> t ] }
        { [ over tuple? ] [
            '[ tuple-slots [ _ at ] map ]
            [ class-of slots>tuple ] bi t ] }
        { [ over sequence? ] [
              '[ _ at ] map t ] }
        [ drop t ]
    } cond ; inline

<PRIVATE

TUPLE: callback-env env trail ;

C: <callback-env> callback-env inline

M: callback-env at* env>> at* ; inline

TUPLE: cut-info cut? ;

C: <cut> cut-info inline

: cut? ( cut-info -- ? ) cut?>> ; inline

: set-info ( ? cut-info -- ) cut?<< ; inline

: set-info-if-f ( ? cut-info -- )
    dup cut?>> [ 2drop ] [ cut?<< ] if ; inline

: 2each-until ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... all-failed? ) 2 nfind 2drop f = ; inline

DEFER: unify*

:: (unify*) ( x! x-env! y! y-env! trail tmp-env -- success? )
    f :> ret-value!  f :> ret?!  f :> ret2?!
    [
        {
            { [ x logic-var? ] [
                  x x-env env-get :> xp
                  xp [
                      xp first2 x-env! x!
                      x x-env dereference x-env! x!
                      t
                  ] [
                      y y-env dereference y-env! y!
                      x y = x-env y-env eq? and [
                          x { y y-env } x-env env-put
                          x-env tmp-env eq? [
                              { x x-env } trail push
                          ] unless
                      ] unless
                      t ret?!  t ret-value!
                      f
                  ] if ] }
            { [ y logic-var? ] [
                  x y x! y!  x-env y-env x-env! y-env!
                  t ] }
            [ f ]
        } cond
    ] loop
    ret? [
        t ret-value!
        x y [ logic-goal? ] both? [
            x pred>> y pred>> = [
                x args>> x!  y args>> y!
            ] [
                f ret-value!  t ret2?!
            ] if
        ] when
        ret2? [
            {
                { [ x y [ tuple? ] both? ] [
                      x y [ class-of ] same? [
                          x y [ tuple-slots ] bi@ [| x-item y-item |
                              x-item x-env y-item y-env trail tmp-env unify* not
                          ] 2each-until
                      ] [ f ] if ret-value! ] }
                { [ x y [ sequence? ] both? ] [
                      x y [ class-of ] same? x y [ length ] same? and [
                          x y [| x-item y-item |
                              x-item x-env y-item y-env trail tmp-env unify* not
                          ] 2each-until
                      ] [ f ] if ret-value! ] }
                [ x y = ret-value! ]
            } cond
        ] unless
    ] unless
    ret-value ;

:: unify* ( x x-env y y-env trail tmp-env -- success? )
    *trace?* get-global :> trace?
    0 :> depth!
    trace? [
        *trace-depth* counter depth!
        depth [ "\t" printf ] times
        "Unification of " printf x-env x of pprint
        " and " printf y pprint nl
    ] when
    x x-env y y-env trail tmp-env (unify*) :> success?
    trace? [
        depth [ "\t" printf ] times
        success? [ "==> Success\n" ] [ "==> Fail\n" ] if "%s\n" printf
        *trace-depth* get-global 1 - *trace-depth* set-global
    ] when
    success? ; inline

SYMBOLS:
    s-start:
    s-not-empty:
    s-cut: s-cut/iter:
    s-not-cut:
    s-defs-loop:
    s-callable: s-callable/iter:
    s-not-callable: s-not-callable/outer-iter: s-not-callable/inner-iter:
    s-unify?-exit:
    s-defs-loop-end:
    s-end: ;

TUPLE: resolver-gen
    { state initial: s-start: }
    body env cut
    first-goal rest-goals d-head d-body defs trail d-env d-cut
    sub-resolver1 sub-resolver2 i loop-end
    yield? return? ;

:: <resolver> ( body env cut -- resolver )
    resolver-gen new
        body >>body env >>env cut >>cut ; inline

GENERIC: next ( generator -- yield? )

M:: resolver-gen next ( resolver -- yield? )
    [
        f resolver return?<<
        f resolver yield?<<
        resolver state>> {
            { s-start: [
                  resolver body>> empty? [
                      t resolver yield?<<
                      s-end: resolver state<<
                  ] [
                      s-not-empty: resolver state<<
                  ] if ] }
            { s-not-empty: [
                  resolver body>> unclip
                  [ resolver rest-goals<< ] [ resolver first-goal<< ] bi*
                  resolver first-goal>> !! = [  ! cut
                      s-cut: resolver state<<
                  ] [
                      s-not-cut: resolver state<<
                  ] if ] }
            { s-cut: [
                  resolver [ rest-goals>> ] [ env>> ] [ cut>> ] tri <resolver>
                  resolver sub-resolver1<<
                  s-cut/iter: resolver state<< ] }
            { s-cut/iter: [
                  resolver sub-resolver1>> next [
                      t resolver yield?<<
                  ] [
                      t resolver cut>> set-info
                      s-end: resolver state<<
                  ] if ] }
            { s-not-cut: [
                  resolver first-goal>> callable? [
                      resolver first-goal>> call( -- goal ) resolver first-goal<<
                  ] when
                  *trace?* get-global [
                      resolver first-goal>>
                      [ pred>> name>> "in: { %s " printf ]
                      [ args>> [ "%u " printf ] each "}\n" printf ] bi
                  ] when
                  <env> resolver d-env<<
                  f <cut> resolver d-cut<<
                  resolver first-goal>> pred>> defs>> dup resolver defs<<
                  length 1 - dup 0 >= [
                      resolver loop-end<<
                      0 resolver i<<
                      s-defs-loop: resolver state<<
                  ] [
                      drop
                      s-end: resolver state<<
                  ] if ] }
            { s-defs-loop: [
                  resolver [ i>> ] [ defs>> ] bi nth
                  first2 [ resolver d-head<< ] [ resolver d-body<< ] bi*
                  resolver d-cut>> cut? resolver cut>> cut? or [
                      s-end: resolver state<<
                  ] [
                      V{ } clone resolver trail<<
                      resolver {
                          [ first-goal>> ]
                          [ env>> ]
                          [ d-head>> ]
                          [ d-env>> ]
                          [ trail>> ]
                          [ d-env>> ]
                      } cleave unify* [
                          resolver d-body>> callable? [
                              s-callable: resolver state<<
                          ] [
                              s-not-callable: resolver state<<
                          ] if
                      ] [
                          s-unify?-exit: resolver state<<
                      ] if
                  ] if ] }
            { s-callable: [
                  resolver [ d-env>> ] [ trail>> ] bi <callback-env>
                  resolver d-body>> call( cb-env -- ? ) [
                      resolver [ rest-goals>> ] [ env>> ] [ cut>> ] tri <resolver>
                      resolver sub-resolver1<<
                      s-callable/iter: resolver state<<
                  ] [
                      s-unify?-exit: resolver state<<
                  ] if ] }
            { s-callable/iter: [
                  resolver sub-resolver1>> next [
                      t resolver yield?<<
                  ] [
                      s-unify?-exit: resolver state<<
                  ] if ] }
            { s-not-callable: [
                  resolver [ d-body>> ] [ d-env>> ] [ d-cut>> ] tri <resolver>
                  resolver sub-resolver1<<
                  s-not-callable/outer-iter: resolver state<< ] }
            { s-not-callable/outer-iter: [
                  resolver sub-resolver1>> next [
                      resolver [ rest-goals>> ] [ env>> ] [ cut>> ] tri <resolver>
                      resolver sub-resolver2<<
                      s-not-callable/inner-iter: resolver state<<
                  ] [
                      s-unify?-exit: resolver state<<
                  ] if ] }
            { s-not-callable/inner-iter: [
                  resolver sub-resolver2>> next [
                      t resolver yield?<<
                  ] [
                      resolver cut>> cut? resolver d-cut>> set-info-if-f
                      s-not-callable/outer-iter: resolver state<<
                  ] if ] }
            { s-unify?-exit: [
                  resolver trail>> [ first2 env-delete ] each
                  resolver d-env>> env-clear
                  s-defs-loop-end: resolver state<< ] }
            { s-defs-loop-end: [
                  resolver [ i>> ] [ loop-end>> ] bi >= [
                      s-end: resolver state<<
                  ] [
                      resolver [ 1 + ] change-i drop
                      s-defs-loop: resolver state<<
                  ] if ] }
            { s-end: [
                  t resolver return?<< ] }
        } case
        resolver [ yield?>> ] [ return?>> ] bi or not
    ] loop
    resolver yield?>> ;

: split-body ( body -- bodies ) { ;; } split [ >array ] map ;

SYMBOL: *anonymouse-var-no*

: reset-anonymouse-var-no ( -- ) 0 *anonymouse-var-no* set-global ;

: proxy-var-for-'__' ( -- var-symbol )
    [
        *anonymouse-var-no* counter "ANON-%d_" sprintf
        "logic.private" create-word dup dup
        define-symbol
        ANONYMOUSE-LOGIC-VAR swap set-global
    ] with-compilation-unit ;

: replace-'__' ( before -- after )
    {
        { [ dup __ = ] [ drop proxy-var-for-'__' ] }
        { [ dup sequence? ] [ [ replace-'__' ] map ] }
        { [ dup tuple? ] [
            [ tuple-slots [ replace-'__' ] map ]
            [ class-of slots>tuple ] bi ] }
        [ ]
    } cond ;

: collect-logic-vars ( seq -- vars-array )
    [ logic-var? ] deep-filter members ;

SYMBOL: dummy-item

:: negation-goal ( goal -- negation-goal )
    "failo_" <pred> :> f-pred
    f-pred { } clone logic-goal boa :> f-goal
    V{ { f-goal [ drop f ] } } f-pred defs<<
    goal pred>> name>> "\\+%s_" sprintf <pred> :> negation-pred
    negation-pred goal args>> clone logic-goal boa :> negation-goal
    V{
        { negation-goal { goal !! f-goal } } ! \+P_ { P !! { failo_ } } rule
        { negation-goal { } }                ! \+P_ fact
    } negation-pred defs<<
    negation-goal ;

SYMBOLS: at-the-beginning at-the-end ;

:: (rule) ( head body pos -- )
    reset-anonymouse-var-no
    head replace-'__' def>goal :> head-goal
    body replace-'__' normalize
    split-body pos at-the-beginning = [ reverse ] when  ! disjunction
    dup empty? [
        head-goal swap 2array 1vector
        head-goal pred>> [
            pos at-the-end = [ swap ] when append!
        ] change-defs drop
    ] [
        f :> negation?!
        [
            [
                {
                    { [ dup \+ = ] [ drop dummy-item t negation?! ] }
                    { [ dup array? ] [
                          def>goal negation? [ negation-goal ] when
                          f negation?! ] }
                    { [ dup callable? ] [
                          call( -- goal ) negation? [ negation-goal ] when
                          f negation?! ] }
                    { [ dup [ t = ] [ f = ] bi or ] [
                          :> t/f! negation? [ t/f not t/f! ] when
                          t/f "trueo_" "failo_" ? <pred> :> t/f-pred
                          t/f-pred { } clone logic-goal boa :> t/f-goal
                          V{ { t/f-goal [ drop t/f ] } } t/f-pred defs<<
                          t/f-goal
                          f negation?! ] }
                    { [ dup !! = ] [ f negation?! ] }  ! as '!!'
                    [ drop dummy-item f negation?! ]
                } cond
            ] map dummy-item swap remove :> body-goals
            V{ { head-goal body-goals } }
            head-goal pred>> [
                pos at-the-end = [ swap ] when append!
            ] change-defs drop
        ] each
    ] if ;

: (fact) ( head pos -- ) { } clone swap (rule) ;

PRIVATE>

: rule ( head body -- ) at-the-end (rule) ;

: rule* ( head body -- ) at-the-beginning (rule) ;

: rules ( defs -- ) [ first2 rule ] each ;

: fact ( head -- ) at-the-end (fact) ;

: fact* ( head -- ) at-the-beginning (fact) ;

: facts ( defs -- ) [ fact ] each ;

:: callback ( head quot: ( callback-env -- ? ) -- )
    head def>goal :> head-goal
    head-goal pred>> [
        { head-goal quot } suffix!
    ] change-defs drop ;

: callbacks ( defs -- ) [ first2 callback ] each ; inline

:: retract ( head-def -- )
    head-def replace-'__' def>goal :> head-goal
    head-goal pred>> defs>> :> defs
    defs [ first <env> head-goal <env> V{ } clone <env> (unify*) ] find [
        head-goal pred>> [ remove-nth! ] change-defs drop
    ] [ drop ] if ;

:: retract-all ( head-def -- )
    head-def replace-'__' def>goal :> head-goal
    head-goal pred>> defs>> :> defs
    defs [
        first <env> head-goal <env> V{ } clone <env> (unify*)
    ] reject! head-goal pred>> defs<< ;

: clear-pred ( pred -- ) get V{ } clone swap defs<< ;

:: unify ( cb-env x y -- success? )
    cb-env env>> :> env
    x env y env cb-env trail>> env (unify*) ;

:: is ( quot: ( env -- value ) dist -- goal )
    quot collect-logic-vars
    dup dist swap member? [ dist suffix ] unless :> args
    quot dist "[ %u %s is ]" sprintf <pred> :> is-pred
    is-pred args logic-goal boa :> is-goal
    V{
        {
            is-goal
            [| env | env dist env quot call( env -- value ) unify ]
        }
    } is-pred defs<<
    is-goal ;

:: =:= ( quot: ( env -- n m ) -- goal )
    quot collect-logic-vars :> args
    quot "[ %u =:= ]" sprintf <pred> :> =:=-pred
    =:=-pred args logic-goal boa :> =:=-goal
    V{
        {
            =:=-goal
            [| env |
                env quot call( env -- n m )
                2dup [ number? ] both? [ = ] [ 2drop f ] if ]
        }
    } =:=-pred defs<<
    =:=-goal ;

:: =\= ( quot: ( env -- n m ) -- goal )
    quot collect-logic-vars :> args
    quot "[ %u =\\= ]" sprintf <pred> :> =\=-pred
    =\=-pred args logic-goal boa :> =\=-goal
    V{
        {
            =\=-goal
            [| env |
                env quot call( env -- n m )
                2dup [ number? ] both? [ = not ] [ 2drop f ] if ]
        }
    } =\=-pred defs<<
    =\=-goal ;

:: invoke ( quot: ( env -- ) -- goal )
    quot collect-logic-vars :> args
    quot "[ %u invoke ]" sprintf <pred> :> invoke-pred
    invoke-pred args logic-goal boa :> invoke-goal
    V{
        { invoke-goal [| env | env quot call( env -- ) t ] }
    } invoke-pred defs<<
    invoke-goal ;

:: invoke* ( quot: ( env -- ? ) -- goal )
    quot collect-logic-vars :> args
    quot "[ %u invoke* ]" sprintf <pred> :> invoke*-pred
    invoke*-pred args logic-goal boa :> invoke*-goal
    V{
        { invoke*-goal [| env | env quot call( env -- ? ) ] }
    } invoke*-pred defs<<
    invoke*-goal ;

:: nquery ( goal-def/defs n/f -- bindings-array/success? )
    *trace?* get-global :> trace?
    0 :> n!
    f :> success?!
    V{ } clone :> bindings
    <env> :> env
    goal-def/defs replace-'__' normalize [ def>goal ] map
    env f <cut>
    <resolver> :> resolver
    [
        [
            resolver next dup [
                resolver env>> table>> keys [ get NORMAL-LOGIC-VAR? ] filter
                [ dup env at ] H{ } map>assoc
                trace? get-global [ dup [ "%u: %u\n" printf ] assoc-each ] when
                bindings push
                t success?!
                n/f [
                    n 1 + n!
                    n n/f >= [ return ] when
                ] when
            ] when
        ] loop
    ] with-return
    bindings dup {
        [ empty? ]
        [ first keys empty? ]
    } 1|| [ drop success? ] [ >array ] if ;

: query ( goal-def/defs -- bindings-array/success? ) f nquery ;

! nquery has been modified to use generators created by finite
! state machines to reduce stack consumption.
! Since the processing algorithm of the code is difficult
! to understand, the words no longer used are kept as private
! words for verification.

<PRIVATE

: each-until ( ... seq quot: ( ... elt -- ... ? ) -- ... ) find 2drop ; inline

:: resolve-body ( body env cut quot: ( -- ) -- )
    body empty? [
        quot call( -- )
    ] [
        body unclip :> ( rest-goals! first-goal! )
        first-goal !! = [  ! cut
            rest-goals env cut quot resolve-body
            t cut set-info
        ] [
            first-goal callable? [
                first-goal call( -- goal ) first-goal!
            ] when
            *trace?* get-global [
                first-goal
                [ pred>> name>> "in: { %s " printf ]
                [ args>> [ "%u " printf ] each "}\n" printf ] bi
            ] when
            <env> :> d-env!
            f <cut> :> d-cut!
            first-goal pred>> defs>> [
                first2 :> ( d-head d-body )
                first-goal d-head [ args>> length ] same? [
                    d-cut cut? cut cut? or [ t ] [
                        V{ } clone :> trail
                        first-goal env d-head d-env trail d-env unify* [
                            d-body callable? [
                                d-env trail <callback-env> d-body call( cb-env -- ? ) [
                                    rest-goals env cut quot resolve-body
                                ] when
                            ] [
                                d-body d-env d-cut [
                                    rest-goals env cut quot resolve-body
                                    cut cut? d-cut set-info-if-f
                                ] resolve-body
                            ] if
                        ] when
                        trail [ first2 env-delete ] each
                        d-env env-clear
                        f
                    ] if
                ] [ f ] if
            ] each-until
        ] if
    ] if ;

:: (resolve) ( goal-def/defs quot: ( env -- ) -- )
    goal-def/defs replace-'__' normalize [ def>goal ] map :> goals
    <env> :> env
    goals env f <cut> [ env quot call( env -- ) ] resolve-body ;

: resolve ( goal-def/defs quot: ( env -- ) -- ) (resolve) ;

:: nquery/rec ( goal-def/defs n/f -- bindings-array/success? )
    *trace?* get-global :> trace?
    0 :> n!
    f :> success?!
    V{ } clone :> bindings
    [
        goal-def/defs normalize [| env |
            env table>> keys [ get NORMAL-LOGIC-VAR? ] filter
            [ dup env at ] H{ } map>assoc
            trace? get-global [ dup [ "%u: %u\n" printf ] assoc-each ] when
            bindings push
            t success?!
            n/f [
                n 1 + n!
                n n/f >= [ return ] when
            ] when
        ] (resolve)
    ] with-return
    bindings dup {
        [ empty? ]
        [ first keys empty? ]
    } 1|| [ drop success? ] [ >array ] if ;

: query/rec ( goal-def/defs -- bindings-array/success? )
    f nquery/rec ;

PRIVATE>

! Built-in predicate definitions -----------------------------------------------------

LOGIC-PREDS:
    trueo failo
    varo nonvaro
    (<) (>) (>=) (=<) (==) (\==) (=) (\=)
    writeo writenlo nlo
    membero appendo lengtho listo ;

{ trueo } [ drop t ] callback

{ failo } [ drop f ] callback


<PRIVATE LOGIC-VARS: X Y Z ; PRIVATE>

{ varo X } [ X of logic-var? ] callback

{ nonvaro X } [ X of logic-var? not ] callback


{ (<) X Y } [
    [ X of ] [ Y of ] bi 2dup [ number? ] both? [ < ] [ 2drop f ] if
] callback

{ (>) X Y } [
    [ X of ] [ Y of ] bi 2dup [ number? ] both? [ > ] [ 2drop f ] if
] callback

{ (>=) X Y } [
    [ X of ] [ Y of ] bi 2dup [ number? ] both? [ >= ] [ 2drop f ] if
] callback

{ (=<) X Y } [
    [ X of ] [ Y of ] bi 2dup [ number? ] both? [ <= ] [ 2drop f ] if
] callback

{ (==) X Y } [ [ X of ] [ Y of ] bi = ] callback

{ (\==) X Y } [ [ X of ] [ Y of ] bi = not ] callback

{ (=) X Y } [ dup [ X of ] [ Y of ] bi unify ] callback

{ (\=) X Y } [
    clone [ clone ] change-env [ clone ] change-trail
    dup [ X of ] [ Y of ] bi unify not
] callback


{ writeo X } [
    X of dup sequence? [
        [ dup string? [ printf ] [ pprint ] if ] each
    ] [
        dup string? [ printf ] [ pprint ] if
    ] if t
] callback

{ writenlo X } [
    X of dup sequence? [
        [ dup string? [ printf ] [ pprint ] if ] each
    ] [
        dup string? [ printf ] [ pprint ] if
    ] if nl t
] callback

{ nlo } [ drop nl t ] callback


<PRIVATE LOGIC-VARS: L L1 L2 L3 Head Tail N N1 ; PRIVATE>

{ membero X L{ X . Tail } } fact
{ membero X L{ Head . Tail } } { membero X Tail } rule

{ appendo L{ } L L } fact
{ appendo L{ X . L1 } L2 L{ X . L3 } } {
    { appendo L1 L2 L3 }
} rule

{ lengtho L{ } 0 } fact
{ lengtho L{ __ . Tail } N } {
    { lengtho Tail N1 }
    [ [ N1 of 1 + ] N is ]
} rule

{ listo L{ } } fact
{ listo L{ __ . __ } } fact
