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

IN: syslog

CONSTANT: SYSLogLevelNone      -1
CONSTANT: SYSLogLevelEmerg     0
CONSTANT: SYSLogLevelAlert     1
CONSTANT: SYSLogLevelCritical  2
CONSTANT: SYSLogLevelError     3
CONSTANT: SYSLogLevelWarning   4
CONSTANT: SYSLogLevelNotice    5
CONSTANT: SYSLogLevelInfo      6
CONSTANT: SYSLogLevelDebug     7
CONSTANT: SYSLogLevelDebug1    8
CONSTANT: SYSLogLevelDebug2    9
CONSTANT: SYSLogLevelTest      99

: SYSLOG-Level-String ( level -- string )
    {
        { SYSLogLevelNone      [ "None"     ] }
        { SYSLogLevelEmerg     [ "Emerg"    ] }
        { SYSLogLevelAlert     [ "Alert"    ] }
        { SYSLogLevelCritical  [ "Critical" ] }
        { SYSLogLevelError     [ "Error"    ] }
        { SYSLogLevelWarning   [ "Warning"  ] }
        { SYSLogLevelNotice    [ "Notice"   ] }
        { SYSLogLevelInfo      [ "Info"     ] }
        { SYSLogLevelDebug     [ "Debug"    ] }
        { SYSLogLevelDebug1    [ "Debug1"   ] }
        { SYSLogLevelDebug2    [ "Debug2"   ] }
        { SYSLogLevelTest      [ "Test"     ] }
    } case ;
   
SYMBOL: sysLogLevel
sysLogLevel [ SYSLogLevelError ] initialize

SYMBOL: sysLogLevelIndex
sysLogLevelIndex [ 0 ] initialize

SYMBOL: sysLogStack
sysLogStack [ 256 0 <array> ] initialize

: SYSLOG_SetVerbose ( level -- )
    sysLogLevel set
    ;
: SYSLOG_PushVerbose ( level -- )
    sysLogLevel get  sysLogLevelIndex get  sysLogStack get  set-nth
    sysLogLevelIndex get  1 +  dup  sysLogLevelIndex set
    255 > [ 255 sysLogLevelIndex set ] when
    sysLogLevel set
    ;
: SYSLOG_PopVerbose ( -- )
    sysLogLevelIndex get  1 -  dup  sysLogLevelIndex set
    0 < [ 0 sysLogLevelIndex set ] when
    sysLogLevelIndex get  sysLogStack get  nth
    sysLogLevel set
    ;

:: (SYSLOG) ( msg file word level -- )
    level sysLogLevel get <= 
    level SYSLogLevelTest = or
    [ level
      file " " append
      word append
      " " append
      level SYSLOG-Level-String append
      " " append
      msg append
      syslog
    ]
    when
;

: SYSLOGWITHLEVEL ( msg level -- )
    "loc" word props>> at dup 
    [ [ "SYSLOG " [ first ] dip  prepend  ":" append ] keep 
      second number>string append ]
      [ drop "Listener: " ] if
    word name>>  rot
   (SYSLOG) ;

: SYSLOG_ERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend
      prepend SYSLogLevelTest SYSLOGWITHLEVEL ] if ;
: SYSLOG_VALUE ( msg value -- )
    number>string  "Value: " prepend prepend 
    SYSLogLevelTest SYSLOGWITHLEVEL ;
: SYSLOG_NOTE ( msg -- )
    "NOTE: " prepend
    SYSLogLevelTest SYSLOGWITHLEVEL ;
: SYSLOG_HERE ( -- )
    "" SYSLogLevelTest SYSLOGWITHLEVEL ;
: SYSLOG_TEST ( msg -- )
    SYSLogLevelTest SYSLOGWITHLEVEL ;
: SYSLOG ( format-string -- )
    sprintf
    SYSLOG_TEST ; inline


: SYSLOG_EMERG ( msg -- )
    SYSLogLevelEmerg SYSLOGWITHLEVEL ;
: SYSLOG_ALERT ( msg -- )
    SYSLogLevelAlert SYSLOGWITHLEVEL ;
: SYSLOG_CRITICAL ( msg -- )
    SYSLogLevelCritical SYSLOGWITHLEVEL ;
: SYSLOG_ERROR ( msg -- )
    SYSLogLevelError SYSLOGWITHLEVEL ;
: SYSLOG_WARNING ( msg -- )
    SYSLogLevelWarning SYSLOGWITHLEVEL ;
: SYSLOG_NOTICE ( msg -- )
    SYSLogLevelNotice SYSLOGWITHLEVEL ;
: SYSLOG_INFO ( msg -- )
    SYSLogLevelInfo SYSLOGWITHLEVEL ;
: SYSLOG_DEBUG ( msg -- )
    SYSLogLevelDebug SYSLOGWITHLEVEL ;

: SYSLOGLEVEL-TEST ( -- )
    "Emergency" SYSLOG_EMERG
    "Alert" SYSLOG_ALERT
    "Critical" SYSLOG_CRITICAL
    "Error" SYSLOG_ERROR
    "Warning" SYSLOG_WARNING
    "Notice" SYSLOG_NOTICE
    "Info" SYSLOG_INFO
    "Debug" SYSLOG_DEBUG
;

: SYSTEST ( -- )
    SYSLOG_HERE
    "Testing 1 2 3" SYSLOG_TEST
    10 iota 
    [ dup
      SYSLOG_PushVerbose
      "Log Level: %d\n" sprintf SYSLOG_NOTE
      SYSLOGLEVEL-TEST
      SYSLOG_PopVerbose
    ] each
    "This is a problem" 32 SYSLOG_ERR
    "Test note" SYSLOG_NOTE
    "This is a value" -1 SYSLOG_VALUE
    ;