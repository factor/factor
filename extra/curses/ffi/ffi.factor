! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.syntax combinators kernel system
alien.libraries ;
IN: curses.ffi

<< "curses" {
    { [ os winnt? ]  [ "libcurses.dll" ] }
    { [ os macosx? ] [ "libcurses.dylib" ] }
    { [ os unix?  ]  [ "libcurses.so" ] }
} cond "cdecl" add-library >>

TYPEDEF: void* WINDOW*
TYPEDEF: void* SCREEN*
TYPEDEF: void* va_list

TYPEDEF: uint chtype
TYPEDEF: chtype attr_t
TYPEDEF: short NCURSES_SIZE_T
TYPEDEF: ushort wchar_t

CONSTANT: CCHARW_MAX  5

C-STRUCT: cchar_t
    { "attr_t" "attr" }
    { { "wchar_t" CCHARW_MAX } "chars" } ;

C-STRUCT: pdat
    { "NCURSES_SIZE_T" "_pad_y" }
    { "NCURSES_SIZE_T" "_pad_x" }
    { "NCURSES_SIZE_T" "_pad_top" }
    { "NCURSES_SIZE_T" "_pad_left" }
    { "NCURSES_SIZE_T" "_pad_bottom" }
    { "NCURSES_SIZE_T" "_pad_right" } ;

C-STRUCT: c-window
    { "NCURSES_SIZE_T" "_cury" }
    { "NCURSES_SIZE_T" "_curx" }

    { "NCURSES_SIZE_T" "_maxy" }
    { "NCURSES_SIZE_T" "_maxx" }
    { "NCURSES_SIZE_T" "_begy" }
    { "NCURSES_SIZE_T" "_begx" }

    { "short"  " _flags" }

    { "attr_t"  "_attrs" }
    { "chtype"  "_bkgd" }

    { "bool"    "_notimeout" }
    { "bool"    "_clear" }
    { "bool"    "_leaveok" }
    { "bool"    "_scroll" }
    { "bool"    "_idlok" }
    { "bool"    "_idcok" }
    { "bool"    "_immed" }
    { "bool"    "_sync" }
    { "bool"    "_use_keypad" }
    { "int"     "_delay" }

    { "char*" "_line" }
    { "NCURSES_SIZE_T" "_regtop" }
    { "NCURSES_SIZE_T" "_regbottom" }

    { "int" "_parx" }
    { "int" "_pary" }
    { "WINDOW*" "_parent" }

    { "pdat" "_pad" }

    { "NCURSES_SIZE_T" "_yoffset" }

    { "cchar_t"  "_bkgrnd" } ;

LIBRARY: curses

: stdscr ( -- alien )
    "stdscr" "curses" library dll>> dlsym ;

FUNCTION: WINDOW* initscr ( ) ;
FUNCTION: int endwin ( ) ;
FUNCTION: bool isendwin ( ) ;
FUNCTION: SCREEN* newterm ( char* type, FILE* outfd, FILE* infd ) ;
FUNCTION: SCREEN* set_term ( SCREEN* new ) ;
FUNCTION: void delscreen ( SCREEN* sp ) ;

FUNCTION: int def_prog_mode ( ) ;
FUNCTION: int def_shell_mode ( ) ;
FUNCTION: int reset_prog_mode ( ) ;
FUNCTION: int reset_shell_mode ( ) ;
FUNCTION: int resetty ( ) ;
FUNCTION: int savetty ( ) ;
FUNCTION: int ripoffline ( int line, void* callback ) ;
FUNCTION: int curs_set ( int visibility ) ;
FUNCTION: int napms ( int ms ) ;

FUNCTION: WINDOW* newwin ( int nlines, int ncols, int begin_y, int begin_x ) ;
FUNCTION: int delwin ( WINDOW* win ) ;
FUNCTION: int mvwin ( WINDOW* win, int y, int x ) ;
FUNCTION: WINDOW* subwin ( WINDOW* orig, int nlines, int ncols, int begin_y, int begin_x ) ;
FUNCTION: WINDOW* derwin ( WINDOW* orig, int nlines, int ncols, int begin_y, int begin_x ) ;
FUNCTION: int mvderwin ( WINDOW* win, int par_y, int par_x ) ;
FUNCTION: WINDOW* dupwin ( WINDOW* win ) ;
FUNCTION: void wsyncup ( WINDOW* win ) ;
FUNCTION: int syncok ( WINDOW* win, bool bf ) ;
FUNCTION: void wcursyncup ( WINDOW* win ) ;
FUNCTION: void wsyncdown ( WINDOW* win ) ;

FUNCTION: int cbreak ( ) ;
FUNCTION: int nocbreak ( ) ;
FUNCTION: int echo ( ) ;
FUNCTION: int noecho ( ) ;
FUNCTION: int halfdelay ( int tenths ) ;
FUNCTION: int intrflush ( WINDOW* win, bool bf ) ;
FUNCTION: int keypad ( WINDOW* win, bool bf ) ;
FUNCTION: int meta ( WINDOW* win, bool bf ) ;
FUNCTION: int nodelay ( WINDOW* win, bool bf ) ;
FUNCTION: int raw ( ) ;
FUNCTION: int noraw ( ) ;
FUNCTION: void noqiflush ( ) ;
FUNCTION: void qiflush ( ) ;
FUNCTION: int notimeout ( WINDOW* win, bool bf ) ;
FUNCTION: void timeout ( int delay ) ;
FUNCTION: void wtimeout ( WINDOW* win, int delay ) ;
FUNCTION: int typeahead ( int fd ) ;

FUNCTION: int clearok ( WINDOW* win, bool bf ) ;
FUNCTION: int idlok ( WINDOW* win, bool bf ) ;
FUNCTION: void idcok ( WINDOW* win, bool bf ) ;
FUNCTION: void immedok ( WINDOW* win, bool bf ) ;
FUNCTION: int leaveok ( WINDOW* win, bool bf ) ;
FUNCTION: int setscrreg ( int top, int bot ) ;
FUNCTION: int wsetscrreg ( WINDOW* win, int top, int bot ) ;
FUNCTION: int scrollok ( WINDOW* win, bool bf ) ;
FUNCTION: int nl ( ) ;
FUNCTION: int nonl ( ) ;

FUNCTION: int erase (  ) ;
FUNCTION: int werase ( WINDOW* win ) ;
FUNCTION: int clear (  ) ;
FUNCTION: int wclear ( WINDOW* win ) ;
FUNCTION: int clrtobot (  ) ;
FUNCTION: int wclrtobot ( WINDOW* win ) ;
FUNCTION: int clrtoeol (  ) ;
FUNCTION: int wclrtoeol ( WINDOW* win ) ;

FUNCTION: int refresh ( ) ;
FUNCTION: int wrefresh ( WINDOW* win ) ;
FUNCTION: int wnoutrefresh ( WINDOW* win ) ;
FUNCTION: int doupdate ( ) ;
FUNCTION: int redrawwin ( WINDOW* win ) ;
FUNCTION: int wredrawln ( WINDOW* win, int beg_line, int num_lines ) ;

FUNCTION: int getch ( ) ;
FUNCTION: int wgetch ( WINDOW* win ) ;
FUNCTION: int mvgetch ( int y, int x ) ;
FUNCTION: int mvwgetch ( WINDOW* win, int y, int x ) ;
FUNCTION: int ungetch ( int ch ) ;
FUNCTION: int has_key ( int ch ) ;

FUNCTION: int getstr ( char* str ) ;
FUNCTION: int getnstr ( char* str, int n ) ;
FUNCTION: int wgetstr ( WINDOW* win, char* str ) ;
FUNCTION: int wgetnstr ( WINDOW* win, char* str, int n ) ;
FUNCTION: int mvgetstr ( int y, int x, char* str ) ;
FUNCTION: int mvwgetstr ( WINDOW* win, int y, int x, char* str ) ;
FUNCTION: int mvgetnstr ( int y, int x, char* str, int n ) ;
FUNCTION: int mvwgetnstr ( WINDOW* win, int y, int x, char* str, int n ) ;

FUNCTION: int printw ( char* fmt, int lol ) ;
FUNCTION: int wprintw ( WINDOW* win, char* fmt, int lol ) ;
FUNCTION: int mvprintw ( int y, int x, char* fmt, int lol ) ;
FUNCTION: int mvwprintw ( WINDOW* win, int y, int x, char* fmt, int lol ) ;
FUNCTION: int vwprintw ( WINDOW* win, char* fmt, va_list varglist ) ;
FUNCTION: int vw_printw ( WINDOW* win, char* fmt, va_list varglist ) ;

FUNCTION: int move ( int y, int x ) ;
FUNCTION: int wmove ( WINDOW* win, int y, int x ) ;


FUNCTION: int scroll ( WINDOW* win ) ;
FUNCTION: int scrl ( int n ) ;
FUNCTION: int wscrl ( WINDOW* win, int n ) ;

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
FUNCTION: int mvcur ( int oldrow, int oldcol, int newrow, int newcol ) ;
       ! int tigetflag(char *capname);
       ! int tigetnum(char *capname);
       ! char *tigetstr(char *capname);

FUNCTION: int touchwin ( WINDOW* win ) ;
FUNCTION: int touchline ( WINDOW* win, int start, int count ) ;
FUNCTION: int untouchwin ( WINDOW* win ) ;
FUNCTION: int wtouchln ( WINDOW* win, int y, int n, int changed ) ;
FUNCTION: bool is_linetouched ( WINDOW* win, int line ) ;
FUNCTION: bool is_wintouched ( WINDOW* win ) ;

FUNCTION: int insch ( chtype ch ) ;
FUNCTION: int winsch ( WINDOW* win, chtype ch ) ;
FUNCTION: int mvinsch ( int y, int x, chtype ch ) ;
FUNCTION: int mvwinsch ( WINDOW* win, int y, int x, chtype ch ) ;
FUNCTION: int delch ( ) ;
FUNCTION: int wdelch ( WINDOW* win ) ;
FUNCTION: int mvdelch ( int y, int x ) ;
FUNCTION: int mvwdelch ( WINDOW* win, int y, int x ) ;

FUNCTION: int deleteln ( ) ;
FUNCTION: int wdeleteln ( WINDOW* win ) ;
FUNCTION: int insdelln ( int n ) ;
FUNCTION: int winsdelln ( WINDOW* win, int n ) ;
FUNCTION: int insertln ( ) ;
FUNCTION: int winsertln ( WINDOW* win ) ;

FUNCTION: int addstr ( char* str ) ;
FUNCTION: int addnstr ( char* str, int n ) ;
FUNCTION: int waddstr ( WINDOW* win, char* str ) ;
FUNCTION: int waddnstr ( WINDOW* win, char* str, int n ) ;
FUNCTION: int mvaddstr ( int y, int x, char* str ) ;
FUNCTION: int mvaddnstr ( int y, int x, char* str, int n ) ;
FUNCTION: int mvwaddstr ( WINDOW* win, int y, int x, char* str ) ;
FUNCTION: int mvwaddnstr ( WINDOW* win, int y, int x, char* str, int n ) ;
