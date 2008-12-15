IN: io.files.info

HELP: file-info
{ $values { "path" "a pathname string" } { "info" file-info } }
{ $description "Queries the file system for metadata. If " { $snippet "path" } " refers to a symbolic link, it is followed. See the article " { $link "file-types" } " for a list of metadata symbols." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: link-info
{ $values { "path" "a pathname string" } { "info" "a file-info tuple" } }
{ $description "Queries the file system for metadata. If path refers to a symbolic link, information about the symbolic link itself is returned. If the file does not exist, an exception is thrown." } ;

{ file-info link-info } related-words

HELP: +regular-file+
{ $description "A regular file. This type exists on all platforms. See " { $link "file-streams" } " for words operating on files." } ;

HELP: +directory+
{ $description "A directory. This type exists on all platforms. See " { $link "directories" } " for words operating on directories." } ;

HELP: +symbolic-link+
{ $description "A symbolic link file.  This type is currently implemented on Unix platforms only. See " { $link "symbolic-links" } " for words operating on symbolic links." } ;

HELP: +character-device+
{ $description "A Unix character device file. This type exists on Unix platforms only." } ;

HELP: +block-device+
{ $description "A Unix block device file. This type exists on Unix platforms only." } ;

HELP: +fifo+
{ $description "A Unix fifo file. This type exists on Unix platforms only." } ;

HELP: +socket+
{ $description "A Unix socket file. This type exists on Unix platforms only." } ;

HELP: +unknown+
{ $description "A unknown file type." } ;

HELP: directory?
{ $values { "file-info" file-info } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "file-info" } " is a directory." } ;

HELP: file-systems
{ $values { "array" array } }
{ $description "Returns an array of " { $link file-system-info } " objects returned by iterating the mount points and calling " { $link file-system-info } " on each." } ;

HELP: file-system-info
{ $values
{ "path" "a pathname string" }
{ "file-system-info" file-system-info } }
{ $description "Returns a platform-specific object describing the file-system that contains the path. The cross-platform slot is " { $slot "free-space" } "." } ;

ARTICLE: "file-types" "File types"
"Platform-independent types:"
{ $subsection +regular-file+ }
{ $subsection +directory+ }
"Platform-specific types:"
{ $subsection +character-device+ }
{ $subsection +block-device+ }
{ $subsection +fifo+ }
{ $subsection +symbolic-link+ }
{ $subsection +socket+ }
{ $subsection +unknown+ } ;

ARTICLE: "io.files.info" "File system meta-data"
"File meta-data:"
{ $subsection file-info }
{ $subsection link-info }
{ $subsection exists? }
{ $subsection directory? }
"File types:"
{ $subsection "file-types" }
"File system meta-data:"
{ $subsection file-system-info }
{ $subsection file-systems } ;

ABOUT: "io.files.info"
