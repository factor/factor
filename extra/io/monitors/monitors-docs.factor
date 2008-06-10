IN: io.monitors
USING: help.markup help.syntax continuations destructors
concurrency.mailboxes quotations ;

HELP: with-monitors
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope where file system monitor operations can be performed." }
{ $errors "Throws an error if the platform does not support file system change monitors." } ;

HELP: <monitor>
{ $values { "path" "a pathname string" } { "recursive?" "a boolean" } { "monitor" "a new monitor" } }
{ $contract "Opens a file system change monitor which listens for changes on " { $snippet "path" } ". The boolean indicates whether changes in subdirectories should be reported." }
{ $errors "Throws an error if the pathname does not exist, if a monitor could not be created or if the platform does not support monitors." } ;

HELP: (monitor)
{ $values { "path" "a pathname string" } { "recursive?" "a boolean" } { "mailbox" mailbox } { "monitor" "a new monitor" } }
{ $contract "Opens a file system change monitor which listens for changes on " { $snippet "path" } " and posts notifications to " { $snippet "mailbox" } " as triples with shape " { $snippet "{ path changed monitor } " } ". The boolean indicates whether changes in subdirectories should be reported." }
{ $errors "Throws an error if the pathname does not exist, if a monitor could not be created or if the platform does not support monitors." } ;

HELP: next-change
{ $values { "monitor" "a monitor" } { "path" "a pathname string" } { "changed" "a change descriptor" } }
{ $contract "Waits for file system changes and outputs the pathname of the first changed file. The change descriptor is a sequence of symbols documented in " { $link "io.monitors.descriptors" } "." }
{ $errors "Throws an error if the monitor is closed from another thread." } ;

HELP: with-monitor
{ $values { "path" "a pathname string" } { "recursive?" "a boolean" } { "quot" "a quotation with stack effect " { $snippet "( monitor -- )" } } }
{ $description "Opens a file system change monitor and passes it to the quotation. Closes the monitor after the quotation returns or throws an error." }
{ $errors "Throws an error if the pathname does not exist, if a monitor could not be created or if the platform does not support monitors." } ;

HELP: +add-file+
{ $description "Indicates that a file has been added to its parent directory." } ;

HELP: +remove-file+
{ $description "Indicates that a file has been removed from its parent directory." } ;

HELP: +modify-file+
{ $description "Indicates that a file's contents have changed." } ;

HELP: +rename-file-old+
{ $description "Indicates that a file has been renamed, and this is the old name." } ;

HELP: +rename-file-new+
{ $description "Indicates that a file has been renamed, and this is the new name." } ;

HELP: +rename-file+
{ $description "Indicates that a file has been renamed." } ;

ARTICLE: "io.monitors.descriptors" "File system change descriptors"
"Change descriptors output by " { $link next-change } ":"
{ $subsection +add-file+ }
{ $subsection +remove-file+ }
{ $subsection +modify-file+ }
{ $subsection +rename-file-old+ }
{ $subsection +rename-file-new+ }
{ $subsection +rename-file+ } ;

ARTICLE: "io.monitors.platforms" "Monitors on different platforms"
"Whether the " { $snippet "path" } " output value of " { $link next-change } " contains an absolute path or a path relative to the path given to " { $link <monitor> } " is platform-specific. User code should not assume either case."
{ $heading "Mac OS X" }
"Factor uses " { $snippet "FSEventStream" } "s to implement monitors on Mac OS X. This requires Mac OS X 10.5 or later."
$nl
{ $snippet "FSEventStream" } "s always monitor directory hierarchies recursively, and the " { $snippet "recursive?" } " parameter to " { $link <monitor> } " has no effect."
$nl
"The " { $snippet "changed" } " output value of the " { $link next-change } " word always outputs " { $link +modify-file+ } " and the " { $snippet "path" } " output value is always the directory containing the file that changed. Unlike other platforms, fine-grained information is not available."
{ $heading "Windows" }
"Factor uses " { $snippet "ReadDirectoryChanges" } " to implement monitors on Windows."
$nl
"Both recursive and non-recursive monitors are directly supported by the operating system."
{ $heading "Linux" }
"Factor uses " { $snippet "inotify" } " to implement monitors on Linux. This requires Linux kernel version 2.6.16 or later."
$nl
"Factor simulates recursive monitors by creating a hierarchy of monitors for every subdirectory, since " { $snippet "inotify" } " can only monitor a single directory. This is transparent to user code."
$nl
"Inside a single " { $link with-monitors } " scope, only one monitor may be created for any given directory."
{ $heading "BSD" }
"Factor uses " { $snippet "kqueue" } " to implement monitors on BSD."
$nl
"The " { $snippet "kqueue" } " system is limited to monitoring individual files and directories. Monitoring a directory only notifies of files being added and removed to the directory itself, not of changes to file contents."
{ $heading "Windows CE" }
"Windows CE does not support monitors." ;

ARTICLE: "io.monitors" "File system change monitors"
"File system change monitors listen for changes to file names, attributes and contents under a specified directory. They can optionally be recursive, in which case subdirectories are also monitored."
$nl
"Monitoring operations must be wrapped in a combinator:"
{ $subsection with-monitors }
"Creating a file system change monitor and listening for changes:"
{ $subsection <monitor> }
{ $subsection next-change }
"An alternative programming style is where instead of having a thread listen for changes on a monitor, change notifications are posted to a mailbox:"
{ $subsection (monitor) }
{ $subsection "io.monitors.descriptors" }
{ $subsection "io.monitors.platforms" } 
"Monitors are closed by calling " { $link dispose } " or " { $link with-disposal } ". An easy way to pair construction with disposal is to use a combinator:"
{ $subsection with-monitor }
"Monitors support the " { $link "io.timeouts" } "."
$nl
"An example which watches a directory for changes:"
{ $code
    "USE: io.monitors"
    ": watch-loop ( monitor -- )"
    "    dup next-change . . nl nl flush watch-loop ;"
    ""
    ": watch-directory ( path -- )"
    "    [ t [ watch-loop ] with-monitor ] with-monitors"
} ;

ABOUT: "io.monitors"
