! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings assocs byte-arrays
classes.struct combinators continuations curses.ffi destructors
fry io io.encodings.8-bit io.encodings.string io.encodings.utf8
io.streams.c kernel libc locals math memoize multiline
namespaces prettyprint sequences strings threads ;
IN: curses

SYMBOL: current-window

CONSTANT: COLOR_BLACK 0
CONSTANT: COLOR_RED   1
CONSTANT: COLOR_GREEN 2
CONSTANT: COLOR_YELLO 3
CONSTANT: COLOR_BLUE  4
CONSTANT: COLOR_MAGEN 5
CONSTANT: COLOR_CYAN  6
CONSTANT: COLOR_WHITE 7

: >BOOLEAN ( ? -- TRUE/FALSE ) TRUE FALSE ? ; inline

ERROR: curses-failed ;
ERROR: unsupported-curses-terminal ;

: curses-error ( n -- ) ERR = [ curses-failed ] when ;

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
    ptr>> delwin curses-error ;

<PRIVATE

: window-params ( window -- lines columns y x )
    { [ lines>> ] [ columns>> ] [ y>> ] [ x>> ] } cleave ;

: set-cbreak/raw ( cbreak raw -- )
    [ drop raw ] [
        [ cbreak ] [ nocbreak ] if
    ] if curses-error ;

: apply-options ( window -- )
    {
        [ [ cbreak>> ] [ raw>> ] bi set-cbreak/raw ]
        [ echo>> [ echo ] [ noecho ] if curses-error ]
        [ [ ptr>> ] [ scrollok>> >BOOLEAN ] bi scrollok curses-error ]
        [ [ ptr>> ] [ leaveok>> >BOOLEAN ] bi leaveok curses-error ]
        [ [ ptr>> ] [ keypad>> >BOOLEAN ] bi keypad curses-error ]
    } cleave ;

SYMBOL: n-registered-colors

MEMO: register-color ( fg bg -- n )
    [ n-registered-colors get ] 2dip init_pair curses-error
    n-registered-colors [ get ] [ inc ] bi ;

PRIVATE>

: setup-window ( window -- window )
    [
        dup
        dup parent-window>> [
            ptr>> swap window-params derwin
        ] [
            window-params newwin
        ] if* [ curses-error ] keep >>ptr &dispose
    ] [ apply-options ] bi ;

: with-window ( window quot -- )
    [ current-window ] dip with-variable ; inline

<PRIVATE

: init-colors ( -- )
    has_colors [
        1 n-registered-colors set
        \ register-color reset-memoized
        start_color curses-error
    ] when ;

: curses-pointer-error ( ptr/f -- ptr )
    dup [ curses-failed ] unless ; inline

PRIVATE>

: with-curses ( window quot -- )
    curses-ok? [ unsupported-curses-terminal ] unless
    [
        [
            initscr curses-pointer-error
            >>ptr dup apply-options
        ] dip
        erase curses-error
        init-colors
        [
            [ endwin curses-error ] [ ] cleanup
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
    [ ptr>> delscreen ] tri ;

: init-terminal ( terminal -- curses-terminal )
    "xterm-color" swap [ "rb" fopen ] [ "wb" fopen ] bi
    [ newterm curses-pointer-error ] 2keep <curses-terminal> ;

: start-remote-curses ( terminal window -- curses-terminal )
    [
        init-terminal
        initscr curses-pointer-error drop
        dup ptr>> set_term curses-pointer-error drop
    ] dip apply-options ;
    

<PRIVATE

: (window-curses-refresh) ( window-ptr -- ) wrefresh curses-error ; inline
: (window-curses-write) ( string window-ptr -- ) swap waddstr curses-error ; inline

:: (window-curses-read) ( n encoding window-ptr -- string )
    [
        n 1 + malloc &free :> str
        window-ptr str n wgetnstr curses-error
        str encoding alien>string
    ] with-destructors ; inline

: (window-curses-getch) ( window -- key )
    wgetch [ curses-error ] keep ;

: (window-curses-move) ( y x window-ptr -- )
    -rot wmove curses-error ; inline

: (window-insert-blank-line) ( y window-ptr -- )
    [ 0 swap (window-curses-move) ]
    [ winsertln curses-error ] bi ; inline

: (window-curses-addch) ( ch window-ptr -- )
    swap waddch curses-error ; inline

PRIVATE>

: window-curses-refresh ( window -- ) ptr>> (window-curses-refresh) ;
: curses-refresh ( -- ) current-window get window-curses-refresh ;

: window-curses-write ( string window -- )
    ptr>> (window-curses-write) ;
: curses-write ( string -- )
    current-window get window-curses-write ;

: window-curses-nl ( window -- )
    [ "\n" ] dip ptr>> (window-curses-write) ;
: curses-nl ( -- )
    current-window get window-curses-nl ;

: window-curses-print ( string window -- )
    ptr>> [ (window-curses-write) ]
    [ "\n" swap (window-curses-write) ] bi ;
: curses-print ( string -- )
    current-window get window-curses-print ;

: window-curses-print-refresh ( string window -- )
    ptr>> [ (window-curses-write) ]
    [ "\n" swap (window-curses-write) ]
    [ (window-curses-refresh) ] tri ;
: curses-print-refresh ( string -- )
    current-window get window-curses-print-refresh ;

: window-curses-write-refresh ( string window -- )
    ptr>> [ (window-curses-write) ] [ (window-curses-refresh) ] bi ;
: curses-write-refresh ( string -- )
    current-window get window-curses-write-refresh ;

: window-curses-read ( n window -- string )
    [ encoding>> ] [ ptr>> ] bi (window-curses-read) ;
: curses-read ( n -- string )
    current-window get window-curses-read ;

: window-curses-getch ( window -- key )
    ptr>> (window-curses-getch) ;
: curses-getch ( -- key )
    current-window get window-curses-getch ;

: window-curses-erase ( window -- )
    ptr>> werase curses-error ;
: curses-erase ( -- )
    current-window get window-curses-erase ;

: window-curses-move ( y x window -- )
    ptr>> [ (window-curses-move) ] [ (window-curses-refresh) ] bi ;
: curses-move ( y x -- )
    current-window get window-curses-move ;

: window-delete-line ( y window -- )
    ptr>> [ 0 swap (window-curses-move) ]
    [ wdeleteln curses-error ] bi ;
: delete-line ( y -- )
    current-window get window-delete-line ;

: window-insert-blank-line ( y window -- )
    ptr>> (window-insert-blank-line) ;
: insert-blank-line ( y -- )
    current-window get window-insert-blank-line ;

: window-insert-line ( string y window -- )
    ptr>> [ (window-insert-blank-line) ]
    [ (window-curses-write) ] bi ;
: insert-line ( string y -- )
    current-window get window-insert-line ;

: window-curses-addch ( ch window -- )
    ptr>> (window-curses-addch) ;
: curses-addch ( ch -- )
    current-window get window-curses-addch ;

: window-curses-color ( foreground background window -- )
    [
        2dup [ COLOR_WHITE = ] [ COLOR_BLACK = ] bi* and
        [ 2drop 0 ] [ register-color ] if COLOR_PAIR
    ] dip ptr>> swap wattron curses-error ;
: curses-color ( foreground background -- )
    current-window get window-curses-color ;
