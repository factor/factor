! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: env

HELP: env
{ $class-description "A singleton that implements the " { $link "assocs-protocol" } " over " { $link "environment" } "." } ;

ARTICLE: "env" "Accessing the environment via the assoc protocol"
"The " { $vocab-link "env" } " vocabulary defines a " { $link env } " word which implements the " { $link "assocs-protocol" } " over " { $link "environment" } "."
{ $subsections env }
;

ABOUT: "env"
