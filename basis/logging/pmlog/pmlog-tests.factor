! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test pmlog ;
IN: pmlog.tests

: PMLOGTEST ( msg -- )
    PMLogLevelTest PMLOGWITHLEVEL ;

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
