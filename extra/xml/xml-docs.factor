! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel xml xml.data xml.errors
xml.writer state-parser xml.tokenize xml.utilities xml.entities
strings sequences io ;

HELP: string>xml
{ $values { "string" "a string" } { "xml" "an xml document" } }
{ $description "converts a string into an " { $link xml }
    " datatype for further processing" }
{ $see-also xml>string xml-reprint } ;

HELP: xml>string
{ $values { "xml" "an xml document" } { "string" "a string" } }
{ $description "converts an xml document (" { $link xml } ") into a string" }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" }
{ $see-also string>xml xml-reprint write-xml } ;

HELP: xml-parse-error
{ $class-description "the exception class that all parsing errors in XML documents are in." } ;

HELP: xml-reprint
{ $values { "string" "a string of XML" } }
{ $description "parses XML and prints it out again, for testing purposes" }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" }
{ $see-also write-xml xml>string string>xml } ;

HELP: write-xml
{ $values { "xml" "an XML document" } }
{ $description "prints the contents of an XML document (" { $link xml } ") to stdio" }
{ $notes "does not preserve what type of quotes were used or what data was omitted from version declaration" }
{ $see-also xml>string xml-reprint read-xml } ;

HELP: read-xml
{ $values { "stream" "a stream that supports readln" }
    { "xml" "an XML document" } }
{ $description "exausts the given stream, reading an XML document from it" }
{ $see-also write-xml string>xml } ;

HELP: PROCESS:
{ $syntax "PROCESS: word" }
{ $values { "word" "a new word to define" } }
{ $description "creates a new word to process XML tags" }
{ $see-also POSTPONE: TAG: } ;

HELP: TAG:
{ $syntax "TAG: tag word definition... ;" }
{ $values { "tag" "an xml tag name" } { "word" "an XML process" } }
{ $description "defines what a process should do when it encounters a specific tag" }
{ $examples { $code "PROCESS: x ( tag -- )\nTAG: a x drop \"hi\" write ;" } }
{ $see-also POSTPONE: PROCESS: } ;

HELP: xml-each
{ $values { "tag" tag } { "quot" "a quotation ( element -- )" } }
{ $description "applies the quotation to each element (tags, strings, etc) in the tag, moving top-down" }
{ $see-also xml-map xml-subset } ;

HELP: xml-map
{ $values { "tag" tag } { "quot" "a quotation ( element -- element )" }
    { "tag" "an XML tag with the quotation applied to each element" } }
{ $description "applies the quotation to each element (tags, strings, etc) in the tag, moving top-down, and produces a new tag" }
{ $see-also xml-each xml-subset } ;

HELP: xml-subset
{ $values { "tag" tag } { "quot" "a quotation ( tag -- ? )" }
    { "seq" "sequence of elements" } }
{ $description "applies the quotation to each element (tags, strings, etc) in the tag, moving top-down, producing a sequence of elements which do not return false for the sequence" }
{ $see-also xml-map xml-each } ;

HELP: build-tag*
{ $values { "items" "sequence of elements" } { "name" "string" }
    { "tag" tag } }
{ $description "builds a " { $link tag } " with the specified name, in the namespace \"\" and URL \"\" containing the children listed in item" }
{ $see-also build-tag build-xml } ;

HELP: build-tag
{ $values { "item" "an element" } { "name" string } { "tag" tag } }
{ $description "builds a " { $link tag } " with the specified name containing the single child item" }
{ $see-also build-tag* build-xml } ;

HELP: build-xml
{ $values { "tag" tag } { "xml" "an XML document" } }
{ $description "builds an XML document out of a tag" }
{ $see-also build-tag* build-tag } ;

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
{ $see-also tag <contained-tag> build-tag build-tag* } ;

HELP: name
{ $class-description "represents an XML name, with the fields space (a string representing the namespace, as written in the document, tag (a string of the actual name of the tag) and url (a string of the URL that the namespace points to)" }
{ $see-also <name> tag } ;

HELP: <name> ( space tag url -- name )
{ $values { "space" "a string" } { "tag" "a string" } { "url" "a string" }
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
{ "main" tag } { "after" "a sequence of XML elements" } { "xml" "an XML document" } }
{ $description "creates an XML document, delegating to the main tag, with the specified prolog, before, and after" }
{ $see-also xml <tag> } ;

HELP: prolog
{ $class-description "represents an XML prolog, with the tuple fields version (containing \"1.0\" or \"1.1\"), encoding (a string representing the encoding type), and standalone (t or f, whether the document is standalone without external entities)" }
{ $see-also <prolog> xml } ;

HELP: <prolog> ( version encoding standalone -- prolog )
{ $values { "version" "a string, 1.0 or 1.1" }
{ "encoding" "a string" } { "standalone" "a boolean" } { "prolog" "an XML prolog" } }
{ $description "creates an XML prolog tuple" }
{ $see-also prolog <xml> } ;

HELP: comment
{ $class-description "represents a comment in XML. Has one slot, text, which contains the string of the comment" }
{ $see-also <comment> } ;

HELP: <comment> ( text -- comment )
{ $values { "text" "a string" } { "comment" "a comment" } }
{ $description "creates an XML comment tuple" }
{ $see-also comment } ;

HELP: instruction
{ $class-description "represents an XML instruction, such as <?xsl stylesheet='foo.xml'?>. Contains one slot, text, which contains the string between the question marks." }
{ $see-also <instruction> } ;

HELP: <instruction> ( text -- instruction )
{ $values { "text" "a string" } { "instruction" "an XML instruction" } }
{ $description "creates an XML parsing instruction, such as <?xsl stylesheet='foo.xml'?>." }
{ $see-also instruction } ;

HELP: names-match?
{ $values { "name1" "a name" } { "name2" "a name" } { "?" "t or f" } }
{ $description "checks to see if the two names match, that is, if all fields are equal, ignoring fields whose value is f in either name." }
{ $example "USE: xml.data" "T{ name f \"rpc\" \"methodCall\" f } T{ name f f \"methodCall\" \"http://www.xmlrpc.org/\" } names-match? ." "t" }
{ $see-also name } ;

HELP: xml-chunk
{ $values { "stream" "an input stream" } { "seq" "a sequence of elements" } }
{ $description "rather than parse a document, as " { $link read-xml } " does, this word parses and returns a sequence of XML elements (tags, strings, etc), ie a document fragment. This is useful for pieces of XML which may have more than one main tag." }
{ $see-also write-chunk read-xml } ;

HELP: xml-find
{ $values { "tag" "an XML element or document" } { "quot" "a quotation ( elem -- ? )" } { "tag" "an XML element which satisfies the predicate" } }
{ $description "finds the first element in the XML document which satisfies the predicate, moving from the outermost element to the innermost, top-down" }
{ $see-also xml-each xml-map get-id } ;

HELP: get-id
{ $values { "tag" "an XML tag or document" } { "id" "a string" } { "elem" "an XML element or f" } }
{ $description "finds the XML tag with the specified id, ignoring the namespace" }
{ $see-also xml-find } ;

HELP: process
{ $values { "object" "an opener, closer, contained or text element" } }
{ $description  "takes an XML event and, using the XML stack, processes it and adds it to the tree"  } ;

HELP: sax
{ $values { "stream" "an input stream" } { "quot" "a quotation ( xml-elem -- )" } }
{ $description "parses the XML document, and whenever an event is encountered (a tag piece, comment, parsing instruction, directive or string element), the quotation is called with that event on the stack. The quotation has all responsibility to deal with the event properly, and it is advised that generic words be used in dispatching on the event class." }
{ $notes "It is important to note that this is not SAX, merely an event-based XML view" }
{ $see-also read-xml } ;

HELP: opener
{ $class-description "describes an opening tag, like <a>. Contains two slots, name and attrs containing, respectively, the name of the tag and its attributes. Usually, the name-url will be f." }
{ $see-also closer contained } ;

HELP: closer
{ $class-description "describes a closing tag, like </a>. Contains one slot, name, containing the tag's name. Usually, the name-url will be f." }
{ $see-also opener contained } ;

HELP: contained
{ $class-description "represents a self-closing tag, like <a/>. Contains two slots, name and attrs containing, respectively, the name of the tag and its attributes. Usually, the name-url will be f." }
{ $see-also opener closer } ;

HELP: parse-text
{ $values { "string" "a string" } }
{ $description "moves the pointer from the current spot to the beginning of the next tag, parsing the text underneath, returning the text element it passed. This parses XML entities like &bar; &#97; and &amp;" }
{ $see-also parse-name } ;

HELP: parse-name
{ $values { "name" "an XML name" } }
{ $description "parses a " { $link name } " from the input stream. Returns a name with only the name-space and name-tag defined, with name-url=f" }
{ $see-also parse-text } ;

HELP: make-tag
{ $values { "tag" "an opener, closer or contained" } }
{ $description "assuming the pointer is just past a <, this word parses until the next > and emits a tuple representing the tag parsed" }
{ $see-also opener closer contained } ;

HELP: pull-xml
{ $class-description "represents the state of a pull-parser for XML. Has one slot, scope, which is a namespace which contains all relevant state information." }
{ $see-also <pull-xml> pull-event pull-elem } ;

HELP: <pull-xml>
{ $values { "pull-xml" "a pull-xml tuple" } }
{ $description "creates an XML pull-based parser which reads from the " { $link stdio } " stream, executing all initial XML commands to set up the parser." }
{ $see-also pull-xml pull-elem pull-event } ;

HELP: pull-elem
{ $values { "pull" "an XML pull parser" } { "xml-elem/f" "an XML tag, string, or f" } }
{ $description "gets the next XML element from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-event } ;

HELP: pull-event
{ $values { "pull" "an XML pull parser" } { "xml-event/f" "an XML tag event, string, or f" } }
{ $description "gets the next XML event from the given XML pull parser. Returns f upon exhaustion." }
{ $see-also pull-xml <pull-xml> pull-elem } ;

HELP: write-item
{ $values { "object" "an XML element" } }
{ $description "writes an XML element to the " { $link stdio } " stream." }
{ $see-also write-chunk write-xml } ;

HELP: write-chunk
{ $values { "seq" "an XML document fragment" } }
{ $description "writes an XML document fragment, ie a sequence of XML elements, to the " { $link stdio } " stream." }
{ $see-also write-item write-xml } ;

HELP: tag-named*
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "matching-tag" tag } }
{ $description "finds an XML tag with a matching name, recursively searching children and children of children" }
{ $see-also tags-named tag-named tags-named* } ;

HELP: tags-named*
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "tags-seq" "a sequence of tags" } }
{ $description "returns a sequence of all tags of a matching name, recursively searching children and children of children" }
{ $see-also tag-named tag-named* tags-named } ;

HELP: children>string
{ $values { "tag" "an XML tag or document" } { "string" "a string" } }
{ $description "concatenates the children of the tag, ignoring everything that's not a string" } ;

HELP: children-tags
{ $values { "tag" "an XML tag or document" } { "sequence" sequence } }
{ $description "gets the children of the tag that are themselves tags" }
{ $see-also first-child-tag } ;

HELP: first-child-tag
{ $values { "tag" "an XML tag or document" } { "tag" tag } }
{ $description "returns the first child of the given tag that is a tag" }
{ $see-also children-tags } ;

HELP: multitags
{ $class-description "XML parsing error describing the case where there is more than one main tag in a document. Contains no slots" } ;

HELP: notags
{ $class-description "XML parsing error describing the case where an XML document contains no main tag, or any tags at all" } ;

HELP: extra-attrs
{ $class-description "XML parsing error describing the case where the XML prolog (<?xml ...?>) contains attributes other than the three allowed ones, standalone, version and encoding. Contains one slot, attrs, which is a hashtable of all the extra attributes' names. Delegates to " { $link parsing-error } "." } ;

HELP: nonexist-ns
{ $class-description "XML parsing error describing the case where a namespace doesn't exist but it is used in a tag. Contains one slot, name, which contains the name of the undeclared namespace, and delegates to " { $link parsing-error } "." } ;

HELP: not-yes/no
{ $class-description "XML parsing error used to describe the case where standalone is set in the XML prolog to something other than 'yes' or 'no'. Delegates to " { $link parsing-error } " and contains one slot, text, which contains offending value." } ;

HELP: unclosed
{ $class-description "XML parsing error used to describe the case where the XML document contains classes which are not closed by the end of the document. Contains one slot, tags, a sequence of names." } ;

HELP: mismatched
{ $class-description "XML parsing error describing mismatched tags, eg <a></c>. Contains two slots: open is the name of the opening tag and close is the name of the closing tag. Delegates to " { $link parsing-error } " showing the location of the closing tag" } ;

HELP: expected
{ $class-description "XML parsing error describing when an expected token was not present. Delegates to " { $link parsing-error } ". Contains two slots, should-be, which has the expected string, and was, which has the actual string." } ;

HELP: no-entity
{ $class-description "XML parsing error describing the use of an undefined entity in a case where standalone is marked yes. Delegates to " { $link parsing-error } ". Contains one slot, thing, containing a string representing the entity." } ;

HELP: xml-string-error
{ $class-description "XML parsing error that delegates to " { $link parsing-error } " and represents an other, unspecified error, which is represented by the slot string, containing a string describing the error." } ;

HELP: open-tag
{ $class-description "represents a tag that does have children, ie is not a contained tag" }
{ $notes "the constructor used for this class is simply " { $link <tag> } "." }
{ $see-also tag contained-tag } ;

HELP: tag-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "matching-tag" tag } }
{ $description "finds the first tag with matching name which is the direct child of the given tag" }
{ $see-also tags-named* tag-named* tags-named } ;

HELP: tags-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "tags-seq" "a sequence of tags" } }
{ $description "finds all tags with matching name that are the direct children of the given tag" }
{ $see-also tag-named* tags-named* tag-named } ;

HELP: state-parse
{ $values { "stream" "an input stream" } { "quot" "a quotation ( -- )" } }
{ $description "takes a stream and runs an imperative parser on it, allowing words like " { $link next } " to be used within the context of the stream." } ;

HELP: pre/post-content
{ $class-description "describes the error where a non-whitespace string is used before or after the main tag in an XML document. Contains two slots: string contains the offending string, and pre? is t if it occured before the main tag and f if it occured after" } ;

HELP: entities
{ $description "a hash table from default XML entity names (like &amp; and &lt;) to the characters they represent. This is automatically included when parsing any XML document." }
{ $see-also html-entities } ;

HELP: html-entities
{ $description "a hash table from HTML entity names to their character values" }
{ $see-also entities with-html-entities } ;

HELP: with-entities
{ $values { "entities" "a hash table of strings to chars" }
    { "quot" "a quotation ( -- )" } }
{ $description "calls the quotation using the given table of entity values (symbolizing, eg, that &foo; represents CHAR: a) on top of the default XML entities" }
{ $see-also with-html-entities } ;

HELP: with-html-entities
{ $values { "quot" "a quotation ( -- )" } }
{ $description "calls the given quotation using HTML entity values" }
{ $see-also html-entities with-entities } ;

HELP: file>xml
{ $values { "filename" "a string representing a filename" }
    { "xml" "an XML document" } }
{ $description "opens the given file, reads it in as XML, closes the file and returns the corresponding XML tree" }
{ $see-also string>xml read-xml } ;

ARTICLE: { "xml" "basic" } "Basic words for XML processing"
    "These are the most basic words needed for processing an XML document"
    $nl
    "Parsing XML:"
    { $subsection string>xml }
    { $subsection read-xml }
    { $subsection xml-chunk }
    { $subsection file>xml }
    "Printing XML"
    { $subsection xml>string }
    { $subsection write-xml }
    { $subsection write-item }
    { $subsection write-chunk }
    "Other"
    { $subsection xml-reprint } ;

ARTICLE: { "xml" "classes" } "XML data classes"
    "Data types that XML documents are made of:"
    { $subsection name }
    { $subsection tag }
    { $subsection contained-tag }
    { $subsection open-tag }
    { $subsection xml }
    { $subsection prolog }
    { $subsection comment }
    { $subsection instruction } ;

ARTICLE: { "xml" "construct" } "XML data constructors"
    "These data types are constructed with:"
    { $subsection <name> }
    { $subsection <tag> }
    { $subsection <contained-tag> }
    { $subsection <xml> }
    { $subsection <prolog> }
    { $subsection <comment> }
    { $subsection <instruction> } ;

ARTICLE: { "xml" "utils" } "XML processing utilities"
    "Utilities for processing XML include..."
    $nl
    "System sfor creating words which dispatch on XML tags:"
    { $subsection POSTPONE: PROCESS: }
    { $subsection POSTPONE: TAG: }
    "Combinators for traversing XML trees:"
    { $subsection xml-each }
    { $subsection xml-map }
    { $subsection xml-subset }
    { $subsection xml-find }
    "Getting parts of an XML document or tag:"
    $nl
    "Note: the difference between tag-named* and tag-named is that the former searches recursively among all children and children of children of the tag, while the latter only looks at the direct children, and is therefore more efficient."
    { $subsection tag-named }
    { $subsection tags-named }
    { $subsection tag-named* }
    { $subsection tags-named* }
    { $subsection get-id }
    "Words for simplified generation of XML:"
    { $subsection build-tag* }
    { $subsection build-tag }
    { $subsection build-xml }
    "Other relevant words:"
    { $subsection children>string }
    { $subsection children-tags }
    { $subsection first-child-tag }
    { $subsection names-match? }
    { $subsection assert-tag } ;

ARTICLE: { "xml" "internal" } "Internals of the XML parser"
    "The XML parser creates its own parsing framework to process XML documents. The parser operates on streams. Important words involved in processing are:"
    { $subsection parse-text }
    { $subsection make-tag }
    { $subsection parse-name }
    { $subsection process }
    "The XML parser is implemented using the libs/state-parser module. For more information, see " { $link { "state-parser" "main" } } ;

ARTICLE: { "xml" "events" } "Event-based XML parsing"
    "In addition to DOM-style parsing based around " { $link read-xml } ", the XML module also provides SAX-style event-based parsing. This uses much of the same data structures as normal XML, with the exception of the classes " { $link xml } " and " { $link tag } " and as such, the articles " { $link { "xml" "classes" } } " and " { $link { "xml" "construct" } } " may be useful in learning how to process documents in this way. Other useful words are:"
    { $subsection sax }
    { $subsection opener }
    { $subsection closer }
    { $subsection contained }
    "There is also pull-based parsing to augment the push-parsing of SAX. This is probably easier to use and more logical. It uses the same parsing objects as the above style of parsing, except string elements are always in arrays, for example { \"\" }. Relevant pull-parsing words are:"
    { $subsection <pull-xml> }
    { $subsection pull-xml }
    { $subsection pull-event }
    { $subsection pull-elem } ;

ARTICLE: { "xml" "errors" } "XML parsing errors"
    "The XML module provides a rich and highly inspectable set of parsing errors. All XML errors are described by the union class " { $link xml-parse-error } " but there are many classes contained in that:"
    { $subsection multitags }
    { $subsection notags }
    { $subsection extra-attrs }
    { $subsection nonexist-ns }
    { $subsection not-yes/no }
    { $subsection unclosed }
    { $subsection mismatched }
    { $subsection expected }
    { $subsection no-entity }
    { $subsection pre/post-content }
    "Additionally, most of these errors delegate to " { $link parsing-error } " in order to provide more information"
    $nl
    "Note that, in parsing an XML document, only the first error is reported." ;

ARTICLE: { "xml" "entities" } "XML entities"
    "When XML is parsed, entities like &foo; are replaced with the characters they represent. A few entities like &amp; and &lt; are defined by default, but more are available, and the set of entities can be customized. Below are some words involved in XML entities, defined in the vocabulary 'entities':"
    { $subsection entities }
    { $subsection html-entities }
    { $subsection with-entities }
    { $subsection with-html-entities } ;

ARTICLE: { "xml" "intro" } "XML"
    "The XML module attempts to implement the XML 1.1 standard, converting strings of text into XML and vice versa. It currently is a work in progress."
    $nl
    "The XML module was implemented by Daniel Ehrenberg, with contributions from the Factor community"
    { $subsection { "xml" "basic" } }
    { $subsection { "xml" "classes" } }
    { $subsection { "xml" "construct" } }
    { $subsection { "xml" "utils" } }
    { $subsection { "xml" "internal" } }
    { $subsection { "xml" "events" } }
    { $subsection { "xml" "errors" } }
    { $subsection { "xml" "entities" } } ;

IN: xml

ABOUT: { "xml" "intro" }
