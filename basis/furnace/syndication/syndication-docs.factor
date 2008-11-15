USING: help.markup help.syntax io.streams.string kernel sequences strings urls ;
IN: furnace.syndication

HELP: <feed-action>
{ $values
    
     { "action" null }
}
{ $description "" } ;

HELP: <feed-content>
{ $values
     { "body" null }
     { "response" null }
}
{ $description "" } ;

HELP: >entry
{ $values
     { "object" object }
     { "entry" null }
}
{ $description "" } ;

HELP: feed-action
{ $description "" } ;

HELP: feed-entry-date
{ $values
     { "object" object }
     { "timestamp" null }
}
{ $description "" } ;

HELP: feed-entry-description
{ $values
     { "object" object }
     { "description" null }
}
{ $description "" } ;

HELP: feed-entry-title
{ $values
     { "object" object }
     { "string" string }
}
{ $description "" } ;

HELP: feed-entry-url
{ $values
     { "object" object }
     { "url" url }
}
{ $description "" } ;

HELP: process-entries
{ $values
     { "seq" sequence }
     { "seq'" sequence }
}
{ $description "" } ;

ARTICLE: "furnace.syndication" "Furnace Atom syndication support"
{ $vocab-link "furnace.syndication" }
;

ABOUT: "furnace.syndication"
