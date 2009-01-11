USING: help.markup help.syntax io io.ports kernel math
io.pathnames io.directories math.parser io.files strings ;
IN: io.files.unique

HELP: temporary-path
{ $values
     { "path" "a pathname string" }
}
{ $description "A hook that returns the path of the temporary directory in a platform-specific way. Does not guarantee that path is writable by your user." } ;

HELP: touch-unique-file
{ $values
     { "path" "a pathname string" }
}
{ $description "Creates a unique file in a platform-specific way. The file is guaranteed not to exist and is openable by your user." } ;

HELP: unique-length
{ $description "A symbol storing the number of random characters inserted between the prefix and suffix of a random file name." } ;

HELP: unique-retries
{ $description "The number of times to try creating a unique file in case of a name collision. The odds of a name collision are extremely low with a sufficient " { $link unique-length } "." } ;

{ unique-length unique-retries } related-words

HELP: make-unique-file ( prefix suffix -- path )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "path" "a pathname string" } }
{ $description "Creates a file that is guaranteed not to exist in a platform-specific temporary directory. The file name is composed of a prefix, a number of random digits and letters, and the suffix. Returns the full pathname." }
{ $errors "Throws an error if a new unique file cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." } ;

HELP: make-unique-file*
{ $values
     { "prefix" string } { "suffix" string }
     { "path" "a pathname string" }
}
{ $description "Creates a file that is guaranteed not to exist in the directory in the " { $link current-directory } " variable. The file name is composed of a prefix, a number of random digits and letters, and the suffix. Returns the full pathname." } ;

{ make-unique-file make-unique-file* with-unique-file } related-words

HELP: with-unique-file ( prefix suffix quot: ( path -- ) -- )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "quot" "a quotation" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls the quotation with the path name on the stack." }
{ $notes "The unique file will be deleted after calling this word." } ;

HELP: make-unique-directory ( -- path )
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory that is guaranteed not to exist in a platform-specific temporary directory and returns the full pathname." }
{ $errors "Throws an error if the directory cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." } ;

HELP: with-unique-directory ( quot -- )
{ $values { "quot" "a quotation" } }
{ $description "Creates a directory with " { $link make-unique-directory } " and calls the quotation with the pathname on the stack using the " { $link with-directory } " combinator. The quotation can access the " { $link current-directory } " symbol for the name of the temporary directory." }
{ $notes "The directory will be deleted after calling this word, even if an error is thrown in the quotation." } ;

ARTICLE: "io.files.unique" "Temporary files"
"The " { $vocab-link "io.files.unique" } " vocabulary implements cross-platform temporary file creation in a high-level and secure way." $nl
"Creating temporary files:"
{ $subsection make-unique-file }
{ $subsection make-unique-file* }
{ $subsection with-unique-file }
"Creating temporary directories:"
{ $subsection make-unique-directory }
{ $subsection with-unique-directory } ;

ABOUT: "io.files.unique"
