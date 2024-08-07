USING: help.markup help.syntax sequences ;

IN: base85

HELP: >base85
{ $values { "seq" sequence } { "base85" sequence } }
{ $description "Encode into Base85 encoding." } ;

HELP: base85>
{ $values { "base85" sequence } { "seq" sequence } }
{ $description "Decode from Base85 encoding." } ;

HELP: >z85
{ $values { "seq" sequence } { "z85" sequence } }
{ $description "Encode into MsgPack Z85 encoding." } ;

HELP: z85>
{ $values { "z85" sequence } { "seq" sequence } }
{ $description "Decode from MsgPack Z85 encoding." } ;

HELP: >ascii85
{ $values { "seq" sequence } { "ascii85" sequence } }
{ $description "Encode into Ascii85 encoding." } ;

HELP: ascii85>
{ $values { "ascii85" sequence } { "seq" sequence } }
{ $description "Decode from Ascii85 encoding." } ;

HELP: >adobe85
{ $values { "seq" sequence } { "adobe85" sequence } }
{ $description "Encode into Adobe85 encoding." } ;

HELP: adobe85>
{ $values { "adobe85" sequence } { "seq" sequence } }
{ $description "Decode from Adobe85 encoding." } ;

ARTICLE: "base85" "Base85 conversions"
"The " { $vocab-link "base85" } " vocabulary supports encoding and decoding of various Base85 encoding formats, including:"
$nl
"Base85 encoding:"
{ $subsections
    >base85
    >base85-lines
    base85>
}
"ASCII85 encoding:"
{ $subsections
    >ascii85
    >ascii85-lines
    ascii85>
}
"Adobe85 encoding:"
{ $subsections
    >adobe85
    adobe85>
}
"MsgPack Z85 encoding:"
{ $subsections
    >z85
    >z85-lines
    z85>
} ;

ABOUT: "base85"
