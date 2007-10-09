USING: help.markup help.syntax words alien.c-types assocs
kernel ;
IN: tools.deploy

ARTICLE: "tools.deploy" "Stand-alone image deployment"
"The stand-alone image deployment tool takes a vocabulary and generates an image, which when passed to the VM, runs the vocabulary's " { $link POSTPONE: MAIN: } " hook."
$nl
"For example, we can deploy the " { $vocab-link "hello-world" } " demo which comes with Factor:"
{ $code "\"hello-world\" deploy" }
"This generates an image file named " { $snippet "hello-world.image" } ". Now we can start this image from the operating system's command line (see " { $link "runtime-cli-args" } "):"
{ $code "./factor -i=hello-world.image" "Hello world" }

"Once the necessary deployment flags have been set, a deployment image can be generated:"
{ $subsection deploy } ;

ABOUT: "tools.deploy"

HELP: deploy*
{ $values { "vm" "a pathname string" } { "image" "a pathname string" } { "vocab" "a vocabulary specifier" } { "config" assoc } }
{ $description "Deploys " { $snippet "vocab" } ", which must have a " { $link POSTPONE: MAIN: } " hook, using the specified VM and configuration. The deployed image is saved as " { $snippet "image" } "." }
{ $notes "This is a low-level word and in most cases " { $link deploy } " should be called instead." } ;

HELP: deploy
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Deploys " { $snippet "vocab" } ", saving the deployed image as " { $snippet { $emphasis "vocab" } ".image" } "." } ;
