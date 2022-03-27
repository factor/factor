USING: help.markup help.syntax logging.server quotations strings
words ;
IN: logging

HELP: DEBUG
{ $description "Log level for debug messages." } ;

HELP: NOTICE
{ $description "Log level for ordinary messages." } ;

HELP: WARNING
{ $description "Log level for warnings." } ;

HELP: ERROR
{ $description "Log level for error messages." } ;

HELP: CRITICAL
{ $description "Log level for critical errors which require immediate attention." } ;

ARTICLE: "logging.levels" "Log levels"
"Several log levels are supported, from lowest to highest:"
{ $subsections
    DEBUG
    NOTICE
    WARNING
    ERROR
    CRITICAL
} ;

ARTICLE: "logging.files" "Log files"
"Each application that wishes to use logging must choose a log service name; the following combinator should wrap the top level of the application:"
{ $subsections with-logging }
"Log messages are written to " { $snippet "log-root/service/1.log" } ", where"
{ $list
    { { $snippet "log-root" } " is " { $snippet "resource:logs" } " by default, but can be overriden with the " { $link log-root } " variable" }
    { { $snippet "service" } " is the service name" }
}
"You can get the log path for a service:"
{ $subsections
    log-path
    log#
}
"New log entries are always sent to " { $snippet "1.log" } " but " { $link "logging.rotation" } " moves " { $snippet "1.log" } " to " { $snippet "2.log" } ", " { $snippet "2.log" } " to " { $snippet "3.log" } ", and so on." ;

HELP: log-message
{ $values { "msg" string } { "word" word } { "level" "a log level" } }
{ $description "Sends a message to the current log if the level is more urgent than " { $link log-level } ". Does nothing if not executing in a dynamic scope established by " { $link with-logging } "." } ;

HELP: add-logging
{ $values { "word" word } { "level" "a log level" } }
{ $description "Causes the word to log a message every time it is called." } ;

HELP: add-input-logging
{ $values { "word" word } { "level" "a log level" } }
{ $description "Causes the word to log its input values every time it is called. The word must have a stack effect declaration." } ;

HELP: add-output-logging
{ $values { "word" word } { "level" "a log level" } }
{ $description "Causes the word to log its output values every time it is called. The word must have a stack effect declaration." } ;

HELP: add-error-logging
{ $values { "word" word } { "level" "a log level" } }
{ $description "Causes the word to log its input values and any errors it throws."
$nl
"If the word is not executed in a dynamic scope established by " { $link with-logging } ", its behavior is unchanged, and any errors it throws are passed to the caller."
$nl
"If called from a logging context, its input values are logged, and if it throws an error, the error is logged and the word returns normally. Any inputs are popped from the stack and " { $link f } " is pushed in place of each output." } ;

HELP: log-error
{ $values { "error" "an error" } { "word" word } }
{ $description "Logs an error." } ;

HELP: log-critical
{ $values { "error" "an error" } { "word" word } }
{ $description "Logs a critical error." } ;

HELP: LOG:
{ $syntax "LOG: name level" }
{ $values { "name" "a new word name" } { "level" "a log level" } }
{ $description "Creates a word with stack effect " { $snippet "( object -- )" } " which logs its input and does nothing else." } ;

ARTICLE: "logging.messages" "Logging messages"
"Logging messages explicitly:"
{ $subsections
    log-message
    log-error
    log-critical
}
"A utility for defining words which just log and do nothing else:"
{ $subsections POSTPONE: LOG: }
"Annotating words to log; this uses the " { $link "tools.annotations" } " feature:"
{ $subsections
    add-input-logging
    add-output-logging
    add-error-logging
} ;

HELP: rotate-logs
{ $description "Rotates all logs. The highest numbered log file in each log directory is deleted, and each file is renamed so that its number increments by one. Subsequent logging calls will create a new #1 log file. This keeps log files from getting too large and makes them easier to search." } ;

HELP: close-logs
{ $description "Closes all open log streams. Subsequent logging will re-open the streams. This should be used before moving or deleting log files." } ;

HELP: with-logging
{ $values { "service" "a log service name" } { "quot" quotation } }
{ $description "Calls the quotation a new dynamic scope where all logging calls more urgent than " { $link log-level } " are sent to the log file for " { $snippet "service" } "." } ;

ARTICLE: "logging.rotation" "Log rotation"
"Log files should be rotated periodically to prevent unbounded growth."
{ $subsections
    rotate-logs
    close-logs
}
"The " { $vocab-link "logging.insomniac" } " vocabulary automates log rotation." ;

ARTICLE: "logging.server" "Log implementation"
"The " { $vocab-link "logging.server" } " vocabulary implements a concurrent log server using " { $vocab-link "concurrency.messaging" } ". User code never interacts with the server directly, instead it uses the words in the " { $link "logging" } " vocabulary. The server is used to synchronize access to log files and ensure that log rotation can proceed in an orderly fashion."
$nl
"The " { $link log-message } " word sends a message to the server which results in the server executing an internal word:"
{ $subsections (log-message) }
"The " { $link rotate-logs } " word sends a message to the server which results in the server executing an internal word:"
{ $subsections (rotate-logs) }
"The " { $link close-logs } " word sends a message to the server which results in the server executing an internal word:"
{ $subsections (close-logs) } ;

ARTICLE: "logging" "Logging framework"
"The " { $vocab-link "logging" } " vocabulary implements a comprehensive logging framework suitable for server-side production applications."
{ $subsections
    "logging.files"
    "logging.levels"
    "logging.messages"
    "logging.rotation"
    "logging.parser"
    "logging.analysis"
    "logging.server"
} ;

ABOUT: "logging"
