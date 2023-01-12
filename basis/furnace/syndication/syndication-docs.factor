USING: calendar help.markup help.syntax kernel strings
syndication urls ;
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
    { "timestamp" timestamp }
}
{ $contract "Outputs a feed entry timestmap." } ;

HELP: feed-entry-description
{ $values
    { "object" object }
    { "description" string }
}
{ $contract "Outputs a feed entry description." } ;

HELP: feed-entry-title
{ $values
    { "object" object }
    { "string" string }
}
{ $contract "Outputs a feed entry title." } ;

HELP: feed-entry-url
{ $values
    { "object" object }
    { "url" url }
}
{ $contract "Outputs a feed entry URL." } ;

ARTICLE: "furnace.syndication.config" "Configuring Atom feed actions"
"Instances of " { $link feed-action } " have three slots which need to be set:"
{ $slots
    { "title" "The title of the feed as a string" }
    { "url" { "The feed " { $link url } } }
    { "entries" { "A quotation with stack effect " { $snippet "( -- seq )" } ", which produces a sequence of objects responding to the " { $link "furnace.syndication.protocol" } " protocol" } }
} ;

ARTICLE: "furnace.syndication.protocol" "Atom feed entry protocol"
"An Atom feed action takes a sequence of objects and converts them into Atom feed entries. The objects must implement a protocol consisting of either a single generic word:"
{ $subsections >entry }
"Or a series of generic words, called by the default implementation of " { $link >entry } ":"
{ $subsections
    feed-entry-title
    feed-entry-description
    feed-entry-date
    feed-entry-url
} ;

ARTICLE: "furnace.syndication" "Furnace Atom syndication support"
"The " { $vocab-link "furnace.syndication" } " vocabulary builds on the " { $link "syndication" } " library by providing easy support for generating Atom feeds from " { $link "furnace.actions" } "."
{ $subsections
    <feed-action>
    "furnace.syndication.config"
    "furnace.syndication.protocol"
} ;

ABOUT: "furnace.syndication"
