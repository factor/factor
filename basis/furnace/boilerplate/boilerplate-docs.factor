! Copyright (C) 2008 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string ;
IN: furnace.boilerplate

HELP: <boilerplate>
{ $values
     { "responder" null }
     { "boilerplate" null }
}
{ $description "" } ;

HELP: boilerplate
{ $description "" } ;

HELP: wrap-boilerplate?
{ $values
     { "response" null }
     { "?" "a boolean" }
}
{ $description "" } ;

ARTICLE: "furnace.boilerplate" "Furnace boilerplate support"
{ $vocab-link "furnace.boilerplate" }
;

ABOUT: "furnace.boilerplate"
