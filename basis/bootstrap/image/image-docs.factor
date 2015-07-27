USING: bootstrap.image.private help.markup help.syntax io io.files
io.pathnames quotations strings words ;
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

HELP: architecture
{ $var-description "Bootstrap architecture name" } ;

HELP: bootstrap-startup-quot
{ $var-description "This image's startup quotation or " { $link f } ". "} ;

HELP: define-sub-primitive
{ $values { "quot" quotation } { "word" word } }
{ $description "Defines a sub primitive by running the quotation which is supposed to output assembler code. The word is then used to call the assembly." } ;

HELP: make-image
{ $values { "arch" string } }
{ $description "Creates a bootstrap image from sources, where " { $snippet "architecture" } " is one of the following:"
{ $code "\"x86.32\"" "\"unix-x86.64\"" "\"windows-x86.64\"" "\"linux-ppc\"" }
"The new image file is written to the " { $link resource-path } " and is named " { $snippet "boot." { $emphasis "architecture" } ".image" } "." } ;
