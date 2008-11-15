USING: help.markup help.syntax io.streams.string kernel sequences strings urls syndication ;
IN: furnace.syndication

HELP: <feed-action>
{ $values { "action" feed-action } }
{ $description "Creates a new Atom feed action." } ;

HELP: >entry
{ $values
     { "object" object }
     { "entry" entry }
}
{ $contract "Converts an object into an Atom feed entry. The default implementation constructs an entry by calling "
{ $link feed-entry-title } ", "
{ $link feed-entry-description } ", "
{ $link feed-entry-date } ", and "
{ $link feed-entry-url } "." } ;

HELP: feed-action
{ $class-description "The class of feed actions. Contains several slots, documented in " { $link "furnace.syndication.config" } "." } ;

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

ARTICLE: "furnace.syndication.config" "Configuring Atom feed actions"

;

ARTICLE: "furnace.syndication.protocol" "Atom feed entry protocol"
"An Atom feed action takes a sequence of objects and converts them into Atom feed entries. The objects must implement a protocol consisting of either a single generic word:"
{ $subsection >entry }
"Or a series of generic words, called by the default implementation of " { $link >entry } ":"
{ $subsection feed-entry-title }
{ $subsection feed-entry-description }
{ $subsection feed-entry-date }
{ $subsection feed-entry-url } ;

ARTICLE: "furnace.syndication" "Furnace Atom syndication support"
"The " { $vocab-link "furnace.syndication" } " vocabulary builds on the " { $link "syndication" } " library by providing easy support for generating Atom feeds from " { $link "furnace.actions" } "."
{ $subsection <feed-action> }
{ $subsection "furnace.syndication.config" }
{ $subsection "furnace.syndication.protocol" } ;

ABOUT: "furnace.syndication"
