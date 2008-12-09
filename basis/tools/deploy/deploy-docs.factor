USING: help.markup help.syntax words alien.c-types assocs
kernel ;
IN: tools.deploy

ARTICLE: "prepare-deploy" "Preparing to deploy an application"
"In order to deploy an application as a stand-alone image, the application's vocabulary must first be given a " { $link POSTPONE: MAIN: } " hook. Then, a " { $emphasis "deployment configuration" } " must be created."
{ $subsection "deploy-config" }
{ $subsection "deploy-flags" } ;

ARTICLE: "tools.deploy" "Application deployment"
"The stand-alone application deployment tool compiles a vocabulary down to a native executable which runs the vocabulary's " { $link POSTPONE: MAIN: } " hook. Deployed executables do not depend on Factor being installed, and do not expose any source code, and thus are suitable for delivering commercial end-user applications."
$nl
"For example, we can deploy the " { $vocab-link "hello-world" } " demo which comes with Factor:"
{ $code "\"hello-ui\" deploy" }
{ $list
   { "On Mac OS X, this yields a program named " { $snippet "Hello world.app" } "." }
   { "On Windows, it yields a directory named " { $snippet "Hello world" } " containing a program named " { $snippet "hello-ui.exe" } "." }
   { "On Unix-like systems (Linux, BSD, Solaris, etc), it yields a directory named " { $snippet "Hello world" } " containing a program named " { $snippet "hello-ui" } "." }
}
"In all cases, running the program displays a window with a message."
$nl
"The deployment tool works by bootstrapping a fresh image, loading the vocabulary into this image, then applying various heuristics to strip the image down to minimal size."
$nl
"You must explicitly specify major subsystems which are required, as well as the level of reflection support needed. This is done by modifying the deployment configuration prior to deployment."
{ $subsection "prepare-deploy" }
"Once the necessary deployment flags have been set, the application can be deployed:"
{ $subsection deploy }
{ $see-also "ui.tools.deploy" } ;

ABOUT: "tools.deploy"

HELP: deploy
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Deploys " { $snippet "vocab" } ", saving the deployed image as " { $snippet { $emphasis "vocab" } ".image" } "." } ;
