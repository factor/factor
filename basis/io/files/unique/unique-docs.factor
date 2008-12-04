USING: help.markup help.syntax io io.ports kernel math
io.files.unique.private math.parser io.files ;
IN: io.files.unique

HELP: make-unique-file ( prefix suffix -- path )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "path" "a pathname string" } }
{ $description "Creates a file that is guaranteed not to exist in a platform-specific temporary directory. The file name is composed of a prefix, a number of random digits and letters, and the suffix. Returns the full pathname." }
{ $errors "Throws an error if a new unique file cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-file } ;

HELP: with-unique-file ( prefix suffix quot: ( path -- ) -- )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "quot" "a quotation" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls the quotation with the path name on the stack." }
{ $notes "The unique file will be deleted after calling this word." } ;

HELP: make-unique-directory ( -- path )
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory that is guaranteed not to exist in a platform-specific temporary directory and returns the full pathname." }
{ $errors "Throws an error if the directory cannot be created after a number of tries. The most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-directory } ;

HELP: with-unique-directory ( quot -- )
{ $values { "quot" "a quotation" } }
{ $description "Creates a directory with " { $link make-unique-directory } " and calls the quotation with the pathname on the stack using the " { $link with-directory } " combinator. The quotation can access the " { $link current-directory } " symbol for the name of the temporary directory." }
{ $notes "The directory will be deleted after calling this word, even if an error is thrown in the quotation." } ;

ARTICLE: "io.files.unique" "Temporary files"
"The " { $vocab-link "io.files.unique" } " vocabulary implements cross-platform temporary file creation in a high-level and secure way." $nl
"Files:"
{ $subsection make-unique-file }
{ $subsection with-unique-file }
"Directories:"
{ $subsection make-unique-directory }
{ $subsection with-unique-directory } ;

ABOUT: "io.files.unique"
