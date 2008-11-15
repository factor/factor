USING: help.markup help.syntax io.streams.string quotations strings ;
IN: furnace.sessions

HELP: <sessions>
{ $values
     { "responder" null }
     { "responder'" null }
}
{ $description "" } ;

HELP: init-session*
{ $values
     { "responder" null }
}
{ $description "" } ;

HELP: schange
{ $values
     { "key" null } { "quot" quotation }
}
{ $description "" } ;

HELP: sget
{ $values
     { "key" null }
     { "value" null }
}
{ $description "" } ;

HELP: sset
{ $values
     { "value" null } { "key" null }
}
{ $description "" } ;

ARTICLE: "furnace.sessions.serialize" "Session state serialization"

;

ARTICLE: "furnace.sessions" "Furnace sessions"
{ $vocab-link "furnace.sessions" }

;

ABOUT: "furnace.sessions"
