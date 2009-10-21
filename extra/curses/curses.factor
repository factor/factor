! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings assocs byte-arrays
classes.struct combinators continuations destructors
fry io io.encodings.8-bit io.encodings.string io.encodings.utf8
io.streams.c kernel libc locals math memoize multiline
namespaces prettyprint sequences strings threads ;
IN: curses

QUALIFIED-WITH: curses.ffi ffi

SYMBOL: current-window

CONSTANT: COLOR_BLACK 0
CONSTANT: COLOR_RED   1
CONSTANT: COLOR_GREEN 2
CONSTANT: COLOR_YELLO 3
CONSTANT: COLOR_BLUE  4
CONSTANT: COLOR_MAGEN 5
CONSTANT: COLOR_CYAN  6
CONSTANT: COLOR_WHITE 7

ERROR: curses-failed ;
ERROR: unsupported-curses-terminal ;

<PRIVATE

: >BOOLEAN ( ? -- TRUE/FALSE ) ffi:TRUE ffi:FALSE ? ; inline

: curses-pointer-error ( ptr/f -- ptr )
    dup [ curses-failed ] unless ; inline
: curses-error ( n -- ) ffi:ERR = [ curses-failed ] when ;

PRIVATE>

: curses-ok? ( -- ? )
    { 0 1 2 } [ isatty 0 = not ] all? ;

TUPLE: curses-window < disposable
    ptr
    parent-window
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
    { keypad initial: t }

    { encoding initial: utf8 } ;

: <curses-window> ( -- window )
    curses-window new-disposable ;

M: curses-window dispose* ( window -- )
    ptr>> ffi:delwin curses-error ;

<PRIVATE

: window-params ( window -- lines columns y x )
    { [ lines>> ] [ columns>> ] [ y>> ] [ x>> ] } cleave ;

: set-cbreak/raw ( cbreak raw -- )
    [ drop ffi:raw ] [
        [ ffi:cbreak ] [ ffi:nocbreak ] if
    ] if curses-error ;

: apply-options ( window -- )
    {
        [ [ cbreak>> ] [ raw>> ] bi set-cbreak/raw ]
        [ echo>> [ ffi:echo ] [ ffi:noecho ] if curses-error ]
        [ [ ptr>> ] [ scrollok>> >BOOLEAN ] bi ffi:scrollok curses-error ]
        [ [ ptr>> ] [ leaveok>> >BOOLEAN ] bi ffi:leaveok curses-error ]
        [ [ ptr>> ] [ keypad>> >BOOLEAN ] bi ffi:keypad curses-error ]
    } cleave ;

SYMBOL: n-registered-colors

MEMO: register-color ( fg bg -- n )
    [ n-registered-colors get ] 2dip ffi:init_pair curses-error
    n-registered-colors [ get ] [ inc ] bi ;

: init-colors ( -- )
    ffi:has_colors [
        1 n-registered-colors set
        \ register-color reset-memoized
        ffi:start_color curses-error
    ] when ;

PRIVATE>

: setup-window ( window -- window )
    [
        dup
        dup parent-window>> [
            ptr>> swap window-params ffi:derwin
        ] [
            window-params ffi:newwin
        ] if* [ curses-error ] keep >>ptr &dispose
    ] [ apply-options ] bi ;

: with-window ( window quot -- )
    [ current-window ] dip with-variable ; inline

: with-curses ( window quot -- )
    curses-ok? [ unsupported-curses-terminal ] unless
    [
        [
            ffi:initscr curses-pointer-error
            >>ptr dup apply-options
        ] dip
        ffi:erase curses-error
        init-colors
        [
            [ ffi:endwin curses-error ] [ ] cleanup
        ] curry with-window
    ] with-destructors ; inline

TUPLE: curses-terminal < disposable
    infd outfd ptr ;

: <curses-terminal> ( infd outfd ptr -- curses-terminal )
    curses-terminal new-disposable
        swap >>ptr
        swap >>outfd
        swap >>infd ;

M: curses-terminal dispose
    [ outfd>> fclose ] [ infd>> fclose ]
    [ ptr>> ffi:delscreen ] tri ;

: init-terminal ( terminal -- curses-terminal )
    "xterm-color" swap [ "rb" fopen ] [ "wb" fopen ] bi
    [ ffi:newterm curses-pointer-error ] 2keep <curses-terminal> ;

: start-remote-curses ( terminal window -- curses-terminal )
    [
        init-terminal
        ffi:initscr curses-pointer-error drop
        dup ptr>> ffi:set_term curses-pointer-error drop
    ] dip apply-options ;
    
<PRIVATE

: (wcrefresh) ( window-ptr -- ) ffi:wrefresh curses-error ; inline
: (wcwrite) ( string window-ptr -- ) swap ffi:waddstr curses-error ; inline

:: (wcread) ( n encoding window-ptr -- string )
    [
        n 1 + malloc &free :> str
        window-ptr str n ffi:wgetnstr curses-error
        str encoding alien>string
    ] with-destructors ; inline

: (wcmove) ( y x window-ptr -- )
    -rot ffi:wmove curses-error ; inline

: (winsert-blank-line) ( y window-ptr -- )
    [ 0 swap (wcmove) ]
    [ ffi:winsertln curses-error ] bi ; inline

: (waddch) ( ch window-ptr -- )
    swap ffi:waddch curses-error ; inline

: (wgetch) ( window -- key )
    ffi:wgetch [ curses-error ] keep ; inline

PRIVATE>

: wcrefresh ( window -- ) ptr>> (wcrefresh) ;
: crefresh ( -- ) current-window get wcrefresh ;

: wcwrite ( string window -- ) ptr>> (wcwrite) ;
: cwrite ( string -- ) current-window get wcwrite ;

: wcnl ( window -- ) [ "\n" ] dip ptr>> (wcwrite) ;
: cnl ( -- ) current-window get wcnl ;

: wcprint ( string window -- )
    ptr>> [ (wcwrite) ] [ "\n" swap (wcwrite) ] bi ;
: cprint ( string -- ) current-window get wcprint ;

: wcprintf ( string window -- )
    ptr>> [ (wcwrite) ] [ "\n" swap (wcwrite) ]
    [ (wcrefresh) ] tri ;
: curses-print-refresh ( string -- ) current-window get wcprintf ;

: wcwritef ( string window -- )
    ptr>> [ (wcwrite) ] [ (wcrefresh) ] bi ;
: cwritef ( string -- ) current-window get wcwritef ;

: wcread ( n window -- string )
    [ encoding>> ] [ ptr>> ] bi (wcread) ;
: curses-read ( n -- string ) current-window get wcread ;

: wgetch ( window -- key ) ptr>> (wgetch) ;
: getch ( -- key ) current-window get wgetch ;

: waddch ( ch window -- ) ptr>> (waddch) ;
: addch ( ch -- ) current-window get waddch ;

: werase ( window -- ) ptr>> ffi:werase curses-error ;
: erase ( -- ) current-window get werase ;

: wcmove ( y x window -- )
    ptr>> [ (wcmove) ] [ (wcrefresh) ] bi ;
: cmove ( y x -- ) current-window get wcmove ;

: wdelete-line ( y window -- )
    ptr>> [ 0 swap (wcmove) ] [ ffi:wdeleteln curses-error ] bi ;
: delete-line ( y -- ) current-window get wdelete-line ;

: winsert-blank-line ( y window -- )
    ptr>> (winsert-blank-line) ;
: insert-blank-line ( y -- )
    current-window get winsert-blank-line ;

: winsert-line ( string y window -- )
    ptr>> [ (winsert-blank-line) ] [ (wcwrite) ] bi ;
: insert-line ( string y -- )
    current-window get winsert-line ;

: wccolor ( foreground background window -- )
    [
        2dup [ COLOR_WHITE = ] [ COLOR_BLACK = ] bi* and
        [ 2drop 0 ] [ register-color ] if ffi:COLOR_PAIR
    ] dip ptr>> swap ffi:wattron curses-error ;

: ccolor ( foreground background -- )
    current-window get wccolor ;
