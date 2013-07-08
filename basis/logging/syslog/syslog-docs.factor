! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;

IN: syslog

HELP: SYSLOG
{ $values
  { "msg" "string to send to syslog" }
  { "file" "string with path to file and line number" }
  { "word" "word being logged" }
  { "level" "log level" }    
}
{ $description "Sends message along with the file, line number and word to syslogd using the log level." } ;

HELP: SYSLOG-Level-String
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;

HELP: SYSLOGLEVEL-TEST
{ $description "Testing word to send a msg with each production log level. Results should be visible in your syslog." } ;

HELP: SYSLOGWITHLEVEL
{ $values
  { "msg" "string to send to syslog" }
  { "level" "log level" }    
}
{ $description "Sends message to syslogd using the specified log level." } ;

HELP: SYSLOG_ALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: SYSLOG_CRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: SYSLOG_DEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

HELP: SYSLOG_EMERG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } ;

HELP: SYSLOG_ERR
  { $values
    { "msg" "string to send to syslog" }
    { "error" integer }
  } 
  { $description "Conditionally test the error value and sends test message to syslogd regardless of log level." } ;

HELP: SYSLOG_ERROR
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the ERROR log level." } ;

HELP: SYSLOG_HERE
  { $description "Sends test message to syslogd regardless of log level. Commonly used to just verify code is reached" } ;

HELP: SYSLOG_INFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: SYSLOG_NOTE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: SYSLOG_NOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: SYSLOG_PopVerbose
{ $description "Returns log level to previous level" } ;

HELP: SYSLOG_PushVerbose
{ $values
    { "level" integer }    
}
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: SYSLOG_SetVerbose
{ $values
    { "level" integer }    
}
{ $description "Set the current log level." } ;

HELP: SYSLOG_TEST
{ $values { "msg" "string to send to syslog" } }
{ $description "Test message to syslogd regardless of log level." } ;

HELP: SYSLOG_VALUE
{ $values
  { "msg" "string to send to syslog" }
  { "value" integer }
}
  { $description "Test message along with a value to syslogd regardless of log level." } ;

HELP: SYSLOG_WARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

HELP: SYSLogLevelAlert
{ $values
        { "value" integer }
}
{ $description "Value for the ALERT log level" } ;

HELP: SYSLogLevelCritical
{ $values
        { "value" integer }
}
{ $description "Value for the CRITICAL log level" } ;

HELP: SYSLogLevelDebug
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: SYSLogLevelEmerg
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: SYSLogLevelError
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: SYSLogLevelInfo
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: SYSLogLevelNone
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } ;

HELP: SYSLogLevelNotice
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: SYSLogLevelTest
{ $values
        { "value" integer }
}
{ $description "Value for the testing log level, log level is ignored." } ;

HELP: SYSLogLevelWarning
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: SYSTEST
{ $description "Sends log message regardless of logging level. Use this during testing and remove before releasing code." } ;

HELP: sysLogLevel
{ $var-description "Current logging level" }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG_SetVerbose
  SYSLOG_PushVerbose
  SYSLOG_PopVerbose
}
;

HELP: sysLogLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG_SetVerbose
  SYSLOG_PushVerbose
  SYSLOG_PopVerbose
}
  ;

HELP: sysLogStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG_SetVerbose
  SYSLOG_PushVerbose
  SYSLOG_PopVerbose
}
;

ARTICLE: "syslog" "SYSLOG: A vocabulary for creating syslog entries"
"This vocabulary defines words to create syslog entries. The vocabulary behaves basically as you would expect. If the priority level of the message to send to syslogd is less than the global log level value it will be sent, otherwise discarded." $nl

"Message verbosity increases with the log level being invoked with EMERGENCY being the lowest level and highest priority and DEBUG is the highest level and lowest priority" $nl

"This permits leaving logging words in production code to issue messages of interest. The default log level is ERROR. Messages with priority greater than ERROR will not be sent unless the global level is raised." $nl

"During testing several words exist which will issue message regardless of the global level. It is expected you will remove such words before shipping the code"
$nl

"Global Control"
{ $subsections
  sysLogLevel
  SYSLOG_SetVerbose
  SYSLOG_PushVerbose
  SYSLOG_PopVerbose
}

"Log Levels"
{ $subsections
  SYSLogLevelNone      
  SYSLogLevelEmerg     
  SYSLogLevelAlert     
  SYSLogLevelCritical  
  SYSLogLevelError     
  SYSLogLevelWarning   
  SYSLogLevelNotice    
  SYSLogLevelInfo      
  SYSLogLevelDebug     
  SYSLogLevelDebug1    
  SYSLogLevelDebug2    
  SYSLogLevelTest      
}

"Logging Words"
{ $subsections
  SYSLOG_TEST
  SYSLOG_EMERG
  SYSLOG_ALERT
  SYSLOG_CRITICAL
  SYSLOG_ERROR
  SYSLOG_WARNING
  SYSLOG_NOTICE
  SYSLOG_INFO
  SYSLOG_DEBUG
}

"Test Words"
{ $subsections
  SYSLOGWITHLEVEL
  SYSLOG_ERR
  SYSLOG_VALUE
  SYSLOG_NOTE
  SYSLOG_HERE
}


{ $vocab-link "syslog" }
;

ABOUT: "syslog"
