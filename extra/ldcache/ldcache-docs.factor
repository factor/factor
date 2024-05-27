! Copyright (C) 2017 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ldcache.private strings ;
IN: ldcache

HELP: search-ldcache
{ $values
  { "entries" { $sequence ldcache-entry } }
  { "namespec" "library name" }
  { "arch" "architecture" }
  { "entry/f" { $maybe ldcache-entry } }
}
{ $description "Searches among the entries for an entry with a matching name and architecture." } ;

HELP: find-so
{ $values { "namespec" "library name" } { "so-name/f" { $maybe string } } }
{ $description "Looks up the library named 'namespec' from the system cache." } ;

ARTICLE: "ldcache" "LD Cache"
"Vocab for interfacing with the '/etc/ld.so.cache' Unix file." ;

ABOUT: "ldcache"
