USING: help.markup help.syntax ;
IN: curses.ffi

ARTICLE: "curses.ffi.varargs" "Curses variadic functions"
"The bindings for " { $link printw } ", " { $link wprintw } ", " { $link mvprintw } " and " { $link mvwprintw } " each accept one integer formatting argument. Their existing stack effects are preserved, and the integer is passed through the C variadic ABI. The format string must describe that argument, for example " { $snippet "%d" } "."
$nl
"Declare a typed alias when a format needs a different argument list. Put the ellipsis immediately after the named format parameter:"
{ $code
    "USING: alien.c-types alien.syntax curses.ffi ;"
    "LIBRARY: curses"
    "FUNCTION-ALIAS: wprintw-values int wprintw ( WINDOW* win, c-string fmt, ... c-string text, double value, int count )"
    "! win \"%s=%.2f/%d\" \"value\" 1.25 7 wprintw-values"
    "FUNCTION-ALIAS: wprintw-literal int wprintw ( WINDOW* win, c-string fmt, ... )"
}
"Types after the ellipsis describe the arguments for that alias; they do not make its Factor stack effect dynamic. Use a separate alias for each required signature. A " { $snippet "float" } " tail undergoes the C default promotion to " { $snippet "double" } ", and narrow integer tails promote to " { $snippet "int" } "."
$nl
"The " { $link tparm } " binding instantiates an ncurses terminfo capability with nine " { $snippet "long" } " parameters. Pass zero for unused parameters. For a shorter parameter list, or capabilities that require strings, declare the matching types explicitly:"
{ $code
    "FUNCTION-ALIAS: tparm-position c-string tparm ( c-string capability, ... long row, long column )"
    "FUNCTION-ALIAS: tparm-text c-string tparm ( c-string capability, ... c-string text )"
}
"The capability expression determines the argument types; printf format strings and terminfo expressions use different syntax. The returned string is copied into a Factor string. Initialize terminfo with a curses screen before using capabilities."
$nl
"The " { $link vw_printw } " and legacy " { $link vwprintw } " functions take an existing " { $snippet "va_list" } " as an ordinary named parameter. They do not receive an ellipsis argument list."
$nl
"Reference: " { $url "https://invisible-island.net/ncurses/man/curs_printw.3x.html" } " and " { $url "https://invisible-island.net/ncurses/man/curs_terminfo.3x.html" } "." ;

ABOUT: "curses.ffi.varargs"
