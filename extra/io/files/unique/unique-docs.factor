USING: help.markup help.syntax io io.nonblocking kernel math
io.files.unique.private math.parser io.files ;
IN: io.files.unique

ARTICLE: "unique" "Making and using unique files"
"Files:"
{ $subsection make-unique-file }
{ $subsection with-unique-file }
"Directories:"
{ $subsection make-unique-directory }
{ $subsection with-unique-directory } ;

ABOUT: "unique"

HELP: make-unique-file ( prefix suffix -- path )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "path" "a pathname string" } }
{ $description "Creates a file that is guaranteed not to exist in a platform-specific temporary directory.  The file name is composed of a prefix, a number of random digits and letters, and the suffix.  Returns the full pathname." }
{ $errors "Throws an error if a new unique file cannot be created after a number of tries.  Since each try generates a new random name, the most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-file } ;

HELP: make-unique-directory ( -- path )
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory that is guaranteed not to exist in a platform-specific temporary directory and returns the full pathname." }
{ $errors "Throws an error if the directory cannot be created after a number of tries.  Since each try generates a new random name, the most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-directory } ;

HELP: with-unique-file ( prefix suffix quot -- )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "quot" "a quotation" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls the quotation with the path name on the stack." }
{ $notes "The unique file will be deleted after calling this word." } ;

HELP: with-unique-directory ( quot -- )
{ $values { "quot" "a quotation" } }
{ $description "Creates a directory with " { $link make-unique-directory } " and calls the quotation with the pathname on the stack." }
{ $notes "The directory will be deleted after calling this word." } ;
