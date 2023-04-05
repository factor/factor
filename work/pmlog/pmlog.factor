! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types accessors arrays assocs kernel libc locals math math.parser namespaces
formatting sequences words combinators ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  ) ;
FUNCTION: void openlog ( c-string ident, int logopt, int facility ) ;
FUNCTION: int setlogmask ( int maskpri ) ;
FUNCTION: void syslog ( int priority, c-string message ) ;
FUNCTION: void vsyslog ( int priority, c-string message, c-string args ) ;

IN: pmlog

CONSTANT: PMLogLevelNone      -1
CONSTANT: PMLogLevelEmerg     0
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
        { PMLogLevelEmerg     [ "Emerg"    ] }
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
pmLogLevel [ PMLogLevelError ] initialize

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

: PMLOG_ERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend
      prepend PMLogLevelTest PMLOGWITHLEVEL ] if ;
: PMLOG_VALUE ( msg value -- )
    number>string  "Value: " prepend prepend 
    PMLogLevelTest PMLOGWITHLEVEL ;
: PMLOG_NOTE ( msg -- )
    "NOTE: " prepend
    PMLogLevelTest PMLOGWITHLEVEL ;
: PMLOG_HERE ( -- )
    "" PMLogLevelTest PMLOGWITHLEVEL ;
: PMLOG_TEST ( msg -- )
    PMLogLevelTest PMLOGWITHLEVEL ;

: PMLOG_EMERG ( msg -- )
    PMLogLevelEmerg PMLOGWITHLEVEL ;
: PMLOG_ALERT ( msg -- )
    PMLogLevelAlert PMLOGWITHLEVEL ;
: PMLOG_CRITICAL ( msg -- )
    PMLogLevelCritical PMLOGWITHLEVEL ;
: PMLOG_ERROR ( msg -- )
    PMLogLevelError PMLOGWITHLEVEL ;
: PMLOG_WARNING ( msg -- )
    PMLogLevelWarning PMLOGWITHLEVEL ;
: PMLOG_NOTICE ( msg -- )
    PMLogLevelNotice PMLOGWITHLEVEL ;
: PMLOG_INFO ( msg -- )
    PMLogLevelInfo PMLOGWITHLEVEL ;
: PMLOG_DEBUG ( msg -- )
    PMLogLevelDebug PMLOGWITHLEVEL ;

: PMLOGLEVEL-TEST ( -- )
    "Emergency" PMLOG_EMERG
    "Alert" PMLOG_ALERT
    "Critical" PMLOG_CRITICAL
    "Error" PMLOG_ERROR
    "Warning" PMLOG_WARNING
    "Notice" PMLOG_NOTICE
    "Info" PMLOG_INFO
    "Debug" PMLOG_DEBUG
;

: PMTEST ( -- )
    PMLOG_HERE
    "Testing 1 2 3" PMLOG_TEST
    10 iota 
    [ dup
      PMLOG_PushVerbose
      "Log Level: %d\n" sprintf PMLOG_NOTE
      PMLOGLEVEL-TEST
      PMLOG_PopVerbose
    ] each
    "This is a problem" 32 PMLOG_ERR
    "Test note" PMLOG_NOTE
    "This is a value" -1 PMLOG_VALUE
    ;