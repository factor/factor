! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax arrays assocs
combinators formatting generalizations kernel lexer libc locals
math math.parser namespaces prettyprint sequences strings
strings.parser words ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  ) 
FUNCTION: void openlog ( c-string ident, int logopt, int facility ) 
FUNCTION: int setlogmask ( int maskpri ) 
FUNCTION: void syslog ( int priority, c-string message ) 
FUNCTION: void vsyslog ( int priority, c-string message, c-string args ) 

IN: pmlog
CONSTANT: PMLogLevelNone      -1
CONSTANT: PMLogLevelEmergency 0
CONSTANT: PMLogLevelAlert     1
CONSTANT: PMLogLevelCritical  2
CONSTANT: PMLogLevelError     3
CONSTANT: PMLogLevelWarning   4
CONSTANT: PMLogLevelNotice    5
CONSTANT: PMLogLevelInfo      6
CONSTANT: PMLogLevelDebug     7
CONSTANT: PMLogLevelDebug1    8
CONSTANT: PMLogLevelDebug2    9
CONSTANT: PMLogLevelTest      99

: PMLOG-Level-String ( level -- string )
    {
        { PMLogLevelNone      [ "None"     ] }
        { PMLogLevelEmergency [ "Emerg"    ] }
        { PMLogLevelAlert     [ "Alert"    ] }
        { PMLogLevelCritical  [ "Critical" ] }
        { PMLogLevelError     [ "Error"    ] }
        { PMLogLevelWarning   [ "Warning"  ] }
        { PMLogLevelNotice    [ "Notice"   ] }
        { PMLogLevelInfo      [ "Info"     ] }
        { PMLogLevelDebug     [ "Debug"    ] }
        { PMLogLevelDebug1    [ "Debug1"   ] }
        { PMLogLevelDebug2    [ "Debug2"   ] }
        { PMLogLevelTest      [ "Test"     ] }
    } case ;
   
SYMBOL: pmLogLevel
pmLogLevel [ PMLogLevelDebug ] initialize

SYMBOL: pmLogLevelIndex
pmLogLevelIndex [ 0 ] initialize

SYMBOL: pmLogStack
pmLogStack [ 256 0 <array> ] initialize

: PMLOG_SetVerbose ( level -- )
    pmLogLevel set
    ;
: PMLOG_PushVerbose ( level -- )
    pmLogLevel get  pmLogLevelIndex get  pmLogStack get  set-nth
    pmLogLevelIndex get  1 +  dup  pmLogLevelIndex set
    255 > [ 255 pmLogLevelIndex set ] when
    pmLogLevel set
    ;
: PMLOG_PopVerbose ( -- )
    pmLogLevelIndex get  1 -  dup  pmLogLevelIndex set
    0 < [ 0 pmLogLevelIndex set ] when
    pmLogLevelIndex get  pmLogStack get  nth
    pmLogLevel set
    ;

:: PMLOG ( msg file word level -- )
    level pmLogLevel get <= 
    level PMLogLevelTest = or
    [ level
      file " " append
      word append
      " " append
      level PMLOG-Level-String append
      " " append
      msg append
      syslog
    ]
    when
;

: PMLOGWITHLEVEL ( msg level -- )
    "loc" word props>> at dup 
    [ [ "PMLOG " [ first ] dip  prepend  ":" append ] keep 
      second number>string append ]
      [ drop "Listener: " ] if
    word name>>  rot
    PMLOG ;

: PMLOGERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend
      prepend PMLogLevelTest PMLOGWITHLEVEL ] if ;

: PMLOGVALUE ( msg value -- )
    number>string " " append
    "Value: " prepend prepend 
    PMLogLevelTest PMLOGWITHLEVEL ;

: level? ( level -- t|f )
    [  pmLogLevel get <= ] keep
    PMLogLevelTest = or ;

: (log) ( level name -- )  +colon-space syslog ;
: (log.) ( name -- )  +colon-space PMLogLevelTest swap syslog ;

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

: (embed-loc) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logloc) suffix! ;

: (embed-inline) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    lexer get skip-blank parse-string suffix!
    \ (logmsg) suffix! ; 

: (embed-string) ( x -- x )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logstring) suffix! ; 


SYNTAX: LOGHERE \ PMLogLevelTest suffix! (embed-loc) ;
SYNTAX: LOGTEST" \ PMLogLevelTest suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: LOGNOTE \ PMLogLevelTest suffix! (embed-string) ;

SYNTAX: LOGDEBUG2 \ PMLogLevelDebug2 suffix! (embed-loc) ;
SYNTAX: LOGDEBUG2" \ PMLogLevelDebug2 suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGDEBUG2 \ PMLogLevelDebug2 suffix! (embed-string) ; 

SYNTAX: LOGDEBUG1 \ PMLogLevelDebug1 suffix! (embed-loc) ;
SYNTAX: LOGDEBUG1" \ PMLogLevelDebug1 suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGDEBUG1 \ PMLogLevelDebug1 suffix! (embed-string) ; 

SYNTAX: LOGDEBUG \ PMLogLevelDebug suffix! (embed-loc) ;
SYNTAX: LOGDEBUG" \ PMLogLevelDebug suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGDEBUG \ PMLogLevelDebug suffix! (embed-string) ; 

SYNTAX: LOGINFO \ PMLogLevelInfo suffix! (embed-loc) ;
SYNTAX: LOGINFO" \ PMLogLevelInfo suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGINFO \ PMLogLevelInfo suffix! (embed-string) ; 

SYNTAX: LOGNOTICE \ PMLogLevelNotice suffix! (embed-loc) ;
SYNTAX: LOGNOTICE" \ PMLogLevelNotice suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGNOTICE \ PMLogLevelNotice suffix! (embed-string) ; 

SYNTAX: LOGWARNING \ PMLogLevelWarning suffix! (embed-loc) ;
SYNTAX: LOGWARNING" \ PMLogLevelWarning suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGWARNING \ PMLogLevelWarning suffix! (embed-string) ; 

SYNTAX: LOGERROR \ PMLogLevelError suffix! (embed-loc) ;
SYNTAX: LOGERROR" \ PMLogLevelError suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGERROR \ PMLogLevelError suffix! (embed-string) ; 

SYNTAX: LOGCRITICAL \ PMLogLevelCritical suffix! (embed-loc) ;
SYNTAX: LOGCRITICAL" \ PMLogLevelCritical suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGCRITICAL \ PMLogLevelCritical suffix! (embed-string) ; 

SYNTAX: LOGALERT \ PMLogLevelAlert suffix! (embed-loc) ;
SYNTAX: LOGALERT" \ PMLogLevelAlert suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGALERT \ PMLogLevelAlert suffix! (embed-string) ; 

SYNTAX: LOGEMERGENCY \ PMLogLevelEmergency suffix! (embed-loc) ;
SYNTAX: LOGEMERGENCY" \ PMLogLevelEmergency suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: >LOGEMERGENCY \ PMLogLevelEmergency suffix! (embed-string) ; 

