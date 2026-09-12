IN: logging.server
USING: help.markup help.syntax ;

HELP: max-log-size
{ $var-description "Log file size threshold in bytes, defaulting to 10 MiB. Set this variable globally. Before writing a message to a file at or above this size, the log server rotates that service's files, retaining at most ten numbered files. A single message is never split between files, so the threshold may be exceeded by one message. Set to f to disable size-based rotation." } ;

ABOUT: "logging.server"
