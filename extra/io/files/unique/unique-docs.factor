USING: help.markup help.syntax io io.nonblocking kernel math
io.files.unique.private math.parser io.files ;
IN: io.files.unique

ARTICLE: "unique" "Making and using unique files"
"Files:"
{ $subsection make-unique-file }
{ $subsection with-unique-file }
{ $subsection with-temporary-file }
"Directories:"
{ $subsection make-unique-directory }
{ $subsection with-unique-directory }
{ $subsection with-temporary-directory } ;

ABOUT: "unique"

HELP: make-unique-file ( prefix suffix -- path stream )
{ $values { "prefix" "a string" } { "suffix" "a string" }
{ "path" "a pathname string" } { "stream" "an output stream" } }
{ $description "Creates a file that is guaranteed not to exist in a platform-specific temporary directory.  The file name is composed of a prefix, a number of random digits and letters, and the suffix.  Returns the full pathname and a " { $link <writer> } " stream." }
{ $errors "Throws an error if a new unique file cannot be created after a number of tries.  Since each try generates a new random name, the most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-file } ;

HELP: make-unique-directory ( -- path )
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory that is guaranteed not to exist in a platform-specific temporary directory and returns the full pathname." }
{ $errors "Throws an error if the directory cannot be created after a number of tries.  Since each try generates a new random name, the most likely error is incorrect directory permissions on the temporary directory." }
{ $see-also with-unique-directory } ;

HELP: with-unique-file ( quot -- path )
{ $values { "quot" "a quotation" } { "path" "a pathname string" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls " { $link with-stream } " on the newly created file.  Returns the full pathname after the stream has been closed." }
{ $notes "The unique file will remain after calling this word." }
{ $see-also with-temporary-file } ;

HELP: with-unique-directory ( quot -- path )
{ $values { "quot" "a quotation" } { "path" "a pathname string" } }
{ $description "Creates a directory with " { $link make-unique-directory } " and calls " { $link with-directory } " on the newly created directory.  Returns the full pathname after the quotation has been called." }
{ $notes "The directory will remain after calling this word." }
{ $see-also with-temporary-directory } ;

HELP: with-temporary-file ( quot -- )
{ $values { "quot" "a quotation" } }
{ $description "Creates a file with " { $link make-unique-file } " and calls " { $link with-stream } " on the newly created file.  The file is deleted after the quotation returns." }
{ $see-also with-unique-file } ;

HELP: with-temporary-directory ( quot -- )
{ $values { "quot" "a quotation" } }
{ $description "Creates a directory with " { $link make-unique-directory } " and calls " { $link with-directory } " on the newly created directory.  The directory is deleted after the quotation returns." }
{ $see-also with-unique-directory } ;
