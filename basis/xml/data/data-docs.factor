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
"For high-level tools for manipulating XML, see " { $vocab-link "xml.traversal" } ;

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
name } ", containing the slots attrs (an alist of names to strings) and children (a sequence). Tags implement the sequence protocol by acting like a sequence of its chidren, and the assoc protocol by acting like its attributes." }
{ $see-also <tag> name contained-tag xml } ;

HELP: <tag>
{ $values { "name" "an XML tag name" }
    { "attrs" "an alist of names to strings" }
    { "children" sequence }
    { "tag" tag } }
{ $description "Constructs an XML " { $link tag } " with the name (not a string) and tag attributes specified in attrs and children specified." }
{ $see-also tag <contained-tag> } ;

HELP: name
{ $class-description "Represents an XML name, with the fields space (a string representing the namespace, as written in the document, tag (a string of the actual name of the tag) and url (a string of the URL that the namespace points to)." }
{ $see-also <name> tag } ;

HELP: <name>
{ $values { "space" string } { "main" string } { "url" string }
    { "name" "an XML tag name" } }
{ $description "Creates a name tuple with the namespace prefix space, the the given main part of the name, and the namespace URL given by url." }
{ $see-also name <tag> } ;

HELP: contained-tag
{ $class-description "This is a subclass of " { $link tag } " consisting of tags with no body, like " { $snippet "<a/>" } "." }
{ $see-also tag <contained-tag> } ;

HELP: <contained-tag>
{ $values { "name" "an XML tag name" }
    { "attrs" "an alist from names to strings" }
    { "tag" tag } }
{ $description "Creates an empty tag (like " { $snippet "<a/>" } ") with the specified name and tag attributes." }
{ $see-also contained-tag <tag> } ;

HELP: xml
{ $class-description "Tuple representing an XML document, delegating to the main tag, containing the fields prolog (the header " { $snippet "<?xml...?>" } "), before (whatever comes between the prolog and the main tag) and after (whatever comes after the main tag)." }
{ $see-also <xml> tag prolog } ;

HELP: <xml>
{ $values { "prolog" "an XML prolog" } { "before" "a sequence of XML elements" }
{ "body" tag } { "after" "a sequence of XML elements" } { "xml" "an XML document" } }
{ $description "Creates an XML document. The " { $snippet "before" } " and " { $snippet "after" } " slots store what comes before and after the main tag, and " { $snippet "body" } " contains the main tag itself." }
{ $see-also xml <tag> } ;

HELP: prolog
{ $class-description "represents an XML prolog, with the tuple fields version (containing \"1.0\" or \"1.1\"), encoding (a string representing the encoding type), and standalone (t or f, whether the document is standalone without external entities)" }
{ $see-also <prolog> xml } ;

HELP: <prolog>
{ $values { "version" "a string, 1.0 or 1.1" }
{ "encoding" string } { "standalone" boolean } { "prolog" "an XML prolog" } }
{ $description "Creates an XML prolog tuple." }
{ $see-also prolog <xml> } ;

HELP: comment
{ $class-description "Represents a comment in XML. This tuple has one slot, " { $snippet "text" } ", which contains the string of the comment." }
{ $see-also <comment> } ;

HELP: <comment>
{ $values { "text" string } { "comment" comment } }
{ $description "Creates an XML " { $link comment } " tuple." }
{ $see-also comment } ;

HELP: instruction
{ $class-description "Represents an XML instruction, such as " { $snippet "<?xsl stylesheet='foo.xml'?>" } ". Contains one slot, " { $snippet "text" } ", which contains the string between the question marks." }
{ $see-also <instruction> } ;

HELP: <instruction>
{ $values { "text" string } { "instruction" "an XML instruction" } }
{ $description "Creates an XML parsing instruction, like " { $snippet "<?xsl stylesheet='foo.xml'?>" } "." }
{ $see-also instruction } ;

HELP: opener
{ $class-description "Describes an opening tag, like " { $snippet "<a>" } ". Contains two slots, " { $snippet "name" } " and " { $snippet "attrs" } " containing, respectively, the name of the tag and its attributes." } ;

HELP: closer
{ $class-description "Describes a closing tag, like " { $snippet "</a>" } ". Contains one slot, " { $snippet "name" } ", containing the closer's name." } ;

HELP: contained
{ $class-description "Represents a self-closing tag, like " { $snippet "<a/>" } ". Contains two slots, " { $snippet "name" } " and " { $snippet "attrs" } " containing, respectively, the name of the tag and its attributes." } ;

{ opener closer contained } related-words

HELP: open-tag
{ $class-description "Represents a tag that does have children, ie. is not a contained tag" }
{ $notes "The constructor used for this class is simply " { $link <tag> } "." }
{ $see-also tag contained-tag } ;

HELP: names-match?
{ $values { "name1" "a name" } { "name2" "a name" } { "?" "t or f" } }
{ $description "Checks to see if the two names match, that is, if all fields are equal, ignoring fields whose value is f in either name." }
{ $example "USING: prettyprint xml.data ;" "T{ name f \"rpc\" \"methodCall\" f } T{ name f f \"methodCall\" \"http://www.xmlrpc.org/\" } names-match? ." "t" }
{ $see-also name } ;

HELP: assure-name
{ $values { "string/name" "a string or a name" } { "name" "a name" } }
{ $description "Converts a string into an XML name, if it is not already a name." } ;

HELP: <simple-name>
{ $values { "string" string } { "name" name } }
{ $description "Converts a string into an XML name with an empty prefix and URL." } ;

HELP: element-decl
{ $class-description "Describes the class of element declarations, like <!ELEMENT greeting (#PCDATA)>." } ;

HELP: <element-decl>
{ $values { "name" name } { "content-spec" string } { "element-decl" entity-decl } }
{ $description "Creates an element declaration object, of the class " { $link element-decl } } ;

HELP: attlist-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!ATTLIST pre xml:space (preserve) #FIXED 'preserve'>" } "." } ;

HELP: <attlist-decl>
{ $values { "name" name } { "att-defs" string } { "attlist-decl" attlist-decl } }
{ $description "Creates an element declaration object, of the class " { $link attlist-decl } } ;

HELP: entity-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!ENTITY foo 'bar'>" } "." } ;

HELP: <entity-decl>
{ $values { "name" name } { "def" string } { "pe?" "t or f" } { "entity-decl" entity-decl } }
{ $description "Creates an entity declaration object, of the class " { $link entity-decl } ". The pe? slot should be t if the object is a DTD-internal entity, like " { $snippet "<!ENTITY % foo 'bar'>" } " and f if the object is like " { $snippet "<!ENTITY foo 'bar'>" } ", that is, it can be used outside of the DTD." } ;

HELP: system-id
{ $class-description "Describes the class of system identifiers within an XML DTD directive, such as " { $snippet "<!DOCTYPE greeting " { $emphasis "SYSTEM 'hello.dtd'" } ">" } "." } ;

HELP: <system-id>
{ $values { "system-literal" string } { "system-id" system-id } }
{ $description "Constructs a " { $link system-id } " tuple." } ;

HELP: public-id
{ $class-description "Describes the class of public identifiers within an XML DTD directive, such as " { $snippet "<!DOCTYPE open-hatch " { $emphasis "PUBLIC '-//Textuality//TEXT Standard open-hatch boilerplate//EN' 'http://www.textuality.com/boilerplate/OpenHatch.xml'" } ">" } } ;

HELP: <public-id>
{ $values { "pubid-literal" string } { "system-literal" string } { "public-id" public-id } }
{ $description "Constructs a " { $link system-id } " tuple." } ;

HELP: notation-decl
{ $class-description "Describes the class of element declarations, like " { $snippet "<!NOTATION jpg SYSTEM './jpgviewer'>" } "." } ;

HELP: <notation-decl>
{ $values { "name" string } { "id" string } { "notation-decl" notation-decl } }
{ $description "Creates an notation declaration object, of the class " { $link notation-decl } "." } ;

HELP: doctype-decl
{ $class-description "Describes the class of doctype declarations." } ;

HELP: <doctype-decl>
{ $values { "name" name } { "external-id" id } { "internal-subset" sequence } { "doctype-decl" doctype-decl } }
{ $description "Creates a new doctype declaration object, of the class " { $link doctype-decl } ". Only one of external-id or internal-subset will be non-null." } ;

HELP: unescaped
{ $class-description "When constructing XML documents to write to output, it can be useful to splice in a string which is already written. This tuple type allows for that. Printing an " { $snippet "unescaped" } " is the same is printing its " { $snippet "string" } " slot." } ;

HELP: <unescaped>
{ $values { "string" string } { "unescaped" unescaped } }
{ $description "Constructs an " { $link unescaped } " tuple, given a string." } ;

HELP: xml-chunk
{ $class-description "Encapsulates a balanced fragment of an XML document. This is a sequence (following the sequence protocol) of XML data types, eg " { $link string } "s and " { $link tag } "s." } ;

HELP: <xml-chunk>
{ $values { "seq" sequence } { "xml-chunk" xml-chunk } }
{ $description "Constructs an " { $link xml-chunk } " tuple, given a sequence to be its contents." } ;
