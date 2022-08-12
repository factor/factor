! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;

IN: syslog

HELP: LOG
{ $values
  { "msg" "string to send to syslog" }
  { "file" "string with path to file and line number" }
  { "word" "word being logged" }
  { "level" "log level" }    
}
{ $description "Sends message along with the file, line number and word to syslogd using the log level." } ;

HELP: LOG-Level-String
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;

HELP: LOGWITHLEVEL
{ $values
  { "msg" "string to send to syslog" }
  { "level" "log level" }    
}
{ $description "Sends message to syslogd using the specified log level." } ;

HELP: LOG_ALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: LOG_CRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: LOG_DEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

HELP: LOG_EMERGENCY
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } ;

HELP: LOG_ERROR
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the ERROR log level." } ;

HELP: LOG_HERE
  { $description "Sends test message to syslogd regardless of log level. Commonly used to just verify code is reached" } ;

HELP: LOG_INFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: LOG_NOTE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: LOG_NOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: LOG_PopVerbose
{ $description "Returns log level to previous level" } ;

HELP: LOG_PushVerbose
{ $values
    { "level" integer }    
}
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: LOG_SetVerbose
{ $values
    { "level" integer }    
}
{ $description "Set the current log level." } ;

HELP: LOG_WARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

HELP: LogLevelAlert
{ $values
        { "value" integer }
}
{ $description "Value for the ALERT log level" } ;

HELP: LogLevelCritical
{ $values
        { "value" integer }
}
{ $description "Value for the CRITICAL log level" } ;

HELP: LogLevelDebug
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: LogLevelEmergency
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: LogLevelError
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: LogLevelInfo
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: LogLevelNone
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } ;

HELP: LogLevelNotice
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: LogLevelTest
{ $values
        { "value" integer }
}
{ $description "Value for the testing log level, log level is ignored." } ;

HELP: LogLevelWarning
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: LogLevel
{ $var-description "Current logging level" }
{ $see-also
  LogLevel
  LogStack
  LogLevelIndex
  LOG_SetVerbose
  LOG_PushVerbose
  LOG_PopVerbose
}
;

HELP: LogLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  LogLevel
  LogStack
  LogLevelIndex
  LOG_SetVerbose
  LOG_PushVerbose
  LOG_PopVerbose
}
  ;

HELP: LogStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  LogLevel
  LogStack
  LogLevelIndex
  LOG_SetVerbose
  LOG_PushVerbose
  LOG_PopVerbose
}
;

ARTICLE: "log" "LOG: A vocabulary for creating syslog entries"
"This vocabulary defines words to create syslog entries. The vocabulary behaves basically as you would expect. If the priority level of the message to send to syslogd is less than the global log level value it will be sent, otherwise discarded." $nl

"Message verbosity increases with the log level being invoked with EMERGENCY being the lowest level and highest priority and DEBUG is the highest level and lowest priority" $nl

"This permits leaving logging words in production code to issue messages of interest. The default log level is ERROR. Messages with priority greater than ERROR will not be sent unless the global level is raised." $nl

"During testing several words exist which will issue message regardless of the global level. It is expected you will remove such words before shipping the code"
$nl

"Global Control"
{ $subsections
  LogLevel
  LOG_SetVerbose
  LOG_PushVerbose
  LOG_PopVerbose
}

"Log Levels"
{ $subsections
  LogLevelNone      
  LogLevelEmergency     
  LogLevelAlert     
  LogLevelCritical  
  LogLevelError     
  LogLevelWarning   
  LogLevelNotice    
  LogLevelInfo      
  LogLevelDebug     
  LogLevelDebug1    
  LogLevelDebug2    
  LogLevelTest      
}

"Logging Words"
{ $subsections
  LOG_NOTE
  LOG_EMERGENCY
  LOG_ALERT
  LOG_CRITICAL
  LOG_ERROR
  LOG_WARNING
  LOG_NOTICE
  LOG_INFO
  LOG_DEBUG
}

"Test Words"
{ $subsections
  LOGWITHLEVEL
  LOG_ERR
  LOG_NOTE
  LOG_HERE
}


{ $vocab-link "log" }
;

ABOUT: "syslog"
