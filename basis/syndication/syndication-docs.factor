USING: help.markup help.syntax io.streams.string strings urls
calendar xml.data xml.writer present ;
IN: syndication

HELP: entry
{ $description "An Atom or RSS feed entry. Has the following slots:"
    { $table
        { "Name" "Class" }
        { "title" { $link string } }
        { "url" { "any class supported by " { $link present } } }
        { "description" { $link string } }
        { "date" { $link timestamp } }
    }
} ;

HELP: <entry>
{ $values { "entry" entry } }
{ $description "Creates a new entry." } ;

HELP: feed
{ $description "An Atom or RSS feed. Has the following slots:"
    { $table
        { "Name" "Class" }
        { "title" { $link string } }
        { "url" { "any class supported by " { $link present } } }
        { "entries" { "a sequence of " { $link entry } " instances" } }
    }
} ;

HELP: <feed>
{ $values { "feed" feed } }
{ $description "Creates a new feed." } ;

HELP: download-feed
{ $values { "url" url } { "feed" feed } }
{ $description "Downloads a feed from a URL using the " { $link "http.client" } "." } ;

HELP: parse-feed
{ $values { "seq" "a string or a byte array" } { "feed" feed } }
{ $description "Parses a feed." } ;

HELP: xml>feed
{ $values { "xml" xml } { "feed" feed } }
{ $description "Parses a feed in XML form." } ;

HELP: feed>xml
{ $values { "feed" feed } { "xml" xml } }
{ $description "Converts a feed to Atom XML form." }
{ $notes "The result of this word can then be passed to " { $link write-xml } ", or stored in an HTTP response object." } ;

ARTICLE: "syndication" "Atom and RSS feed syndication"
"The " { $vocab-link "syndication" } " vocabulary implements support for reading Atom and RSS feeds, and writing Atom feeds."
$nl
"Data types:"
{ $subsection feed }
{ $subsection <feed> }
{ $subsection entry }
{ $subsection <entry> }
"Reading feeds:"
{ $subsection download-feed }
{ $subsection parse-feed }
{ $subsection xml>feed }
"Writing feeds:"
{ $subsection feed>xml }
"The " { $vocab-link "furnace.syndication" } " vocabulary builds on top of this vocabulary to enable easy generation of Atom feeds from web applications. The " { $vocab-link "webapps.planet" } " vocabulary is a complete example of a web application which reads and exports feeds."
{ $see-also "urls" } ;

ABOUT: "syndication"
