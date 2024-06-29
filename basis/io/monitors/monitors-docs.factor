IN: io.monitors
USING: concurrency.mailboxes destructors help.markup help.syntax
kernel quotations ;

HELP: with-monitors
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope where file system monitor operations can be performed." }
{ $errors "Throws an error if the platform does not support file system change monitors." } ;

HELP: <monitor>
{ $values { "path" "a pathname string" } { "recursive?" boolean } { "monitor" "a new monitor" } }
{ $contract "Opens a file system change monitor which listens for changes on " { $snippet "path" } ". The boolean indicates whether changes in subdirectories should be reported." }
{ $errors "Throws an error if the pathname does not exist, if a monitor could not be created or if the platform does not support monitors." } ;

HELP: (monitor)
{ $values { "path" "a pathname string" } { "recursive?" boolean } { "mailbox" mailbox } { "monitor" "a new monitor" } }
{ $contract "Opens a file system change monitor which listens for changes on " { $snippet "path" } " and posts notifications to " { $snippet "mailbox" } " as triples with shape " { $snippet "{ path changed monitor } " } ". The boolean indicates whether changes in subdirectories should be reported." }
{ $errors "Throws an error if the pathname does not exist, if a monitor could not be created or if the platform does not support monitors." } ;

HELP: file-change
{ $class-description "A change notification output by " { $link next-change } ". The " { $snippet "path" } " slot holds a pathname string. The " { $snippet "changed" } " slots holds a sequence of symbols documented in " { $link "io.monitors.descriptors" } "." } ;

HELP: next-change
{ $values { "monitor" "a monitor" } { "change" file-change } }
{ $contract "Waits for file system changes and outputs a change descriptor for the first changed file." }
{ $errors "Throws an error if the monitor is closed from another thread." } ;

HELP: with-monitor
{ $values { "path" "a pathname string" } { "recursive?" boolean } { "quot" { $quotation ( monitor -- ) } } }
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
"The " { $link next-change } " word outputs instances of a class:"
{ $subsections file-change }
"The " { $slot "changed" } " slot holds a sequence which may contain any of the following symbols:"
{ $subsections
    +add-file+
    +remove-file+
    +modify-file+
    +rename-file-old+
    +rename-file-new+
    +rename-file+
} ;

ARTICLE: "io.monitors.platforms" "Monitors on different platforms"
"Whether the " { $slot "path" } " slot of a " { $link file-change } " contains an absolute path or a path relative to the path given to " { $link <monitor> } " is unspecified, and may even vary on the same platform. User code should not assume either case."
$nl
"If the immediate path being monitored was changed, then " { $snippet "path" } " will equal " { $snippet "\"\"" } "; however this condition is not reported on all platforms. See below."
{ $heading "macOS" }
"Factor uses " { $snippet "FSEventStream" } "s to implement monitors on macOS. This requires macOS 10.5 or later."
$nl
{ $snippet "FSEventStream" } "s always monitor directory hierarchies recursively, and the " { $snippet "recursive?" } " parameter to " { $link <monitor> } " has no effect."
$nl
"The " { $snippet "changed" } " slot of the " { $link file-change } " word tuple always contains " { $link +modify-file+ } " and the " { $snippet "path" } " slot is always the directory containing the file that changed. Unlike other platforms, fine-grained information is not available."
$nl
"Only directories may be monitored, not individual files. Changes to the directory itself (permissions, modification time, and so on) are not reported; only changes to children are reported."
{ $heading "Windows" }
"Factor uses " { $snippet "ReadDirectoryChanges" } " to implement monitors on Windows."
$nl
"Both recursive and non-recursive monitors are directly supported by the operating system."
$nl
"Only directories may be monitored, not individual files. Changes to the directory itself (permissions, modification time, and so on) are not reported; only changes to children are reported."
{ $heading "Linux" }
"Factor uses " { $snippet "inotify" } " to implement monitors on Linux. This requires Linux kernel version 2.6.16 or later."
$nl
"Factor simulates recursive monitors by creating a hierarchy of monitors for every subdirectory, since " { $snippet "inotify" } " can only monitor a single directory. This is transparent to user code."
$nl
"Inside a single " { $link with-monitors } " scope, only one monitor may be created for any given directory."
$nl
"Both directories and files may be monitored. Unlike macOS and Windows, changes to the immediate directory being monitored (permissions, modification time, and so on) are reported."
;

ARTICLE: "io.monitors" "File system change monitors"
"File system change monitors listen for changes to file names, attributes and contents under a specified directory. They can optionally be recursive, in which case subdirectories are also monitored."
$nl
"Monitoring operations must be wrapped in a combinator:"
{ $subsections with-monitors }
"Creating a file system change monitor and listening for changes:"
{ $subsections
    <monitor>
    next-change
}
"An alternative programming style is where instead of having a thread listen for changes on a monitor, change notifications are posted to a mailbox:"
{ $subsections
    (monitor)
    "io.monitors.descriptors"
    "io.monitors.platforms"
}
"Monitors are closed by calling " { $link dispose } " or " { $link with-disposal } ". An easy way to pair construction with disposal is to use a combinator:"
{ $subsections with-monitor }
"Monitors support the " { $link "io.timeouts" } "."
$nl
"An example which watches a directory for changes:"
{ $code
    "USE: io.monitors"
    ""
    ": watch-loop ( monitor -- )"
    "    dup next-change path>> print flush watch-loop ;"
    ""
    ": watch-directory ( path -- )"
    "    [ t [ watch-loop ] with-monitor ] with-monitors ;"
} ;

ABOUT: "io.monitors"
