USING: help.markup help.syntax io.directories io.pathnames
quotations strings ;
IN: io.files.unique

HELP: touch-unique-file
{ $values { "path" "a pathname string" } }
{ $description "Creates a unique file in a platform-specific way. The file is guaranteed not to exist and is openable by your user." } ;

HELP: unique-length
{ $description "A symbol storing the number of random characters inserted between the prefix and suffix of a random file name." } ;

HELP: unique-retries
{ $description "The number of times to try creating a unique file in case of a name collision. The odds of a name collision are extremely low with a sufficient " { $link unique-length } "." } ;

{ unique-length unique-retries } related-words

HELP: unique-file
{ $values { "prefix" string } { "suffix" string } { "path" "a pathname string" } }
{ $description "Creates a file that is guaranteed not to exist in the " { $link current-directory } ". The file name is composed of a prefix, a " { $link unique-length } " number of random digits and letters, and the suffix. Returns the full pathname." }
{ $errors "Throws an error if a new unique file cannot be created after a " { $link unique-retries } " number of tries. The most likely error is incorrect directory permissions on the " { $link current-directory } "." } ;

{ unique-file cleanup-unique-file } related-words

HELP: cleanup-unique-file
{ $values { "prefix" string } { "suffix" string } { "quot" { $quotation ( ..a path -- ..b ) } } }
{ $description "Creates a file with " { $link unique-file } " and calls the quotation with the path name on the stack." }
{ $notes "The unique file will be deleted after calling this word, even if an error is thrown in the quotation." } ;

HELP: unique-directory
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory in the " { $link current-directory } " that is guaranteed not to exist and return the full pathname. The mechanism for the guarantee of uniqueness is retrying with a " { $link unique-length } " randomly generated filename until " { $link make-directory } " succeeds." }
{ $errors "Throws an error if the directory cannot be created after a " { $link unique-retries } " number of tries. The most likely error is incorrect directory permissions on the " { $link current-directory } "." } ;

HELP: with-unique-directory
{ $values { "quot" quotation } { "path" "a pathname string" } }
{ $description "Creates a directory with " { $link unique-directory } " and calls the quotation using " { $link with-directory } " to set it as the " { $link current-directory } "." } ;

HELP: cleanup-unique-directory
{ $values { "quot" quotation } }
{ $description "Creates a directory with " { $link unique-directory } " and calls the quotation using " { $link with-directory } " to set it as the " { $link current-directory } "." }
{ $notes "The unique directory will be deleted after calling this word, even if an error is thrown in the quotation." } ;

{ unique-directory with-unique-directory cleanup-unique-directory } related-words

HELP: safe-replace-file
{ $values { "original-path" "a pathname string" } { "quot" quotation } }
{ $description "Copies the file from " { $snippet "original-path" } " to a unique file, applies the " { $snippet "quot" } " quotation to it, and then moves the unique file back atomically." } ;

ARTICLE: "io.files.unique" "Unique files"
"The " { $vocab-link "io.files.unique" } " vocabulary implements cross-platform unique file creation in a high-level and secure way." $nl
"Creating unique files:"
{ $subsections
    unique-file
    cleanup-unique-file
}
"Creating unique directories:"
{ $subsections
    unique-directory
    with-unique-directory
    cleanup-unique-directory
} ;

ABOUT: "io.files.unique"
