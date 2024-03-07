! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data alien.strings
classes.struct combinators continuations destructors fry
io.encodings.utf8 kernel libc locals math memoize multiline
namespaces sequences unix.ffi ;

QUALIFIED-WITH: curses.ffi ffi

IN: curses

SYMBOL: current-window

CONSTANT: COLOR_BLACK   0
CONSTANT: COLOR_RED     1
CONSTANT: COLOR_GREEN   2
CONSTANT: COLOR_YELLOW  3
CONSTANT: COLOR_BLUE    4
CONSTANT: COLOR_MAGENTA 5
CONSTANT: COLOR_CYAN    6
CONSTANT: COLOR_WHITE   7

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
CONSTANT: A_ITALIC      2147483648

CONSTANT: KEY_CODE_YES  0o400  /* A wchar_t contains a key code */
CONSTANT: KEY_MIN       0o401  /* Minimum curses key */
CONSTANT: KEY_BREAK     0o401  /* Break key (unreliable) */
CONSTANT: KEY_SRESET    0o530  /* Soft (partial) reset (unreliable) */
CONSTANT: KEY_RESET     0o531  /* Reset or hard reset (unreliable) */
CONSTANT: KEY_DOWN      0o402  /* down-arrow key */
CONSTANT: KEY_UP        0o403  /* up-arrow key */
CONSTANT: KEY_LEFT      0o404  /* left-arrow key */
CONSTANT: KEY_RIGHT     0o405  /* right-arrow key */
CONSTANT: KEY_HOME      0o406  /* home key */
CONSTANT: KEY_BACKSPACE 0o407  /* backspace key */
CONSTANT: KEY_DL        0o510  /* delete-line key */
CONSTANT: KEY_IL        0o511  /* insert-line key */
CONSTANT: KEY_DC        0o512  /* delete-character key */
CONSTANT: KEY_IC        0o513  /* insert-character key */
CONSTANT: KEY_EIC       0o514  /* sent by rmir or smir in insert mode */
CONSTANT: KEY_CLEAR     0o515  /* clear-screen or erase key */
CONSTANT: KEY_EOS       0o516  /* clear-to-end-of-screen key */
CONSTANT: KEY_EOL       0o517  /* clear-to-end-of-line key */
CONSTANT: KEY_SF        0o520  /* scroll-forward key */
CONSTANT: KEY_SR        0o521  /* scroll-backward key */
CONSTANT: KEY_NPAGE     0o522  /* next-page key */
CONSTANT: KEY_PPAGE     0o523  /* previous-page key */
CONSTANT: KEY_STAB      0o524  /* set-tab key */
CONSTANT: KEY_CTAB      0o525  /* clear-tab key */
CONSTANT: KEY_CATAB     0o526  /* clear-all-tabs key */
CONSTANT: KEY_ENTER     0o527  /* enter/send key */
CONSTANT: KEY_PRINT     0o532  /* print key */
CONSTANT: KEY_LL        0o533  /* lower-left key (home down) */
CONSTANT: KEY_A1        0o534  /* upper left of keypad */
CONSTANT: KEY_A3        0o535  /* upper right of keypad */
CONSTANT: KEY_B2        0o536  /* center of keypad */
CONSTANT: KEY_C1        0o537  /* lower left of keypad */
CONSTANT: KEY_C3        0o540  /* lower right of keypad */
CONSTANT: KEY_BTAB      0o541  /* back-tab key */
CONSTANT: KEY_BEG       0o542  /* begin key */
CONSTANT: KEY_CANCEL    0o543  /* cancel key */
CONSTANT: KEY_CLOSE     0o544  /* close key */
CONSTANT: KEY_COMMAND   0o545  /* command key */
CONSTANT: KEY_COPY      0o546  /* copy key */
CONSTANT: KEY_CREATE    0o547  /* create key */
CONSTANT: KEY_END       0o550  /* end key */
CONSTANT: KEY_EXIT      0o551  /* exit key */
CONSTANT: KEY_FIND      0o552  /* find key */
CONSTANT: KEY_HELP      0o553  /* help key */
CONSTANT: KEY_MARK      0o554  /* mark key */
CONSTANT: KEY_MESSAGE   0o555  /* message key */
CONSTANT: KEY_MOVE      0o556  /* move key */
CONSTANT: KEY_NEXT      0o557  /* next key */
CONSTANT: KEY_OPEN      0o560  /* open key */
CONSTANT: KEY_OPTIONS   0o561  /* options key */
CONSTANT: KEY_PREVIOUS  0o562  /* previous key */
CONSTANT: KEY_REDO      0o563  /* redo key */
CONSTANT: KEY_REFERENCE 0o564  /* reference key */
CONSTANT: KEY_REFRESH   0o565  /* refresh key */
CONSTANT: KEY_REPLACE   0o566  /* replace key */
CONSTANT: KEY_RESTART   0o567  /* restart key */
CONSTANT: KEY_RESUME    0o570  /* resume key */
CONSTANT: KEY_SAVE      0o571  /* save key */
CONSTANT: KEY_SBEG      0o572  /* shifted begin key */
CONSTANT: KEY_SCANCEL   0o573  /* shifted cancel key */
CONSTANT: KEY_SCOMMAND  0o574  /* shifted command key */
CONSTANT: KEY_SCOPY     0o575  /* shifted copy key */
CONSTANT: KEY_SCREATE   0o576  /* shifted create key */
CONSTANT: KEY_SDC       0o577  /* shifted delete-character key */
CONSTANT: KEY_SDL       0o600  /* shifted delete-line key */
CONSTANT: KEY_SELECT    0o601  /* select key */
CONSTANT: KEY_SEND      0o602  /* shifted end key */
CONSTANT: KEY_SEOL      0o603  /* shifted clear-to-end-of-line key */
CONSTANT: KEY_SEXIT     0o604  /* shifted exit key */
CONSTANT: KEY_SFIND     0o605  /* shifted find key */
CONSTANT: KEY_SHELP     0o606  /* shifted help key */
CONSTANT: KEY_SHOME     0o607  /* shifted home key */
CONSTANT: KEY_SIC       0o610  /* shifted insert-character key */
CONSTANT: KEY_SLEFT     0o611  /* shifted left-arrow key */
CONSTANT: KEY_SMESSAGE  0o612  /* shifted message key */
CONSTANT: KEY_SMOVE     0o613  /* shifted move key */
CONSTANT: KEY_SNEXT     0o614  /* shifted next key */
CONSTANT: KEY_SOPTIONS  0o615  /* shifted options key */
CONSTANT: KEY_SPREVIOUS 0o616  /* shifted previous key */
CONSTANT: KEY_SPRINT    0o617  /* shifted print key */
CONSTANT: KEY_SREDO     0o620  /* shifted redo key */
CONSTANT: KEY_SREPLACE  0o621  /* shifted replace key */
CONSTANT: KEY_SRIGHT    0o622  /* shifted right-arrow key */
CONSTANT: KEY_SRSUME    0o623  /* shifted resume key */
CONSTANT: KEY_SSAVE     0o624  /* shifted save key */
CONSTANT: KEY_SSUSPEND  0o625  /* shifted suspend key */
CONSTANT: KEY_SUNDO     0o626  /* shifted undo key */
CONSTANT: KEY_SUSPEND   0o627  /* suspend key */
CONSTANT: KEY_UNDO      0o630  /* undo key */
CONSTANT: KEY_MOUSE     0o631  /* Mouse event has occurred */
CONSTANT: KEY_RESIZE    0o632  /* Terminal resize event */
CONSTANT: KEY_EVENT     0o633  /* We were interrupted by an event */
CONSTANT: KEY_MAX       0o777  /* Maximum key value is 0633 */
CONSTANT: KEY_F0        0o410  /* Function keys.  Space for 64 */
: KEY_F ( n -- code ) KEY_F0 + ; inline /* Value of function key n */

: BUTTON1_RELEASED       ( -- mask ) 1 ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON1_PRESSED        ( -- mask ) 1 ffi:NCURSES_BUTTON_PRESSED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON1_CLICKED        ( -- mask ) 1 ffi:NCURSES_BUTTON_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON1_DOUBLE_CLICKED ( -- mask ) 1 ffi:NCURSES_DOUBLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON1_TRIPLE_CLICKED ( -- mask ) 1 ffi:NCURSES_TRIPLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON2_RELEASED       ( -- mask ) 2 ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON2_PRESSED        ( -- mask ) 2 ffi:NCURSES_BUTTON_PRESSED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON2_CLICKED        ( -- mask ) 2 ffi:NCURSES_BUTTON_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON2_DOUBLE_CLICKED ( -- mask ) 2 ffi:NCURSES_DOUBLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON2_TRIPLE_CLICKED ( -- mask ) 2 ffi:NCURSES_TRIPLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON3_RELEASED       ( -- mask ) 3 ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON3_PRESSED        ( -- mask ) 3 ffi:NCURSES_BUTTON_PRESSED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON3_CLICKED        ( -- mask ) 3 ffi:NCURSES_BUTTON_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON3_DOUBLE_CLICKED ( -- mask ) 3 ffi:NCURSES_DOUBLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON3_TRIPLE_CLICKED ( -- mask ) 3 ffi:NCURSES_TRIPLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON4_RELEASED       ( -- mask ) 4 ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON4_PRESSED        ( -- mask ) 4 ffi:NCURSES_BUTTON_PRESSED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON4_CLICKED        ( -- mask ) 4 ffi:NCURSES_BUTTON_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON4_DOUBLE_CLICKED ( -- mask ) 4 ffi:NCURSES_DOUBLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON4_TRIPLE_CLICKED ( -- mask ) 4 ffi:NCURSES_TRIPLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON5_RELEASED       ( -- mask ) 5 ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON5_PRESSED        ( -- mask ) 5 ffi:NCURSES_BUTTON_PRESSED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON5_CLICKED        ( -- mask ) 5 ffi:NCURSES_BUTTON_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON5_DOUBLE_CLICKED ( -- mask ) 5 ffi:NCURSES_DOUBLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON5_TRIPLE_CLICKED ( -- mask ) 5 ffi:NCURSES_TRIPLE_CLICKED  ffi:NCURSES_MOUSE_MASK ; inline

: BUTTON_CTRL            ( -- mask ) 5 0o01 ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON_SHIFT           ( -- mask ) 5 0o02 ffi:NCURSES_MOUSE_MASK ; inline
: BUTTON_ALT             ( -- mask ) 5 0o04 ffi:NCURSES_MOUSE_MASK ; inline
: REPORT_MOUSE_POSITION  ( -- mask ) 5 0o10 ffi:NCURSES_MOUSE_MASK ; inline

: ALL_MOUSE_EVENTS ( -- mask ) REPORT_MOUSE_POSITION 1 - ; inline

ERROR: curses-failed ;
ERROR: unsupported-curses-terminal ;

<PRIVATE

: >BOOLEAN ( ? -- TRUE/FALSE ) ffi:TRUE ffi:FALSE ? ; inline

: curses-pointer-error ( ptr/f -- ptr )
    [ curses-failed ] unless* ; inline
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
    { echo initial: f }
    { raw initial: f }

    { scrollok initial: t }
    { leaveok initial: f }

    idcok idlok immedok
    { keypad initial: t }
    { nodelay initial: f }

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
        [ [ ptr>> ] [ nodelay>> ] bi [ ffi:TRUE ffi:nodelay
        curses-error ] [ drop ] if ]
    } cleave ;

: apply-global-options ( window -- )
    [ [ cbreak>> ] [ raw>> ] bi set-cbreak/raw ]
    [ echo>> [ ffi:echo ] [ ffi:noecho ] if curses-error ]
    bi ;

SYMBOL: n-registered-colors

MEMO: register-color ( fg bg -- n )
    [ n-registered-colors get dup ] 2dip ffi:init_pair curses-error
    n-registered-colors inc ;

: init-colors ( -- )
    ffi:has_colors [
        1 n-registered-colors set
        \ register-color reset-memoized
        ffi:start_color curses-error
        ffi:stdscr 0 f ffi:wcolor_set curses-error
    ] when ;

PRIVATE>

: setup-window ( window -- window )
    [
        dup [ window-params ] keep
        parent-window>> [ ptr>> ffi:derwin ] [ ffi:newwin ] if*
        curses-pointer-error >>ptr &dispose
    ] [ apply-window-options ] bi ;

: with-window ( window quot -- )
    [ current-window ] dip with-variable ; inline

: with-curses ( window quot -- )
    curses-ok? [ unsupported-curses-terminal ] unless
    [
        '[
            ffi:initscr curses-pointer-error
            >>ptr
            {
                [ apply-global-options ]
                [ apply-window-options ]
                [ ptr>> ffi:wclear curses-error ]
                [ ptr>> ffi:wrefresh curses-error ]
                [ ]
            } cleave
            init-colors

            _ with-window
        ] [ ffi:endwin curses-error ] finally
    ] with-destructors ; inline

<PRIVATE

: (wcrefresh) ( window-ptr -- )
    ffi:wrefresh curses-error ; inline

: (wcwrite) ( string window-ptr -- )
    swap ffi:waddstr curses-error ; inline

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

: wgetch ( window -- key ) ptr>> (wgetch) ;
: getch ( -- key ) current-window get wgetch ;

: wgetch-err ( window -- key ) ptr>> ffi:wgetch ;
: getch-err ( -- key ) current-window get wgetch-err ;

: waddch ( ch window -- ) ptr>> (waddch) ;
: addch ( ch -- ) current-window get waddch ;

: wcnl ( window -- ) [ CHAR: \n ] dip waddch ;
: cnl ( -- ) current-window get wcnl ;

: wcwrite ( string window -- ) ptr>> (wcwrite) ;
: cwrite ( string -- ) current-window get wcwrite ;

: wcprint ( string window -- )
    ptr>> [ (wcwrite) ] [ CHAR: \n swap (waddch) ] bi ;
: cprint ( string -- ) current-window get wcprint ;

: wcprintf ( string window -- )
    ptr>> [ (wcwrite) ] [ CHAR: \n swap (waddch) ]
    [ (wcrefresh) ] tri ;
: cprintf ( string -- ) current-window get wcprintf ;

: wcwritef ( string window -- )
    ptr>> [ (wcwrite) ] [ (wcrefresh) ] bi ;
: cwritef ( string -- ) current-window get wcwritef ;

: wcread ( n window -- string )
    [ encoding>> ] [ ptr>> ] bi (wcread) ;
: cread ( n -- string ) current-window get wcread ;

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
    [ register-color ] dip ptr>> swap f ffi:wcolor_set curses-error ;

: ccolor ( foreground background -- )
    current-window get wccolor ;

: wcbox ( window -- )
    ptr>> 0 0 ffi:box curses-error ;
: cbox ( -- )
    current-window get wcbox ;

SYMBOLS: +pressed+ +released+ +clicked+ +double+ +triple+ ;

TUPLE: mouse-event
    { id fixnum }
    { y fixnum }
    { x fixnum }
    { button fixnum }
    type
    alt
    shift
    ctrl ;

<PRIVATE

: substate-n ( bstate n -- substate )
    [ 1 + ffi:NCURSES_BUTTON_RELEASED ffi:NCURSES_MOUSE_MASK 1 - bitand ] keep
    1 - -6 * shift ; inline

: button-n? ( bstate n -- ? ) substate-n 0 = not ; inline

: fill-in-type ( mouse-event bstate button -- )
    substate-n {
        { BUTTON1_RELEASED       [ +released+ ] }
        { BUTTON1_PRESSED        [ +pressed+ ] }
        { BUTTON1_CLICKED        [ +clicked+ ] }
        { BUTTON1_DOUBLE_CLICKED [ +double+ ] }
        { BUTTON1_TRIPLE_CLICKED [ +triple+ ] }
    } case >>type drop ; inline

: fill-in-bstate ( mouse-event bstate -- )
    2dup {
        { [ dup 1 button-n? ] [ [ 1 >>button ] dip 1 fill-in-type ] }
        { [ dup 2 button-n? ] [ [ 2 >>button ] dip 2 fill-in-type ] }
        { [ dup 3 button-n? ] [ [ 3 >>button ] dip 3 fill-in-type ] }
        { [ dup 4 button-n? ] [ [ 4 >>button ] dip 4 fill-in-type ] }
        { [ dup 5 button-n? ] [ [ 5 >>button ] dip 5 fill-in-type ] }
    } cond
    {
        [ BUTTON_CTRL  bitand 0 = not [ t >>ctrl  ] when drop ]
        [ BUTTON_SHIFT bitand 0 = not [ t >>shift ] when drop ]
        [ BUTTON_ALT   bitand 0 = not [ t >>alt   ] when drop ]
    } 2cleave ;

: <mouse-event> ( MEVENT -- mouse-event )
    [ mouse-event new ] dip {
        [ id>> >>id drop ]
        [ y>> >>y drop ]
        [ x>> >>x drop ]
        [ bstate>> fill-in-bstate ]
        [ drop ]
    } 2cleave ;

PRIVATE>

: getmouse ( -- mouse-event/f )
    [
        ffi:MEVENT malloc-struct &free
        dup ffi:getmouse
        ffi:ERR = [ drop f ] [ <mouse-event> ] if
    ] with-destructors ;

: mousemask ( mask -- newmask oldmask )
    0 ulong <ref> [ ffi:mousemask ] keep ulong deref ;

: wget-yx ( window -- y x )
    ptr>> [ _cury>> ] [ _curx>> ] bi ;
: get-yx ( -- y x )
    current-window get wget-yx ;

: wget-y ( window -- y )
    ptr>> _cury>> ;
: get-y ( -- y )
    current-window get wget-y ;
: wget-x ( window -- x )
    ptr>> _curx>> ;
: get-x ( -- x )
    current-window get wget-x ;

: wget-max-yx ( window -- y x )
    ptr>> [ _maxy>> 1 + ] [ _maxx>> 1 + ] bi ;
: get-max-yx ( -- y x )
    current-window get wget-max-yx ;

: wget-max-y ( window -- y )
    ptr>> _maxy>> 1 + ;
: get-max-y ( -- y )
    current-window get wget-max-y ;
: wget-max-x ( window -- x )
    ptr>> _maxx>> 1 + ;
: get-max-x ( -- x )
    current-window get wget-max-x ;

ALIAS: set-escdelay ffi:set-ESCDELAY
