USING: arrays help.markup help.syntax strings ;
IN: elevate

ABOUT: elevate

ARTICLE: "elevate" "Cross-platform API for elevated permissions"
    "Thanks to " { $url "https://github.com/barneygale/elevate" }
;

HELP: elevated
{ $values { "command" { $or array string } } }
{ $description } ;