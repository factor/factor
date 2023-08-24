USING: help.markup help.syntax kernel sequences strings ;
IN: xml.data

ABOUT: "xml.data"

ARTICLE: "xml.data" "XML data types"
"The " { $vocab-link "xml.data" } " vocabulary defines a simple document object model for XML. Everything is simply a tuple and can be manipulated as such."
{ $subsections
    { "xml.data" "classes" }
    { "xml.data" "constructors" }
}
"Simple words for manipulating names:"
{ $subsections
    names-match?
    assure-name
}
"For high-level tools for manipulating XML, see " { $vocab-link "xml.traversal" } "." ;

ARTICLE: { "xml.data" "classes" } "XML data classes"
"XML documents and chunks are made of the following classes:"
{ $subsections
    xml
    xml-chunk
    tag
    name
    contained-tag
    open-tag
    prolog
    comment
    instruction
    unescaped
    element-decl
    attlist-decl
    entity-decl
    system-id
    public-id
    doctype-decl
    notation-decl
} ;

ARTICLE: { "xml.data" "constructors" } "XML data constructors"
"These data types are constructed with:"
{ $subsections
    <xml>
    <xml-chunk>
    <tag>
    <name>
    <contained-tag>
    <prolog>
    <comment>
    <instruction>
    <unescaped>
    <simple-name>
    <element-decl>
    <attlist-decl>
    <entity-decl>
    <system-id>
    <public-id>
    <doctype-decl>
    <notation-decl>
} ;

HELP: tag
{ $class-description "Tuple representing an XML tag, delegating to a " { $link
name } ", containing the following slots:"
{ $slots
    { { $slot "attrs" } "an alist of names to strings" }
    { { $slot "children" } { "a " { $link sequence } } } }
"Tags implement the " { $link "sequence-protocol" }
" by acting like a sequence of its chidren, and the "
{ $link "assocs-protocol" } " for getting and setting their attributes." } ;

HELP: <tag>
{ $values { "name" { "an XML tag " { $link name } } }
    { "attrs" "an alist of names to strings" }
    { "children" sequence }
    { "tag" tag } }
{ $description "Constructs an XML " { $link tag } " with the " { $link name }
" (not a string) and tag attributes specified in the given "
{ $snippet "attrs" } " and " { $snippet "children" } "." } ;

HELP: name
{ $class-description "Represents an XML name, with the following slots:"
    { $slots
        { { $slot "space" }
            "an optional string representing the namespace, as written in the document," }
        { { $slot "main" } "a string with the actual tag name," }
        { { $slot "url" } "an optional string with the URL that the namespace points to." } } } ;

HELP: <name>
{ $values { "space" string } { "main" string } { "url" string }
    { "name" { "an XML tag " { $link name } } } }
{ $description "Creates a " { $link name } " tuple with the namespace prefix "
{ $snippet "space" } ", the given " { $snippet "main" }
" part of the name, and the namespace URL given by " { $snippet "url" } "." } ;

{ name <name> <simple-name> } related-words

HELP: contained-tag
{ $class-description "This is a predicate class of " { $link tag }
"s with no body, e.g. " { $snippet "<a/>" } "." }
{ $notes "The tags created with " { $link <tag> } " initially satisfy this predicate." } ;

HELP: <contained-tag>
{ $values { "name" { "an XML tag " { $link name } } }
    { "attrs" "an alist from names to strings" }
    { "tag" tag } }
{ $description "Creates an empty tag (like " { $snippet "<a/>" } ") with the specified " { $snippet "name" } " and " { $snippet "tag" } " attributes." } ;

HELP: open-tag
{ $class-description "This is a predicate class of " { $link tag }
"s with children, i.e. the opposite of a " { $link contained-tag } "." } ;

{ tag <tag> contained-tag <contained-tag> open-tag } related-words

HELP: xml
{ $class-description "Tuple representing an XML document, delegating to the main tag, containing the following slots:"
{ $slots
    { { $slot "prolog" } { "the " { $link prolog } " header " { $snippet "<?xml...?>" } } }
    { { $slot "before" } { "whatever comes between the " { $slot "prolog" } " and the main tag" } }
    { { $slot "body" } { "contains the main " { $link tag } " itself" } }
    { { $slot "after" } "whatever comes after the main tag" } } } ;

HELP: <xml>
{ $values { "prolog" "an XML " { $link prolog } } { "before" { $sequence "XML elements" } }
{ "body" tag } { "after" { $sequence "XML elements" } } { "xml" "an XML document" } }
{ $description "Creates an XML document. The " { $slot "before" } " and "
{ $slot "after" } " slots store what comes before and after the main tag, and "
{ $slot "body" } " contains the main tag itself." } ;

{ xml <xml> } related-words

HELP: prolog
{ $class-description "Represents an XML prolog, with the following slots:"
{ $slots
    { { $slot "version" } "containing \"1.0\" or \"1.1\"" }
    { { $slot "encoding" } { "a " { $link string } " representing the encoding type" } }
    { { $slot "standalone" } { "a " { $link boolean } ", whether the document is standalone without external entities" } } } } ;

HELP: <prolog>
{ $values
    { "version" "a string: \"1.0\" or \"1.1\"" } { "encoding" string }
    { "standalone" boolean } { "prolog" "an XML " { $link prolog } } }
{ $description "Creates an XML " { $link prolog } " tuple." } ;

{ prolog <prolog> } related-words

HELP: comment
{ $class-description "Represents a comment in XML. This tuple has one slot, "
{ $slot "text" } ", which contains the comment " { $link string } "." } ;

HELP: <comment>
{ $values { "text" string } { "comment" comment } }
{ $description "Creates an XML " { $link comment } " tuple." } ;

{ comment <comment> } related-words

HELP: instruction
{ $class-description "Represents an XML instruction, such as "
{ $snippet "<?xsl stylesheet='foo.xml'?>" } ". Contains one slot, "
{ $slot "text" } ", which contains the string between the question marks." } ;

HELP: <instruction>
{ $values { "text" string } { "instruction" "an XML " { $link instruction } } }
{ $description "Creates an XML parsing instruction, like " { $snippet "<?xsl stylesheet='foo.xml'?>" } "." } ;

{ instruction <instruction> } related-words

HELP: opener
{ $class-description
"Describes an opening tag, like " { $snippet "<a>" } ". Contains two slots:"
{ $slots
    { { $slot "name" } { "the " { $link name } " of the tag" } }
    { { $slot "attrs" } "the tag attributes" } } } ;

HELP: closer
{ $class-description
"Describes a closing tag, like " { $snippet "</a>" } ". Contains one slot:"
{ $slots { { $slot "name" } "contains the closer's name." } } } ;

HELP: contained
{ $class-description
"Represents a self-closing tag, like " { $snippet "<a/>" } ". Contains two slots:"
{ $slots
    { { $slot "name" } { "the " { $link name } " of the tag" } }
    { { $slot "attrs" } "tag attributes" } } } ;

{ opener closer contained } related-words

HELP: names-match?
{ $values { "name1" name } { "name2" name } { "?" boolean } }
{ $description "Checks to see if the two names match, that is, if all slots are equal, ignoring those whose value is "
{ $link f } " in either name." }
{ $example "USING: prettyprint xml.data ;" "T{ name f \"rpc\" \"methodCall\" f } T{ name f f \"methodCall\" \"http://www.xmlrpc.org/\" } names-match? ." "t" }
{ $see-also name } ;

HELP: assure-name
{ $values { "string/name" { "a " { $link string } " or a " { $link name } } } { "name" name } }
{ $description "Converts a string into an XML " { $link name } ", if it is not already a name." } ;

HELP: <simple-name>
{ $values { "string" string } { "name" name } }
{ $description "Converts a string into an XML " { $link name }
" with an empty namespace prefix and URL." } ;

HELP: element-decl
{ $class-description "Describes the class of element declarations, like "
{ $snippet "<!ELEMENT greeting (#PCDATA)>" } "." } ;

HELP: <element-decl>
{ $values { "name" name } { "content-spec" string } { "element-decl" element-decl } }
{ $description "Creates an element declaration object, of the class " { $link element-decl } "." } ;

{ element-decl <element-decl> } related-words

HELP: attlist-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!ATTLIST pre xml:space (preserve) #FIXED 'preserve'>" } "." } ;

HELP: <attlist-decl>
{ $values { "name" name } { "att-defs" string } { "attlist-decl" attlist-decl } }
{ $description "Creates an element declaration object, of the class " { $link attlist-decl } "." } ;

{ attlist-decl <attlist-decl> } related-words

HELP: entity-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!ENTITY foo 'bar'>" } "." } ;

HELP: <entity-decl>
{ $values { "name" name } { "def" string } { "pe?" boolean } { "entity-decl" entity-decl } }
{ $description "Creates an entity declaration object, of the class " { $link entity-decl }
". The " { $slot "pe?" } " slot should be " { $link t }
" if the object is a DTD-internal entity, like "
{ $snippet "<!ENTITY % foo 'bar'>" } " and " { $link f } " if the object is like "
{ $snippet "<!ENTITY foo 'bar'>" } ", that is, it can be used outside of the DTD." } ;

{ entity-decl <entity-decl> } related-words

HELP: system-id
{ $class-description "Describes the class of system identifiers within an XML DTD directive, such as " { $snippet "<!DOCTYPE greeting " { $emphasis "SYSTEM 'hello.dtd'" } ">" } "." } ;

HELP: <system-id>
{ $values { "system-literal" string } { "system-id" system-id } }
{ $description "Constructs a " { $link system-id } " tuple." } ;

{ system-id <system-id> } related-words

HELP: public-id
{ $class-description "Describes the class of public identifiers within an XML DTD directive, such as " { $snippet "<!DOCTYPE open-hatch " { $emphasis "PUBLIC '-//Textuality//TEXT Standard open-hatch boilerplate//EN' 'http://www.textuality.com/boilerplate/OpenHatch.xml'" } ">" } } ;

HELP: <public-id>
{ $values { "pubid-literal" string } { "system-literal" string } { "public-id" public-id } }
{ $description "Constructs a " { $link public-id } " tuple." } ;

{ public-id <public-id> } related-words

HELP: notation-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!NOTATION jpg SYSTEM './jpgviewer'>" } "." } ;

HELP: <notation-decl>
{ $values { "name" string } { "id" string } { "notation-decl" notation-decl } }
{ $description "Creates a notation declaration object, of the class " { $link notation-decl } "." } ;

{ notation-decl <notation-decl> } related-words

HELP: doctype-decl
{ $class-description "Describes the class of document type declarations." } ;

HELP: <doctype-decl>
{ $values { "name" name } { "external-id" id } { "internal-subset" sequence } { "doctype-decl" doctype-decl } }
{ $description "Creates a new document type declaration object, of the class "
{ $link doctype-decl } ". Only one of " { $snippet "external-id" } " or " { $snippet "internal-subset" } " will be non-"
{ $link f } "." } ;

{ doctype-decl <doctype-decl> } related-words

HELP: unescaped
{ $class-description "When constructing XML documents to write to output, it can be useful to splice in a string which is already written. This tuple type allows for that. Printing an "
{ $snippet "unescaped" } " is the same as printing its " { $slot "string" }
" slot." } ;

HELP: <unescaped>
{ $values { "string" string } { "unescaped" unescaped } }
{ $description "Constructs an " { $link unescaped } " tuple, given a " { $link string } "." } ;

{ unescaped <unescaped> } related-words

HELP: xml-chunk
{ $class-description "Encapsulates a balanced fragment of an XML document. This is a sequence (following the " { $link "sequence-protocol" } ") of XML data types, e.g. " { $link string } "s and " { $link tag } "s." } ;

HELP: <xml-chunk>
{ $values { "seq" sequence } { "xml-chunk" xml-chunk } }
{ $description "Constructs an " { $link xml-chunk } " tuple, given a " { $snippet "seq" } " for its contents." } ;

{ xml-chunk <xml-chunk> } related-words
