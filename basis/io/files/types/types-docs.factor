USING: help.markup help.syntax ;
IN: io.files.types

HELP: +regular-file+
{ $description "A regular file. This type exists on all platforms. See " { $link "io.files" } " for words operating on files." } ;

HELP: +directory+
{ $description "A directory. This type exists on all platforms. See " { $link "io.directories" } " for words operating on directories." } ;

HELP: +symbolic-link+
{ $description "A symbolic link file. This type is currently implemented on Unix platforms only. See " { $link "io.files.links" } " for words operating on symbolic links." } ;

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

ARTICLE: "file-types" "File types"
"Platform-independent types:"
{ $subsections
    +regular-file+
    +directory+
}
"Platform-specific types:"
{ $subsections
    +character-device+
    +block-device+
    +fifo+
    +symbolic-link+
    +socket+
    +unknown+
} ;

ABOUT: "file-types"
