USING: help.markup help.syntax io io.files io.pathnames strings ;
IN: bootstrap.image

ARTICLE: "bootstrap.image" "Bootstrapping new images"
"A new image can be built from source; this is known as " { $emphasis "bootstrap" } ". Bootstrap is a two-step process. The first stage is the creation of a bootstrap image from a running Factor instance:"
{ $subsections make-image }
"The second bootstrapping stage is initiated by running the resulting bootstrap image:"
{ $code "./factor -i=boot.x86.32.image" }
"This stage loads additional code, compiles all words, and dumps a final " { $snippet "factor.image" } "."
$nl
"The bootstrap process can be customized with command-line switches."
{ $see-also "runtime-cli-args" "bootstrap-cli-args" } ;

ABOUT: "bootstrap.image"

HELP: make-image
{ $values { "arch" string } }
{ $description "Creates a bootstrap image from sources, where " { $snippet "architecture" } " is one of the following:"
{ $code "x86.32" "unix-x86.64" "winnt-x86.64" "macosx-ppc" "linux-ppc" }
"The new image file is written to the " { $link resource-path } " and is named " { $snippet "boot." { $emphasis "architecture" } ".image" } "." } ;
