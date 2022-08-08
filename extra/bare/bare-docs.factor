USING: byte-arrays help.markup help.syntax io kernel ;

IN: bare

HELP: read-bare
{ $values { "schema" "schema" } { "obj" object } }
{ $description "Decodes an object that was serialized in the BARE format using " { $snippet "schema" } ", reading from an " { $link input-stream } "." } ;

HELP: write-bare
{ $values { "obj" object } { "schema" "schema" } }
{ $description "Encodes an object into the BARE format using " { $snippet "schema" } ", writing to an " { $link output-stream } "." } ;

HELP: bare>
{ $values { "encoded" byte-array } { "schema" "schema" } { "obj" object } }
{ $description "Decodes an object that was serialized in the BARE format using " { $snippet "schema" } ", reading from a " { $link byte-array } "." } ;

HELP: >bare
{ $values { "obj" object } { "schema" "schema" } { "encoded" byte-array } }
{ $description "Encodes an object into the BARE format using " { $snippet "schema" } "." } ;

ARTICLE: "bare" "Binary Application Record Encoding (BARE)"
"The Binary Application Record Encoding (BARE) is a draft format defined at " 
{ $url "https://baremessages.org" } "."
$nl
"Decoding support for the BARE protocol:"
{ $subsections
    read-bare
    bare>
}
"Encoding support for the BARE protocol:"
{ $subsections
    write-bare
    >bare
}
"Using schema files:"
{ $subsections
    parse-schema
    load-schema
    \ SCHEMA:
} ;

ABOUT: "bare"
