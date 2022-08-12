! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.syntax arrays assocs
combinators formatting io kernel lexer libc literals locals math
math.parser namespaces prettyprint quotations sequences strings
strings.parser words generalizations ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  ) 
FUNCTION: void openlog ( c-string ident, int logopt, int facility ) 
FUNCTION: int setlogmask ( int maskpri ) 
FUNCTION: void syslog ( int priority, c-string message ) 
FUNCTION: void vsyslog ( int priority, c-string message, c-string args ) 

IN: pmlog

CONSTANT: LogLevelNone      -1
CONSTANT: LogLevelEmergency 0
CONSTANT: LogLevelAlert     1
CONSTANT: LogLevelCritical  2
CONSTANT: LogLevelError     3
CONSTANT: LogLevelWarning   4
CONSTANT: LogLevelNotice    5
CONSTANT: LogLevelInfo      6
CONSTANT: LogLevelDebug     7
CONSTANT: LogLevelDebug1    8
CONSTANT: LogLevelDebug2    9
CONSTANT: LogLevelTest      99

: LOG-Level-String ( level -- string )
    {
        { LogLevelNone      [ "None"     ] }
        { LogLevelEmergency [ "Emerg"    ] }
        { LogLevelAlert     [ "Alert"    ] }
        { LogLevelCritical  [ "Critical" ] }
        { LogLevelError     [ "Error"    ] }
        { LogLevelWarning   [ "Warning"  ] }
        { LogLevelNotice    [ "Notice"   ] }
        { LogLevelInfo      [ "Info"     ] }
        { LogLevelDebug     [ "Debug"    ] }
        { LogLevelDebug1    [ "Debug1"   ] }
        { LogLevelDebug2    [ "Debug2"   ] }
        { LogLevelTest      [ "Test"     ] }
    } case ;
   
SYMBOL: LogLevel
LogLevel [ LogLevelDebug ] initialize

SYMBOL: LogLevelIndex
LogLevelIndex [ 0 ] initialize

SYMBOL: LogStack
LogStack [ 256 0 <array> ] initialize

: LOG_SetVerbose ( level -- )
    LogLevel set
    ;

: LOG_PushVerbose ( level -- )
    LogLevel get  LogLevelIndex get  LogStack get  set-nth
    LogLevelIndex get  1 +  dup  LogLevelIndex set
    255 > [ 255 LogLevelIndex set ] when
    LogLevel set
    ;

: LOG_PopVerbose ( -- )
    LogLevelIndex get  1 -  dup  LogLevelIndex set
    0 < [ 0 LogLevelIndex set ] when
    LogLevelIndex get  LogStack get  nth
    LogLevel set
    ;

:: LOG ( msg file word level -- )
    level LogLevel get <= 
    level LogLevelTest = or
    [ level
      file " " append
      word append
      " " append
      level LOG-Level-String append
      " " append
      msg append
      syslog
    ]
    when
;

: LOGWITHLEVEL ( msg level -- )
    ${ last-word } first dup
    props>> "loc" swap at unparse ! file
    [ name>> ] dip ! file word
    rot 
    LOG ; 

: LOG_ERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend
      prepend LogLevelTest LOGWITHLEVEL ] if ;

: LOG_VALUE ( msg value -- )
    number>string " " append
    "Value: " prepend prepend 
    LogLevelTest LOGWITHLEVEL ;

: level? ( level -- t|f )
    [  LogLevel get <= ] keep
    LogLevelTest = or ;

: (log) ( level name -- )  +colon-space syslog ;
: (log.) ( name -- )  +colon-space LogLevelTest swap syslog ;

: (location) ( loc -- string )
    dup
    [ unparse +space ]
    [ drop "no location: " ]
    if ;

: (logloc) ( level name loc -- )
    [ dup level? ] 2dip rot
    [ (location) prepend +space  syslog ]
    [ 2drop drop ] if
    ;

: (logmsg) ( level name loc msg -- )
    [ dup level? ] 3dip 4 nrot
    [ [ (location) prepend +colon-space ] dip ! name+loc level msg
      append  syslog ]
    [ 2drop 2drop ] if
    ;

: (logstring) ( msg level name loc -- )
    (location) 
    [ dup level? ] 2dip rot
    [ prepend  +colon-space  rot append  syslog ]
    [ 2drop 2drop ] if
    ;

: (stuff-loc) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logloc) suffix! ;

: (inline) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    lexer get skip-blank parse-string suffix!
    \ (logmsg) suffix! ; 

: (string) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logstring) suffix! ; 


SYNTAX: LOG_HERE \ LogLevelTest suffix! (stuff-loc) ;
SYNTAX: LOG_NOTE \ LogLevelTest suffix! (string) ;

SYNTAX: LOG_NOTICE \ LogLevelNotice suffix! (stuff-loc) ;
SYNTAX: LOG_NOTICE" \ LogLevelNotice suffix! (inline) ; ! "for the editors sake
SYNTAX: >LOG_NOTICE \ LogLevelNotice suffix! (string) ; ! "for the editors sake

SYNTAX: LOG_INFO \ LogLevelInfo suffix! (stuff-loc) ;
SYNTAX: LOG_INFO" \ LogLevelInfo suffix! (inline) ; ! "for the editors sake
SYNTAX: >LOG_INFO \ LogLevelInfo suffix! (string) ; ! "for the editors sake

SYNTAX: LOG_WARNING \ LogLevelWarning suffix! (stuff-loc) ;
SYNTAX: LOG_WARNING" \ LogLevelWarning suffix! (inline) ; ! "for the editors sake
SYNTAX: >LOG_WARNING \ LogLevelWarning suffix! (string) ; ! "for the editors sake

SYNTAX: LOG_DEBUG \ LogLevelDebug suffix! (stuff-loc) ;
SYNTAX: LOG_DEBUG" \ LogLevelDebug suffix! (inline) ; ! "for the editors sake

SYNTAX: LOG_ERROR \ LogLevelError suffix! (stuff-loc) ;
SYNTAX: LOG_ERROR" \ LogLevelError suffix! (inline) ; ! "for the editors sake

SYNTAX: LOG_CRITICAL \ LogLevelCritical suffix! (stuff-loc) ;
SYNTAX: LOG_CRITICAL" \ LogLevelCritical suffix! (inline) ; ! "for the editors sake

SYNTAX: LOG_ALERT \ LogLevelAlert suffix! (stuff-loc) ;
SYNTAX: LOG_ALERT" \ LogLevelAlert suffix! (inline) ; ! "for the editors sake

SYNTAX: LOG_EMERGENCY \ LogLevelEmergency suffix! (stuff-loc) ;
SYNTAX: LOG_EMERGENCY" \ LogLevelEmergency suffix! (inline) ; ! "for the editors sake
    
