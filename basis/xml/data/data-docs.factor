USING: help.markup help.syntax sequences strings ;
IN: xml.data

ABOUT: "xml.data"

ARTICLE: "xml.data" "XML data types"
{ $vocab-link "xml.data" } " defines a simple document object model for XML. Everything is simply a tuple and can be manipulated as such."
{ $subsection { "xml.data" "classes" } }
{ $subsection { "xml.data" "constructors" } }
"Simple words for manipulating names:"
    { $subsection names-match? }
    { $subsection assure-name }
"For high-level tools for manipulating XML, see " { $vocab-link "xml.utilities" } ;

ARTICLE: { "xml.data" "classes" } "XML data classes"
    "Data types that XML documents are made of:"
    { $subsection name }
    { $subsection tag }
    { $subsection contained-tag }
    { $subsection open-tag }
    { $subsection xml }
    { $subsection prolog }
    { $subsection comment }
    { $subsection instruction }
    { $subsection element-decl }
    { $subsection attlist-decl }
    { $subsection entity-decl }
    { $subsection system-id }
    { $subsection public-id }
    { $subsection doctype-decl }
    { $subsection notation-decl } ;

ARTICLE: { "xml.data" "constructors" } "XML data constructors"
    "These data types are constructed with:"
    { $subsection <name> }
    { $subsection <tag> }
    { $subsection <contained-tag> }
    { $subsection <xml> }
    { $subsection <prolog> }
    { $subsection <comment> }
    { $subsection <instruction> }
    { $subsection <simple-name> }
    { $subsection <element-decl> }
    { $subsection <attlist-decl> }
    { $subsection <entity-decl> }
    { $subsection <system-id> }
    { $subsection <public-id> }
    { $subsection <doctype-decl> }
    { $subsection <notation-decl> } ;

HELP: tag
{ $class-description "tuple representing an XML tag, delegating to a " { $link
name } ", containing the slots attrs (an alist of names to strings) and children (a sequence). Tags implement the sequence protocol by acting like a sequence of its chidren, and the assoc protocol by acting like its attributes." }
{ $see-also <tag> name contained-tag xml } ;

HELP: <tag>
{ $values { "name" "an XML tag name" }
    { "attrs" "an alist of names to strings" }
    { "children" sequence }
    { "tag" tag } }
{ $description "constructs an XML " { $link tag } " with the name (not a string) and tag attributes specified in attrs and children specified" }
{ $see-also tag <contained-tag> } ;

HELP: name
{ $class-description "represents an XML name, with the fields space (a string representing the namespace, as written in the document, tag (a string of the actual name of the tag) and url (a string of the URL that the namespace points to)" }
{ $see-also <name> tag } ;

HELP: <name>
{ $values { "space" "a string" } { "main" "a string" } { "url" "a string" }
    { "name" "an XML tag name" } }
{ $description "creates a name tuple with the name-space space and the tag-name tag and the tag-url url." }
{ $see-also name <tag> } ;

HELP: contained-tag
{ $class-description "delegates to tag representing a tag like <a/> with no contents. The tag attributes are accessed with tag-attrs" }
{ $see-also tag <contained-tag> } ;

HELP: <contained-tag>
{ $values { "name" "an XML tag name" }
    { "attrs" "an alist from names to strings" }
    { "tag" tag } }
{ $description "creates an empty tag (like <a/>) with the specified name and tag attributes. This delegates to tag" }
{ $see-also contained-tag <tag> } ;

HELP: xml
{ $class-description "tuple representing an XML document, delegating to the main tag, containing the fields prolog (the header <?xml...?>), before (whatever comes between the prolog and the main tag) and after (whatever comes after the main tag)" }
{ $see-also <xml> tag prolog } ;

HELP: <xml>
{ $values { "prolog" "an XML prolog" } { "before" "a sequence of XML elements" }
{ "body" tag } { "after" "a sequence of XML elements" } { "xml" "an XML document" } }
{ $description "creates an XML document, delegating to the main tag, with the specified prolog, before, and after" }
{ $see-also xml <tag> } ;

HELP: prolog
{ $class-description "represents an XML prolog, with the tuple fields version (containing \"1.0\" or \"1.1\"), encoding (a string representing the encoding type), and standalone (t or f, whether the document is standalone without external entities)" }
{ $see-also <prolog> xml } ;

HELP: <prolog>
{ $values { "version" "a string, 1.0 or 1.1" }
{ "encoding" "a string" } { "standalone" "a boolean" } { "prolog" "an XML prolog" } }
{ $description "creates an XML prolog tuple" }
{ $see-also prolog <xml> } ;

HELP: comment
{ $class-description "represents a comment in XML. Has one slot, text, which contains the string of the comment" }
{ $see-also <comment> } ;

HELP: <comment>
{ $values { "text" "a string" } { "comment" "a comment" } }
{ $description "creates an XML comment tuple" }
{ $see-also comment } ;

HELP: instruction
{ $class-description "represents an XML instruction, such as <?xsl stylesheet='foo.xml'?>. Contains one slot, text, which contains the string between the question marks." }
{ $see-also <instruction> } ;

HELP: <instruction>
{ $values { "text" "a string" } { "instruction" "an XML instruction" } }
{ $description "creates an XML parsing instruction, such as <?xsl stylesheet='foo.xml'?>." }
{ $see-also instruction } ;

HELP: opener
{ $class-description "describes an opening tag, like <a>. Contains two slots, name and attrs containing, respectively, the name of the tag and its attributes. Usually, the name-url will be f." }
{ $see-also closer contained } ;

HELP: closer
{ $class-description "describes a closing tag, like </a>. Contains one slot, name, containing the tag's name. Usually, the name-url will be f." }
{ $see-also opener contained } ;

HELP: contained
{ $class-description "represents a self-closing tag, like <a/>. Contains two slots, name and attrs containing, respectively, the name of the tag and its attributes. Usually, the name-url will be f." }
{ $see-also opener closer } ;

HELP: open-tag
{ $class-description "represents a tag that does have children, ie is not a contained tag" }
{ $notes "the constructor used for this class is simply " { $link <tag> } "." }
{ $see-also tag contained-tag } ;

HELP: names-match?
{ $values { "name1" "a name" } { "name2" "a name" } { "?" "t or f" } }
{ $description "checks to see if the two names match, that is, if all fields are equal, ignoring fields whose value is f in either name." }
{ $example "USING: prettyprint xml.data ;" "T{ name f \"rpc\" \"methodCall\" f } T{ name f f \"methodCall\" \"http://www.xmlrpc.org/\" } names-match? ." "t" }
{ $see-also name } ;

HELP: assure-name
{ $values { "string/name" "a string or a name" } { "name" "a name" } }
{ $description "Converts a string into an XML name, if it is not already a name." } ;

HELP: <simple-name>
{ $values { "string" string } { "name" name } }
{ $description "Converts a string into an XML name with an empty prefix and URL." } ;
