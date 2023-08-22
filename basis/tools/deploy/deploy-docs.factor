USING: combinators.private help.markup help.syntax kernel
tools.deploy.config ;
IN: tools.deploy

ARTICLE: "prepare-deploy" "Preparing to deploy an application"
"In order to deploy an application as a stand-alone image, the application's vocabulary must first be given a " { $link POSTPONE: MAIN: } " hook. Then, a " { $emphasis "deployment configuration" } " must be created."
{ $subsections
    "deploy-config"
    "deploy-flags"
    "deploy-resources"
} ;

ARTICLE: "deploy-resources" "Deployed resource files"
"To include additional files in your deployed application, specify their names in a vocabulary's " { $snippet "resources.txt" } " file. The " { $snippet "resources.txt" } " file contains one glob pattern per line. These patterns are expanded relative to the vocabulary directory; files outside of the vocabulary directory cannot be referenced. If a file inside the vocabulary directory matches any of these patterns, it will be included in deployed applications that reference the vocabulary. If a subdirectory matches, its contents will be included recursively."
$nl
"If the deployed vocabulary includes an icon file for the current platform, it will be embedded in the deployed application as its GUI icon. See " { $link "vocabs.icons" } "." ;

ARTICLE: "tools.deploy.usage" "Deploy tool usage"
"Once the necessary deployment flags have been set, the application can be deployed:"
{ $subsections deploy deploy-image-only }
"For example, you can deploy the " { $vocab-link "hello-ui" } " demo which comes with Factor. Note that this demo already has a deployment configuration, so nothing needs to be configured:"
{ $code "\"hello-ui\" deploy" }
{ $list
    { "On Mac OS X, this yields a program named " { $snippet "Hello world.app" } "." }
    { "On Windows, it yields a directory named " { $snippet "Hello world" } " containing a program named " { $snippet "hello-ui.exe" } "." }
    { "On Unix-like systems (Linux, BSD, Solaris, etc), it yields a directory named " { $snippet "Hello world" } " containing a program named " { $snippet "hello-ui" } "." }
}
"On all platforms, running the program will display a window with a message." ;

ARTICLE: "tools.deploy.impl" "Deploy tool implementation"
"The deployment tool works by bootstrapping a fresh image, loading the vocabulary into this image, then applying various heuristics to strip the image down to minimal size."
$nl
"The deploy tool generates " { $emphasis "staging images" } " containing major subsystems, and uses the staging images to derive the final application image. The first time an application is deployed using a major subsystem, such as the UI, a new staging image is made, which can take a few minutes. Subsequent deployments of applications using this subsystem will be much faster." ;

ARTICLE: "tools.deploy.caveats" "Deploy tool caveats"
{ $heading "Behavior of " { $link boa } }
"In deployed applications, the " { $link boa } " word does not verify that the parameters on the stack satisfy the tuple's slot declarations, if any. This reduces deploy image size but can make bugs harder to track down. Make sure your program is fully debugged before deployment."
{ $heading "Behavior of " { $link POSTPONE: execute( } }
"Similarly, the " { $link POSTPONE: execute( } " word does not check word stack effects in deployed applications, since stack effects are stripped out, and so it behaves exactly like " { $link POSTPONE: execute-effect-unsafe } "."
{ $heading "Behavior of " { $link POSTPONE: call-next-method } }
"The " { $link POSTPONE: call-next-method } " word does not check if the input is of the right type in deployed applications."
{ $heading "Error reporting" }
"If the " { $link deploy-reflection } " level in the configuration is low enough, the debugger is stripped out, and error messages can be rather cryptic. Increase the reflection level to get readable error messages."
{ $heading "Choosing the right deploy flags" }
"Finding the correct deploy flags is a trial and error process; you must find a tradeoff between deployed image size and correctness. If your program uses dynamic language features, you may need to elect to strip out fewer subsystems in order to have full functionality." ;

ARTICLE: "tools.deploy" "Application deployment"
"The stand-alone application deployment tool, implemented in the " { $vocab-link "tools.deploy" } " vocabulary, compiles a vocabulary down to a native executable which runs the vocabulary's " { $link POSTPONE: MAIN: } " hook. Deployed executables do not depend on Factor being installed, and do not expose any source code, and thus are suitable for delivering commercial end-user applications."
$nl
"Most of the time, the words in the " { $vocab-link "tools.deploy" } " vocabulary should not be used directly; instead, use " { $link "ui.tools.deploy" } "."
$nl
"You must explicitly specify major subsystems which are required, as well as the level of reflection support needed. This is done by modifying the deployment configuration prior to deployment."
{ $subsections
    "prepare-deploy"
    "tools.deploy.usage"
    "tools.deploy.impl"
    "tools.deploy.caveats"
} ;

ABOUT: "tools.deploy"

HELP: deploy
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Deploys " { $snippet "vocab" } " into a packaged application. This will create a directory containing the Factor VM, a deployed image set up to run the " { $link POSTPONE: MAIN: } " entry point of " { $snippet "vocab" } " at startup, and any " { $link "deploy-resources" } " and shared libraries the application depends on. On Mac OS X, the deployment directory will be a standard " { $snippet ".app" } " bundle executable from Finder. To only generate the Factor image, use " { $link deploy-image-only } "." } ;

HELP: deploy-image-only
{ $values { "vocab" "a vocabulary specifier" } { "image" "a pathname" } }
{ $description "Deploys " { $snippet "vocab" } ", saving the deployed image to the location specified by " { $snippet "image" } ". This only builds the Factor image for the vocabulary; to create a complete packaged application, use " { $link deploy } "." } ;

{ deploy deploy-image-only } related-words
