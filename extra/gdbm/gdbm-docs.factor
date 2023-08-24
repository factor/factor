! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: gdbm.ffi gdbm.private help.markup help.syntax kernel math
quotations strings ;
IN: gdbm

HELP: gdbm
{ $class-description "Instance of this class is used as database configuration object. It has following slots:"
  { $slots
    { "name" "The file name of the database." }
    { "block-size" "The size of a single transfer from disk to memory. If the value is less than 512, the file system blocksize is used (this is default)." }
    { "role" "Determines what kind of access the user wants to obtain (see below)." }
    { "sync" { "Being set to " { $link t } " causes all database operations to be synchronized to the disk." } }
    { "nolock" { "Being set to " { $link t } " prevents gdbm from performing any locking on the database file." } }
    { "mode" "An integer representing standard UNIX access permissions." }
  }
  "The " { $slot "role" } " can be set to one of the folowing values:"
  { $table
    { { $snippet "reader" } "The user can only read from existing database." }
    { { $snippet "writer" } "The user can access existing database as reader and writer." }
    { { $snippet "wrcreat" } "Open the database for reading and writing if it exists and create new one otherwise." }
    { { $snippet "newdb" } "Create empty database even if there is already one with the same name." }
  }
} ;

HELP: <gdbm>
{ $values { "gdbm" gdbm } }
{ $description "Creates database configuration object with all slots set to their default values. See " { $link gdbm } " for complete slots description." } ;

HELP: gdbm-info
{ $values { "str" string } }
{ $description "Returns version number and build date." } ;

HELP: gdbm-delete
{ $values { "key" object } }
{ $description "Removes the keyed item from the database." } ;

HELP: gdbm-error-message
{ $values { "error" gdbm-error } { "msg" string } }
{ $description "Returns error message in human readable format." } ;

HELP: gdbm-exists?
{ $values { "key" object } { "?" boolean } }
{ $description "Searches for a particular key without retreiving it." } ;

HELP: each-gdbm-key
{ $values { "quot" quotation } }
{ $description "Applies the quotation to the each key in the database." } ;

HELP: each-gdbm-value
{ $values { "quot" quotation } }
{ $description "Applies the quotation to the each value in the database." } ;

HELP: each-gdbm-record
{ $values { "quot" quotation } }
{ $description "Applies the quotation to the each key-value pair in the database." } ;

HELP: gdbm-file-descriptor
{ $values { "desc" integer } }
{ $description "Returns the file descriptor of the database. This is used for manual database locking if it was opened with " { $snippet "nolock" } " flag set to " { $link t } "." } ;

HELP: gdbm-fetch
{ $values
  { "key" object }
  { "content/f" { "the value associated with " { $snippet "key" } " or " { $link f } " if there is no such key" } }
}
{ $description "Looks up a given key and returns value associated with it. This word makes no distinction between a missing value and a value set to " { $link f } "." } ;

HELP: gdbm-fetch*
{ $values { "key" object } { "content" object } { "?" boolean } }
{ $description "Looks up a given key and returns value associated with it. The boolean flag can decide between the case of a missing value, and a value of " { $link f } "." } ;

HELP: gdbm-first-key
{ $values { "key/f" object } }
{ $description "Returns first key in the database. This word makes no distinction between an empty database case and a case of a first value set to " { $link f } "." } ;

HELP: gdbm-first-key*
{ $values { "key" object } { "?" boolean } }
{ $description "Returns first key in the database. The boolean flag can decide between the case of an empty database and a case of a first value set to " { $link f } "." } ;

HELP: gdbm-insert
{ $values { "key" object } { "content" object } }
{ $description "Inserts record into the database. Throws an error if the key already exists." } ;

HELP: gdbm-next-key
{ $values { "key" object } { "key/f" object } }
{ $description "Given a key returns next key in the database. This word makes no distinction between reaching the end of the database case and a case of a next value set to " { $link f } "." } ;

HELP: gdbm-next-key*
{ $values { "key" object } { "next-key" object } { "?" boolean } }
{ $description "Given a key returns next key in the database. The boolean flag can decide between the case of reaching the end of the database and a case of a next value set to " { $link f } "." } ;

HELP: gdbm-reorganize
{ $description "Reorganisation is a process of shinking the space used by gdbm. This requires creating a new file and moving all elements from old gdbm file to new one." } ;

HELP: gdbm-replace
{ $values { "key" object } { "content" object } }
{ $description "Inserts record into the database replacing old value with the new one if the key already exists." } ;

HELP: set-gdbm-block-merging
{ $values { "?" boolean } }
{ $description "If set, this option causes adjacent free blocks to be merged. The default is " { $link f } "." } ;

HELP: set-gdbm-block-pool
{ $values { "?" boolean } }
{ $description "If set, this option causes all subsequent free blocks to be placed in the global pool. The default is " { $link f } "." } ;

HELP: set-gdbm-cache-size
{ $values { "size" integer } }
{ $description "Sets the size of the internal bucket cache. The default value is 100. This option may only be set once." } ;

HELP: set-gdbm-sync-mode
{ $values { "?" boolean } }
{ $description "Turns on or off file system synchronization. The default is " { $link f } "." } ;

HELP: gdbm-synchronize
{ $description "Performs database synchronization: make sure the disk version of the database has been completely updated." } ;

HELP: with-gdbm
{ $values
  { "gdbm" "a database configuration object" } { "quot" quotation }
}
{ $description "Calls the quotation with a database bound to " { $link current-dbf } " symbol." } ;


ARTICLE: "gdbm" "GNU Database Manager"
"The " { $vocab-link "gdbm" } " vocabulary provides an interface to GNU DataBase Manager. This is a GNU implementation of the standard Unix dbm library, originally developed at Berkeley."

$nl
"This is a very brief manual. For a more detailed description consult the official gdbm documentation."

{ $heading "Basics" }
"All interaction with gdbm database should be realized using special combinator which automates all work for database initialisation and cleanup. All initialisation options are passed to combinator with a database configuration object."
{ $subsections gdbm <gdbm> with-gdbm }
"For actual record manipulation the following words are used:"
{ $subsections gdbm-insert gdbm-exists? gdbm-fetch gdbm-delete }

{ $heading "Sequential access" }
"It is possible to iterate through all records in the database with"
{ $subsections gdbm-first-key gdbm-next-key }
"The following combinators, however, provide more convenient way to do that:"
{ $subsections each-gdbm-key each-gdbm-value each-gdbm-record }
"The order in which records are accessed has nothing to do with the order in which records have been stored. Note that these words can only be used in read-only algorithms since delete operation re-arranges the hash table."
;

ABOUT: "gdbm"
