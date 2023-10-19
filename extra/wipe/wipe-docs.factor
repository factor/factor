! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations ;
IN: wipe

HELP: overwrite-with-random-bytes
{ $values { "file-name" "a filename string" } }
{ $description "Overwrite the " { $snippet "file-name" } " contents with random data. The slack space at the end is not overwritten." } ;

ABOUT: "Wipe"

ARTICLE: "Wipe" "Wipe"
"The " { $vocab-link "wipe" } " vocab provides some words for securely erasing (wiping) individual files, entire folders or the free space on a drive:"
{ $subsections wipe wipe-all wipe-file wipe-free-space }
;

HELP: wipe
{ $values { "path" "a pathname string" } }
{ $description "Call either " { $link wipe-file } " if the " { $snippet "path" } " is a file, or " { $link wipe-all } " if " { $snippet "path" } " is a directory." } ;

HELP: wipe-all
{ $values { "directory" "a pathname string" } }
{ $description "Wipe all files in the " { $snippet "directory" } " and all subdirectories by overwriting their contents with random data and then deleting them." } ;

HELP: wipe-file
{ $values { "file-name" "a filename string" } }
{ $description "Wipe the " { $snippet "file-name" } " by overwriting its contents with random data and then deleting it." } ;

HELP: wipe-free-space
{ $values { "path" "a pathname string" } }
{ $description "Create a temporary file at " { $snippet "path" } " that consumes all of free space on the drive, fill it with random data, then delete the file. This has the effect of wiping any recoverable data left on the drive after insecurely deleting the files." } ;

HELP: with-temp-directory-at
{ $values { "path" "a filename string" } { "quot" quotation } }
{ $description "Run the " { $snippet "quot" } "ation in a randomly named subdirectory of " { $snippet "path" } ", then delete the subdirectory." } ;

HELP: make-file-empty
{ $values { "file-name" "a filename string" } }
{ $description "Create a new empty file named " { $snippet "file-name" } ", discarding any existing data under that name." } ;
