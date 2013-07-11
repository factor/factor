SYSLOG
======

Syslog vocabulary for Factor

This vocabulary defines words to create syslog entries. The vocabulary behaves basically as you would expect. If the priority level of the message to send to syslogd is less than the global log level value it will be sent, otherwise discarded. 

Message verbosity increases with the log level being invoked with EMERGENCY being the lowest level and highest priority and DEBUG is the highest level and lowest priority 

This permits leaving logging words in production code to issue messages of interest. The default log level is ERROR. Messages with priority greater than ERROR will not be sent unless the global level is raised. 

During testing several words exist which will issue message regardless of the global level. It is expected you will remove such words before shipping the code

See vocabulary help for details:
`"pmlog" help`
