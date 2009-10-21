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

CONSTANT: A_NORMAL      0
CONSTANT: A_ATTRIBUTES  -256
CONSTANT: A_CHARTEXT    255
CONSTANT: A_COLOR       65280
CONSTANT: A_STANDOUT    65536
CONSTANT: A_UNDERLINE   131072
CONSTANT: A_REVERSE     262144
CONSTANT: A_BLINK       524288
CONSTANT: A_DIM         1048576
CONSTANT: A_BOLD        2097152
CONSTANT: A_ALTCHARSET  4194304
CONSTANT: A_INVIS       8388608
CONSTANT: A_PROTECT     16777216
CONSTANT: A_HORIZONTAL  33554432
CONSTANT: A_LEFT        67108864
CONSTANT: A_LOW         134217728
CONSTANT: A_RIGHT       268435456
CONSTANT: A_TOP         536870912
CONSTANT: A_VERTICAL    1073741824

CONSTANT: KEY_CODE_YES  OCT: 400  /* A wchar_t contains a key code */
CONSTANT: KEY_MIN       OCT: 401  /* Minimum curses key */
CONSTANT: KEY_BREAK     OCT: 401  /* Break key (unreliable) */
CONSTANT: KEY_SRESET    OCT: 530  /* Soft (partial) reset (unreliable) */
CONSTANT: KEY_RESET     OCT: 531  /* Reset or hard reset (unreliable) */
CONSTANT: KEY_DOWN      OCT: 402  /* down-arrow key */
CONSTANT: KEY_UP        OCT: 403  /* up-arrow key */
CONSTANT: KEY_LEFT      OCT: 404  /* left-arrow key */
CONSTANT: KEY_RIGHT     OCT: 405  /* right-arrow key */
CONSTANT: KEY_HOME      OCT: 406  /* home key */
CONSTANT: KEY_BACKSPACE OCT: 407  /* backspace key */
CONSTANT: KEY_DL        OCT: 510  /* delete-line key */
CONSTANT: KEY_IL        OCT: 511  /* insert-line key */
CONSTANT: KEY_DC        OCT: 512  /* delete-character key */
CONSTANT: KEY_IC        OCT: 513  /* insert-character key */
CONSTANT: KEY_EIC       OCT: 514  /* sent by rmir or smir in insert mode */
CONSTANT: KEY_CLEAR     OCT: 515  /* clear-screen or erase key */
CONSTANT: KEY_EOS       OCT: 516  /* clear-to-end-of-screen key */
CONSTANT: KEY_EOL       OCT: 517  /* clear-to-end-of-line key */
CONSTANT: KEY_SF        OCT: 520  /* scroll-forward key */
CONSTANT: KEY_SR        OCT: 521  /* scroll-backward key */
CONSTANT: KEY_NPAGE     OCT: 522  /* next-page key */
CONSTANT: KEY_PPAGE     OCT: 523  /* previous-page key */
CONSTANT: KEY_STAB      OCT: 524  /* set-tab key */
CONSTANT: KEY_CTAB      OCT: 525  /* clear-tab key */
CONSTANT: KEY_CATAB     OCT: 526  /* clear-all-tabs key */
CONSTANT: KEY_ENTER     OCT: 527  /* enter/send key */
CONSTANT: KEY_PRINT     OCT: 532  /* print key */
CONSTANT: KEY_LL        OCT: 533  /* lower-left key (home down) */
CONSTANT: KEY_A1        OCT: 534  /* upper left of keypad */
CONSTANT: KEY_A3        OCT: 535  /* upper right of keypad */
CONSTANT: KEY_B2        OCT: 536  /* center of keypad */
CONSTANT: KEY_C1        OCT: 537  /* lower left of keypad */
CONSTANT: KEY_C3        OCT: 540  /* lower right of keypad */
CONSTANT: KEY_BTAB      OCT: 541  /* back-tab key */
CONSTANT: KEY_BEG       OCT: 542  /* begin key */
CONSTANT: KEY_CANCEL    OCT: 543  /* cancel key */
CONSTANT: KEY_CLOSE     OCT: 544  /* close key */
CONSTANT: KEY_COMMAND   OCT: 545  /* command key */
CONSTANT: KEY_COPY      OCT: 546  /* copy key */
CONSTANT: KEY_CREATE    OCT: 547  /* create key */
CONSTANT: KEY_END       OCT: 550  /* end key */
CONSTANT: KEY_EXIT      OCT: 551  /* exit key */
CONSTANT: KEY_FIND      OCT: 552  /* find key */
CONSTANT: KEY_HELP      OCT: 553  /* help key */
CONSTANT: KEY_MARK      OCT: 554  /* mark key */
CONSTANT: KEY_MESSAGE   OCT: 555  /* message key */
CONSTANT: KEY_MOVE      OCT: 556  /* move key */
CONSTANT: KEY_NEXT      OCT: 557  /* next key */
CONSTANT: KEY_OPEN      OCT: 560  /* open key */
CONSTANT: KEY_OPTIONS   OCT: 561  /* options key */
CONSTANT: KEY_PREVIOUS  OCT: 562  /* previous key */
CONSTANT: KEY_REDO      OCT: 563  /* redo key */
CONSTANT: KEY_REFERENCE OCT: 564  /* reference key */
CONSTANT: KEY_REFRESH   OCT: 565  /* refresh key */
CONSTANT: KEY_REPLACE   OCT: 566  /* replace key */
CONSTANT: KEY_RESTART   OCT: 567  /* restart key */
CONSTANT: KEY_RESUME    OCT: 570  /* resume key */
CONSTANT: KEY_SAVE      OCT: 571  /* save key */
CONSTANT: KEY_SBEG      OCT: 572  /* shifted begin key */
CONSTANT: KEY_SCANCEL   OCT: 573  /* shifted cancel key */
CONSTANT: KEY_SCOMMAND  OCT: 574  /* shifted command key */
CONSTANT: KEY_SCOPY     OCT: 575  /* shifted copy key */
CONSTANT: KEY_SCREATE   OCT: 576  /* shifted create key */
CONSTANT: KEY_SDC       OCT: 577  /* shifted delete-character key */
CONSTANT: KEY_SDL       OCT: 600  /* shifted delete-line key */
CONSTANT: KEY_SELECT    OCT: 601  /* select key */
CONSTANT: KEY_SEND      OCT: 602  /* shifted end key */
CONSTANT: KEY_SEOL      OCT: 603  /* shifted clear-to-end-of-line key */
CONSTANT: KEY_SEXIT     OCT: 604  /* shifted exit key */
CONSTANT: KEY_SFIND     OCT: 605  /* shifted find key */
CONSTANT: KEY_SHELP     OCT: 606  /* shifted help key */
CONSTANT: KEY_SHOME     OCT: 607  /* shifted home key */
CONSTANT: KEY_SIC       OCT: 610  /* shifted insert-character key */
CONSTANT: KEY_SLEFT     OCT: 611  /* shifted left-arrow key */
CONSTANT: KEY_SMESSAGE  OCT: 612  /* shifted message key */
CONSTANT: KEY_SMOVE     OCT: 613  /* shifted move key */
CONSTANT: KEY_SNEXT     OCT: 614  /* shifted next key */
CONSTANT: KEY_SOPTIONS  OCT: 615  /* shifted options key */
CONSTANT: KEY_SPREVIOUS OCT: 616  /* shifted previous key */
CONSTANT: KEY_SPRINT    OCT: 617  /* shifted print key */
CONSTANT: KEY_SREDO     OCT: 620  /* shifted redo key */
CONSTANT: KEY_SREPLACE  OCT: 621  /* shifted replace key */
CONSTANT: KEY_SRIGHT    OCT: 622  /* shifted right-arrow key */
CONSTANT: KEY_SRSUME    OCT: 623  /* shifted resume key */
CONSTANT: KEY_SSAVE     OCT: 624  /* shifted save key */
CONSTANT: KEY_SSUSPEND  OCT: 625  /* shifted suspend key */
CONSTANT: KEY_SUNDO     OCT: 626  /* shifted undo key */
CONSTANT: KEY_SUSPEND   OCT: 627  /* suspend key */
CONSTANT: KEY_UNDO      OCT: 630  /* undo key */
CONSTANT: KEY_MOUSE     OCT: 631  /* Mouse event has occurred */
CONSTANT: KEY_RESIZE    OCT: 632  /* Terminal resize event */
CONSTANT: KEY_EVENT     OCT: 633  /* We were interrupted by an event */
CONSTANT: KEY_F0        OCT: 410  /* Function keys.  Space for 64 */
: KEY_F ( n -- code ) KEY_F0 + ; inline /* Value of function key n */

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

: apply-window-options ( window -- )
    {
        [ [ ptr>> ] [ scrollok>> >BOOLEAN ] bi ffi:scrollok curses-error ]
        [ [ ptr>> ] [ leaveok>> >BOOLEAN ] bi ffi:leaveok curses-error ]
        [ [ ptr>> ] [ keypad>> >BOOLEAN ] bi ffi:keypad curses-error ]
    } cleave ;

: apply-global-options ( window -- )
    [ [ cbreak>> ] [ raw>> ] bi set-cbreak/raw ]
    [ echo>> [ ffi:echo ] [ ffi:noecho ] if curses-error ]
    bi ;

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
    ] [ apply-window-options ] bi ;

: with-window ( window quot -- )
    [ current-window ] dip with-variable ; inline

: with-curses ( window quot -- )
    curses-ok? [ unsupported-curses-terminal ] unless
    [
        '[
            ffi:initscr curses-pointer-error
            >>ptr
            [ apply-global-options ] [ apply-window-options ] [ ] tri

            ffi:erase curses-error
            init-colors

            _ with-window
        ] [ ffi:endwin curses-error ] [ ] cleanup
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
    ] dip [ apply-global-options ] [ apply-window-options ] bi ;
    
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

: (wattroff) ( attribute window-ptr -- )
    swap ffi:wattroff curses-error ; inline

: (wattron) ( attribute window-ptr -- )
    swap ffi:wattron curses-error ; inline

PRIVATE>

: wcrefresh ( window -- ) ptr>> (wcrefresh) ;
: crefresh ( -- ) current-window get wcrefresh ;

: wcnl ( window -- ) [ "\n" ] dip ptr>> (wcwrite) ;
: cnl ( -- ) current-window get wcnl ;

: wcwrite ( string window -- ) ptr>> (wcwrite) ;
: cwrite ( string -- ) current-window get wcwrite ;

: wcprint ( string window -- )
    ptr>> [ (wcwrite) ] [ "\n" swap (wcwrite) ] bi ;
: cprint ( string -- ) current-window get wcprint ;

: wcprintf ( string window -- )
    ptr>> [ (wcwrite) ] [ "\n" swap (wcwrite) ]
    [ (wcrefresh) ] tri ;
: cprintf ( string -- ) current-window get wcprintf ;

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

: wattron ( attribute window -- ) ptr>> (wattron) ;
: attron ( attribute -- ) current-window get wattron ;

: wattroff ( attribute window -- ) ptr>> (wattroff) ;
: attroff ( attribute -- ) current-window get wattroff ;

: wall-attroff ( window -- ) [ A_NORMAL ] dip wattroff ;
: all-attroff ( -- ) current-window get wall-attroff ;

: wccolor ( foreground background window -- )
    [
        2dup [ COLOR_WHITE = ] [ COLOR_BLACK = ] bi* and
        [ 2drop 0 ] [ register-color ] if ffi:COLOR_PAIR
    ] dip ptr>> (wattron) ;

: ccolor ( foreground background -- )
    current-window get wccolor ;
