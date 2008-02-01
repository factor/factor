IN: io.monitor
USING: help.markup help.syntax continuations ;

HELP: <monitor>
{ $values { "path" "a pathname string" } { "recursive?" "a boolean" } }
{ $description "Opens a file system change monitor which listens for changes on " { $snippet "path" } ". The boolean indicates whether changes in subdirectories should be reported."
$nl
"Not all operating systems support recursive monitors; if recursive monitoring is not available, an error is thrown and the caller must implement alternative logic for monitoring subdirectories." } ;

HELP: next-change
{ $values { "monitor" "a monitor" } { "path" "a pathname string" } { "changes" "a sequence of change descriptors" } }
{ $description "Waits for file system changes and outputs the pathname of the first changed file. The change descriptor is a sequence containing at least one change descriptor; see " { $link "io.monitor.descriptors" } "." } ;

HELP: with-monitor
{ $values { "path" "a pathname string" } { "recursive?" "a boolean" } { "quot" "a quotation with stack effect " { $snippet "( monitor -- )" } } }
{ $description "Opens a file system change monitor and passes it to the quotation. Closes the monitor after the quotation returns or throws an error." } ;

HELP: +change-file+
{ $description "Indicates that the contents of the file have changed." } ;

HELP: +change-name+
{ $description "Indicates that the file name has changed." } ;

HELP: +change-size+
{ $description "Indicates that the file size has changed." } ;

HELP: +change-attributes+
{ $description "Indicates that file attributes has changed. Attributes are operating system-specific but may include the creation time and permissions." } ;

HELP: +change-modified+
{ $description "Indicates that the last modification time of the file has changed." } ;

ARTICLE: "io.monitor.descriptors" "File system change descriptors"
"Change descriptors output by " { $link next-change } ":"
{ $subsection +change-file+ }
{ $subsection +change-name+ }
{ $subsection +change-size+ }
{ $subsection +change-attributes+ }
{ $subsection +change-modified+ } ;

ARTICLE: "io.monitor" "File system change monitors"
"File system change monitors listen for changes to file names, attributes and contents under a specified directory. They can optionally be recursive, in which case subdirectories are also monitored."
$nl
"Creating a file system change monitor and listening for changes:"
{ $subsection <monitor> }
{ $subsection next-change }
{ $subsection "io.monitor.descriptors" }
"Monitors are closed by calling " { $link dispose } " or " { $link with-disposal } "."
$nl
"A utility combinator which opens a monitor and cleans it up after:"
{ $subsection with-monitor }
"An example which watches the Factor directory for changes:"
{ $code
    "USE: io.monitor"
    ": watch-loop ( monitor -- )"
    "    dup next-change . . nl nl flush watch-loop ;"
    ""
    "\"\" resource-path f [ watch-loop ] with-monitor"
} ;

ABOUT: "io.monitor"
