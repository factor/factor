USING: help.markup help.syntax io io.ports kernel math
io.pathnames io.directories math.parser io.files strings
quotations io.files.unique.private ;
IN: io.files.unique

HELP: default-temporary-directory
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

HELP: make-unique-file
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "path" "a pathname string" } }
{ $description "Creates a file that is guaranteed not to exist in the directory stored in " { $link current-temporary-directory } ". The file name is composed of a prefix, a number of random digits and letters, and the suffix. Returns the full pathname." }
{ $errors "Throws an error if a new unique file cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." } ;

{ unique-file make-unique-file cleanup-unique-file } related-words

HELP: cleanup-unique-file
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "quot" "a quotation" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls the quotation with the path name on the stack." }
{ $notes "The unique file will be deleted after calling this word." } ;

HELP: unique-directory
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory in the value in " { $link current-temporary-directory } " that is guaranteed not to exist in and returns the full pathname." }
{ $errors "Throws an error if the directory cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." } ;

HELP: cleanup-unique-directory
{ $values { "quot" "a quotation" } }
{ $description "Creates a directory with " { $link unique-directory } " and calls the quotation with the pathname on the stack using the " { $link with-temporary-directory } " combinator. The quotation can access the " { $link current-temporary-directory } " symbol for the name of the temporary directory. Subsequent unique files will be created in this unique directory until the combinator returns." }
{ $notes "The directory will be deleted after calling this word, even if an error is thrown in the quotation. This combinator is like " { $link with-unique-directory } " but does not delete the directory." } ;

HELP: with-unique-directory
{ $values
     { "quot" quotation }
     { "path" "a pathname string" }
}
{ $description "Creates a directory with " { $link unique-directory } " and calls the quotation with the pathname on the stack using the " { $link with-temporary-directory } " combinator. The quotation can access the " { $link current-temporary-directory } " symbol for the name of the temporary directory. Subsequent unique files will be created in this unique directory until the combinator returns." } ;

HELP: current-temporary-directory
{ $values
     { "value" "a path" }
}
{ $description "The temporary directory used for creating unique files and directories." } ;

HELP: unique-file
{ $values
     { "path" "a pathname string" }
     { "path'" "a pathname string" }
}
{ $description "Creates a temporary file in the directory stored in " { $link current-temporary-directory } " and outputs the path name." } ;

HELP: with-temporary-directory
{ $values
     { "path" "a pathname string" } { "quot" quotation }
}
{ $description "Sets " { $link current-temporary-directory } " to " { $snippet "path" } " and calls the quotation, restoring the previous temporary path after execution completes." } ;

ARTICLE: "io.files.unique" "Unique files"
"The " { $vocab-link "io.files.unique" } " vocabulary implements cross-platform unique file creation in temporary directories in a high-level and secure way." $nl
"Changing the temporary path:"
{ $subsection current-temporary-directory }
"Creating unique files:"
{ $subsection unique-file }
{ $subsection cleanup-unique-file }
{ $subsection make-unique-file }
"Creating unique directories:"
{ $subsection unique-directory }
{ $subsection with-unique-directory }
{ $subsection cleanup-unique-directory }
"Default temporary directory:"
{ $subsection default-temporary-directory } ;

ABOUT: "io.files.unique"
