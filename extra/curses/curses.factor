! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings assocs byte-arrays
combinators continuations destructors fry io.encodings.8-bit
io io.encodings.string io.encodings.utf8 kernel locals math
namespaces prettyprint sequences classes.struct
strings threads curses.ffi ;
IN: curses

SYMBOL: curses-windows
SYMBOL: current-window

CONSTANT: ERR -1
CONSTANT: FALSE 0
CONSTANT: TRUE 1
: >BOOLEAN ( n -- TRUE/FALSE ) >boolean TRUE FALSE ? ; inline

ERROR: duplicate-window window ;
ERROR: unnamed-window window ;
ERROR: window-not-found window ;
ERROR: curses-failed ;

: get-window ( string -- window )
    dup curses-windows get at*
    [ nip ] [ drop window-not-found ] if ;

: window-ptr ( string -- window ) get-window ptr>> ;

: curses-error ( n -- ) ERR = [ curses-failed ] when ;

: with-curses ( quot -- )
    H{ } clone curses-windows [
        initscr curses-error
        [
            curses-windows get values [ dispose ] each
            nocbreak curses-error
            echo curses-error
            endwin curses-error
        ] [ ] cleanup
    ] with-variable ; inline

: with-window ( name quot -- )
    [ window-ptr current-window ] dip with-variable ; inline

TUPLE: curses-window
    name
    parent-name
    ptr
    { lines integer initial: 0 }
    { columns integer initial: 0 }
    { y integer initial: 0 }
    { x integer initial: 0 }

    { cbreak initial: t }
    { echo initial: t }
    { raw initial: f }

    { scrollok initial: t }
    { leaveok initial: f }

    idcok idlok immedok
    { keypad initial: f } ;

M: curses-window dispose ( window -- )
    ptr>> delwin curses-error ;

<PRIVATE

: add-window ( window -- )
    dup name>> [ unnamed-window ] unless*
    curses-windows get 2dup key?
    [ duplicate-window ] [ set-at ] if ;

: delete-window ( window -- )
    curses-windows get 2dup key?
    [ delete-at ] [ drop window-not-found ] if ;

: window-params ( window -- lines columns y x )
    { [ lines>> ] [ columns>> ] [ y>> ] [ x>> ] } cleave ;

: setup-window ( window -- )
    {
        [
            dup
            dup parent-name>> [
                window-ptr swap window-params derwin
            ] [
                window-params newwin
            ] if* [ curses-error ] keep >>ptr drop
        ]
        [ cbreak>> [ cbreak ] [ nocbreak ] if curses-error ]
        [ echo>> [ echo ] [ noecho ] if curses-error ]
        [ raw>> [ raw ] [ noraw ] if curses-error ]
        [ [ ptr>> ] [ scrollok>> >BOOLEAN ] bi scrollok curses-error ]
        [ [ ptr>> ] [ leaveok>> >BOOLEAN ] bi leaveok curses-error ]
        [ [ ptr>> ] [ keypad>> >BOOLEAN ] bi keypad curses-error ]
        [ add-window ]
    } cleave ;

PRIVATE>

: add-curses-window ( window -- )
    [ setup-window ] [ ] [ dispose ] cleanup ;

: (curses-window-refresh) ( window-ptr -- ) wrefresh curses-error ;
: wnrefresh ( window -- ) window-ptr (curses-window-refresh) ;
: curses-refresh ( -- ) current-window get (curses-window-refresh) ;

: (curses-wprint) ( window-ptr string -- )
    waddstr curses-error ;

: curses-nwrite ( window string -- )
    [ window-ptr ] dip (curses-wprint) ;

: curses-wprint ( window string -- )
    [ window-ptr dup ] dip (curses-wprint) "\n" (curses-wprint) ;

: curses-printf ( window string -- )
    [ window-ptr dup dup ] dip (curses-wprint)
    "\n" (curses-wprint)
    (curses-window-refresh) ;

: curses-writef ( window string -- )
    [ window-ptr dup ] dip (curses-wprint) (curses-window-refresh) ;

:: (curses-read) ( window-ptr n encoding -- string )
    n <byte-array> :> buf
    window-ptr buf n wgetnstr curses-error
    buf encoding alien>string ;

: curses-read ( window n -- string )
    utf8 [ window-ptr ] 2dip (curses-read) ;

: curses-erase ( window -- ) window-ptr werase curses-error ;

: move-cursor ( window-name y x -- )
    [
        window-ptr c-window memory>struct
        {
            [ ]
            [ (curses-window-refresh) ]
            [ _curx>> ]
            [ _cury>> ]
        } cleave
    ] 2dip mvcur curses-error (curses-window-refresh) ;

: delete-line ( window-name y -- )
    [ window-ptr dup ] dip
    0 wmove curses-error wdeleteln curses-error ;

: insert-blank-line ( window-name y -- )
    [ window-ptr dup ] dip
    0 wmove curses-error winsertln curses-error ;

: insert-line ( window-name y string -- )
    [ dupd insert-blank-line ] dip
    curses-writef ;
