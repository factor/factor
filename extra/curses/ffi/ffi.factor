! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.libraries.finder alien.syntax classes.struct combinators
kernel literals math system unix.types ;
IN: curses.ffi

C-LIBRARY: curses {
    { windows "libcurses.dll" }
    { macos "libcurses.dylib" }
    { unix $[ "ncursesw" find-library ] }
}

C-TYPE: SCREEN
TYPEDEF: void* va_list

TYPEDEF: uint chtype
TYPEDEF: chtype attr_t
TYPEDEF: short NCURSES_SIZE_T
TYPEDEF: ushort wchar_t
TYPEDEF: ulong mmask_t

CONSTANT: CCHARW_MAX  5

CONSTANT: ERR -1
CONSTANT: FALSE 0
CONSTANT: TRUE 1

STRUCT: cchar_t
{ attr attr_t }
{ chars { wchar_t CCHARW_MAX } } ;

STRUCT: pdat
{ _pad_y NCURSES_SIZE_T }
{ _pad_x NCURSES_SIZE_T }
{ _pad_top NCURSES_SIZE_T }
{ _pad_left NCURSES_SIZE_T }
{ _pad_bottom NCURSES_SIZE_T }
{ _pad_right NCURSES_SIZE_T } ;

STRUCT: WINDOW
{ _cury NCURSES_SIZE_T }
{ _curx NCURSES_SIZE_T }

{ _maxy NCURSES_SIZE_T }
{ _maxx NCURSES_SIZE_T }
{ _begy NCURSES_SIZE_T }
{ _begx NCURSES_SIZE_T }

{ _flags short }

{ _attrs attr_t }
{ _bkgd chtype }

{ _notimeout bool }
{ _clear bool }
{ _leaveok bool }
{ _scroll bool }
{ _idlok bool }
{ _idcok bool }
{ _immed bool }
{ _sync bool }
{ _use_keypad bool }
{ _delay int }

{ _line c-string }
{ _regtop NCURSES_SIZE_T }
{ _regbottom NCURSES_SIZE_T }

{ _parx int }
{ _pary int }
{ _parent WINDOW* }

{ _pad pdat }

{ _yoffset NCURSES_SIZE_T }

{ _bkgrnd cchar_t } ;

STRUCT: MEVENT
    { id short }
    { x int } { y int } { z int }
    { bstate mmask_t } ;

LIBRARY: curses

C-GLOBAL: void* stdscr

FUNCTION: WINDOW* initscr ( )
FUNCTION: int endwin ( )
FUNCTION: bool isendwin ( )
FUNCTION: SCREEN* newterm ( c-string type, FILE* outfd, FILE* infd )
FUNCTION: SCREEN* set_term ( SCREEN* new )
FUNCTION: void delscreen ( SCREEN* sp )

FUNCTION: int def_prog_mode ( )
FUNCTION: int def_shell_mode ( )
FUNCTION: int reset_prog_mode ( )
FUNCTION: int reset_shell_mode ( )
FUNCTION: int resetty ( )
FUNCTION: int savetty ( )
FUNCTION: int ripoffline ( int line, void* callback )
FUNCTION: int curs_set ( int visibility )
FUNCTION: int napms ( int ms )

FUNCTION: WINDOW* newwin ( int nlines, int ncols, int begin_y, int begin_x )
FUNCTION: int delwin ( WINDOW* win )
FUNCTION: int mvwin ( WINDOW* win, int y, int x )
FUNCTION: WINDOW* subwin ( WINDOW* orig, int nlines, int ncols, int begin_y, int begin_x )
FUNCTION: WINDOW* derwin ( WINDOW* orig, int nlines, int ncols, int begin_y, int begin_x )
FUNCTION: int mvderwin ( WINDOW* win, int par_y, int par_x )
FUNCTION: WINDOW* dupwin ( WINDOW* win )
FUNCTION: void wsyncup ( WINDOW* win )
FUNCTION: int syncok ( WINDOW* win, bool bf )
FUNCTION: void wcursyncup ( WINDOW* win )
FUNCTION: void wsyncdown ( WINDOW* win )

FUNCTION: int cbreak ( )
FUNCTION: int nocbreak ( )
FUNCTION: int echo ( )
FUNCTION: int noecho ( )
FUNCTION: int halfdelay ( int tenths )
FUNCTION: int intrflush ( WINDOW* win, bool bf )
FUNCTION: int keypad ( WINDOW* win, bool bf )
FUNCTION: int meta ( WINDOW* win, bool bf )
FUNCTION: int nodelay ( WINDOW* win, bool bf )
FUNCTION: int raw ( )
FUNCTION: int noraw ( )
FUNCTION: void noqiflush ( )
FUNCTION: void qiflush ( )
FUNCTION: int notimeout ( WINDOW* win, bool bf )
FUNCTION: void timeout ( int delay )
FUNCTION: void wtimeout ( WINDOW* win, int delay )
FUNCTION: int typeahead ( int fd )

FUNCTION: int clearok ( WINDOW* win, bool bf )
FUNCTION: int idlok ( WINDOW* win, bool bf )
FUNCTION: void idcok ( WINDOW* win, bool bf )
FUNCTION: void immedok ( WINDOW* win, bool bf )
FUNCTION: int leaveok ( WINDOW* win, bool bf )
FUNCTION: int setscrreg ( int top, int bot )
FUNCTION: int wsetscrreg ( WINDOW* win, int top, int bot )
FUNCTION: int scrollok ( WINDOW* win, bool bf )
FUNCTION: int nl ( )
FUNCTION: int nonl ( )

FUNCTION: int erase ( )
FUNCTION: int werase ( WINDOW* win )
FUNCTION: int clear ( )
FUNCTION: int wclear ( WINDOW* win )
FUNCTION: int clrtobot ( )
FUNCTION: int wclrtobot ( WINDOW* win )
FUNCTION: int clrtoeol ( )
FUNCTION: int wclrtoeol ( WINDOW* win )

FUNCTION: int refresh ( )
FUNCTION: int wrefresh ( WINDOW* win )
FUNCTION: int wnoutrefresh ( WINDOW* win )
FUNCTION: int doupdate ( )
FUNCTION: int redrawwin ( WINDOW* win )
FUNCTION: int wredrawln ( WINDOW* win, int beg_line, int num_lines )

FUNCTION: int getch ( )
FUNCTION: int wgetch ( WINDOW* win )
FUNCTION: int mvgetch ( int y, int x )
FUNCTION: int mvwgetch ( WINDOW* win, int y, int x )
FUNCTION: int ungetch ( int ch )
FUNCTION: int has_key ( int ch )

FUNCTION: int get_wch ( c-string wc )
FUNCTION: int wget_wch ( WINDOW* win, c-string wc )
FUNCTION: int mvget_wch ( int y, int x, c-string wc )
FUNCTION: int mvwget_wch ( WINDOW* win, int y, int x, c-string wc )
FUNCTION: int unget_wch ( wchar_t wc )

FUNCTION: int getstr ( c-string str )
FUNCTION: int getnstr ( c-string str, int n )
FUNCTION: int wgetstr ( WINDOW* win, c-string str )
FUNCTION: int wgetnstr ( WINDOW* win, c-string str, int n )
FUNCTION: int mvgetstr ( int y, int x, c-string str )
FUNCTION: int mvwgetstr ( WINDOW* win, int y, int x, c-string str )
FUNCTION: int mvgetnstr ( int y, int x, c-string str, int n )
FUNCTION: int mvwgetnstr ( WINDOW* win, int y, int x, c-string str, int n )

FUNCTION: int printw ( c-string fmt, int lol )
FUNCTION: int wprintw ( WINDOW* win, c-string fmt, int lol )
FUNCTION: int mvprintw ( int y, int x, c-string fmt, int lol )
FUNCTION: int mvwprintw ( WINDOW* win, int y, int x, c-string fmt, int lol )
FUNCTION: int vwprintw ( WINDOW* win, c-string fmt, va_list varglist )
FUNCTION: int vw_printw ( WINDOW* win, c-string fmt, va_list varglist )

FUNCTION: int move ( int y, int x )
FUNCTION: int wmove ( WINDOW* win, int y, int x )

FUNCTION: int scroll ( WINDOW* win )
FUNCTION: int scrl ( int n )
FUNCTION: int wscrl ( WINDOW* win, int n )

! int setupterm(char *term, int fildes, int *errret);
! int setterm(char *term);
! TERMINAL *set_curterm(TERMINAL *nterm);
! int del_curterm(TERMINAL *oterm);
! int restartterm(const char *term, int fildes, int *errret);
! char *tparm(char *str, ...);
! int tputs(const char *str, int affcnt, int (*putc)(int));
! int putp(const char *str);
! int vidputs(chtype attrs, int (*putc)(int));
! int vidattr(chtype attrs);
! int vid_puts(attr_t attrs, short pair, void *opts, int (*putc)(char));
! int vid_attr(attr_t attrs, short pair, void *opts);
FUNCTION: int mvcur ( int oldrow, int oldcol, int newrow, int newcol )
! int tigetflag(char *capname);
! int tigetnum(char *capname);
! char *tigetstr(char *capname);

FUNCTION: int touchwin ( WINDOW* win )
FUNCTION: int touchline ( WINDOW* win, int start, int count )
FUNCTION: int untouchwin ( WINDOW* win )
FUNCTION: int wtouchln ( WINDOW* win, int y, int n, int changed )
FUNCTION: bool is_linetouched ( WINDOW* win, int line )
FUNCTION: bool is_wintouched ( WINDOW* win )

FUNCTION: int insch ( chtype ch )
FUNCTION: int winsch ( WINDOW* win, chtype ch )
FUNCTION: int mvinsch ( int y, int x, chtype ch )
FUNCTION: int mvwinsch ( WINDOW* win, int y, int x, chtype ch )
FUNCTION: int delch ( )
FUNCTION: int wdelch ( WINDOW* win )
FUNCTION: int mvdelch ( int y, int x )
FUNCTION: int mvwdelch ( WINDOW* win, int y, int x )

FUNCTION: int ins_wch ( wchar_t ch )
FUNCTION: int wins_wch ( WINDOW* win, wchar_t ch )
FUNCTION: int mvins_wch ( int y, int x, wchar_t ch )
FUNCTION: int mvwins_wch ( WINDOW* win, int y, int x, wchar_t ch )
FUNCTION: int del_wch ( )
FUNCTION: int wdel_wch ( WINDOW* win )
FUNCTION: int mvdel_wch ( int y, int x )
FUNCTION: int mvwdel_wch ( WINDOW* win, int y, int x )

FUNCTION: int ins_wstr ( c-string str )
FUNCTION: int wins_wstr ( WINDOW* win, c-string str )
FUNCTION: int mvins_wstr ( int y, int x, c-string str )
FUNCTION: int mvwins_wstr ( WINDOW* win, int y, int x, c-string str )


FUNCTION: int deleteln ( )
FUNCTION: int wdeleteln ( WINDOW* win )
FUNCTION: int insdelln ( int n )
FUNCTION: int winsdelln ( WINDOW* win, int n )
FUNCTION: int insertln ( )
FUNCTION: int winsertln ( WINDOW* win )

FUNCTION: int addstr ( c-string str )
FUNCTION: int addnstr ( c-string str, int n )
FUNCTION: int waddstr ( WINDOW* win, c-string str )
FUNCTION: int waddnstr ( WINDOW* win, c-string str, int n )
FUNCTION: int mvaddstr ( int y, int x, c-string str )
FUNCTION: int mvaddnstr ( int y, int x, c-string str, int n )
FUNCTION: int mvwaddstr ( WINDOW* win, int y, int x, c-string str )
FUNCTION: int mvwaddnstr ( WINDOW* win, int y, int x, c-string str, int n )

FUNCTION: int addwch ( wchar_t ch )
FUNCTION: int waddwch ( WINDOW* win, wchar_t ch )
FUNCTION: int mvaddwch ( int y, int x, wchar_t ch )
FUNCTION: int mvwaddwch ( WINDOW* win, int y, int x, wchar_t ch )

FUNCTION: int addwstr ( c-string str )
FUNCTION: int addnwstr ( c-string str, int n )
FUNCTION: int waddwstr ( WINDOW* win, c-string str )
FUNCTION: int waddnwstr ( WINDOW* win, c-string str, int n )
FUNCTION: int mvaddwstr ( int y, int x, c-string str )
FUNCTION: int mvaddnwstr ( int y, int x, c-string str, int n )
FUNCTION: int mvwaddwstr ( WINDOW* win, int y, int x, c-string str )
FUNCTION: int mvwaddnwstr ( WINDOW* win, int y, int x, c-string str, int n )

FUNCTION: int waddch ( WINDOW* win, chtype ch )

FUNCTION: int start_color ( )
FUNCTION: int init_pair ( short pair, short f, short b )
FUNCTION: int init_color ( short color, short r, short g, short b )
FUNCTION: bool has_colors ( )
FUNCTION: bool can_change_color ( )
FUNCTION: int color_content ( short color, short* r, short* g, short* b )
FUNCTION: int pair_content ( short pair, short* f, short* b )

FUNCTION: int assume_default_colors ( int fg, int bg )
FUNCTION: int use_default_colors ( )
FUNCTION: int extended_color_content ( short color, short* r, short* g, short* b )
FUNCTION: int extended_pair_content ( short pair, short* fg, short* bg )

C-GLOBAL: int COLORS
C-GLOBAL: int COLOR_PAIRS

: COLOR_PAIR ( n -- n' ) 8 shift ; inline foldable

FUNCTION: int wcolor_set ( WINDOW* win, short color_pair_number, void* opts )

FUNCTION: int wattron ( WINDOW* win, int attrs )
FUNCTION: int wattroff ( WINDOW* win, int attrs )
FUNCTION: int wattrset ( WINDOW* win, int attrs )

: NCURSES_MOUSE_MASK ( b m -- mask ) swap 1 - 6 * shift ; inline

CONSTANT: NCURSES_BUTTON_RELEASED 0o01
CONSTANT: NCURSES_BUTTON_PRESSED  0o02
CONSTANT: NCURSES_BUTTON_CLICKED  0o04
CONSTANT: NCURSES_DOUBLE_CLICKED  0o10
CONSTANT: NCURSES_TRIPLE_CLICKED  0o20
CONSTANT: NCURSES_RESERVED_EVENT  0o40

FUNCTION: int getmouse ( MEVENT* event )
FUNCTION: int ungetmouse ( MEVENT* event )
FUNCTION: mmask_t mousemask ( mmask_t newmask, mmask_t* oldmask )
FUNCTION: bool wenclose ( WINDOW* win, int y, int x )
FUNCTION: bool mouse_trafo ( int* pY, int* pX, bool to_screen )
FUNCTION: bool wmouse_trafo ( WINDOW* win, int* pY, int* pX, bool to_screen )
FUNCTION: int mouseinterval ( int erval )

FUNCTION: int wborder ( WINDOW* win, chtype ls, chtype rs, chtype ts, chtype bs, chtype tl, chtype tr, chtype bl, chtype br )
FUNCTION: int box ( WINDOW* win, chtype verch, chtype horch )
FUNCTION: int whline ( WINDOW* win, chtype ch, int n )
FUNCTION: int wvline ( WINDOW* win, chtype ch, int n )

FUNCTION: bool is_term_resized ( int lines, int columns )
FUNCTION: int resize_term ( int lines, int columns )
FUNCTION: int resizeterm ( int lines, int columns )

C-GLOBAL: int ESCDELAY
