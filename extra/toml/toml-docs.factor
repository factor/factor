USING: help.markup help.syntax kernel strings toml ;
IN: toml+docs

HELP: toml>
{ $values { "string" string } { "assoc" object } }
{ $description "Decodes a configuration from the TOML format, represented as a " { $link string } "." } ;

ARTICLE: "toml" "Tom's Obvious Markup Language (TOML)"
"Tom's Obvious Markup Language (TOML) is described further in "
{ $url "https://en.wikipedia.org/wiki/TOML" } "."
$nl
"Decoding support for the TOML protocol:"
{ $subsections
    toml>
} ;

ABOUT: "toml"
