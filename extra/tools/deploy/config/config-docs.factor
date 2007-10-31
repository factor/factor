USING: help.markup help.syntax words alien.c-types assocs
kernel math ;
IN: tools.deploy.config

ARTICLE: "deploy-config" "Deployment configuration"
"The deployment configuration is a key/value mapping stored in the " { $snippet "deploy.factor" } " file in the vocabulary's directory. If this file does not exist, the default deployment configuration is used:"
{ $subsection default-config }
"The deployment configuration can be read and written with a pair of words:"
{ $subsection deploy-config }
{ $subsection set-deploy-config }
"A utility word is provided to load the configuration, change a flag, and store it back to disk:"
{ $subsection set-deploy-flag } ;

ARTICLE: "deploy-flags" "Deployment flags"
"There are two types of flags. The first set controls the major subsystems which are to be included in the deployment image:"
{ $subsection deploy-math?     }
{ $subsection deploy-compiler? }
{ $subsection deploy-ui?       }
"The second set of flags controls the level of stripping to be performed on the deployment image; there is a trade-off between image size, and retaining functionality which is required by the application:"
{ $subsection deploy-io          }
{ $subsection deploy-reflection  }
{ $subsection deploy-word-props? }
{ $subsection deploy-c-types?    } ;

ARTICLE: "prepare-deploy" "Preparing to deploy an application"
"In order to deploy an application as a stand-alone image, the application's vocabulary must first be given a " { $link POSTPONE: MAIN: } " hook. Then, a " { $emphasis "deployment configuration" } " must be created."
{ $subsection "deploy-config" }
{ $subsection "deploy-flags" } ;

ABOUT: "prepare-deploy"

HELP: deploy-word-props?
{ $description "Deploy flag. If set, the deploy tool retains all word properties. Otherwise, it applies various heuristics to strip out un-needed word properties from words in the dictionary."
$nl
"Off by default. Enable this if the heuristics strip out required word properties." } ;

HELP: deploy-c-types?
{ $description "Deploy flag. If set, the deploy tool retains the " { $link c-types } " table."
$nl
"Off by default. Disable this if your program calls " { $link c-type } ", " { $link heap-size } ", " { $link <c-object> } ", " { $link <c-array> } ", " { $link malloc-object } ", or " { $link malloc-array } " with a C type name which is not a literal pushed directly at the call site. In this situation, the compiler is unable to fold away the C type lookup, and thus must use the global table at runtime." } ;

HELP: deploy-math?
{ $description "Deploy flag. If set, the deployed image will contain support for " { $link ratio } " and " { $link complex } " types."
$nl
"On by default. Often the programmer will use rationals without realizing it. A small amount of space can be saved by stripping these features out, but some code may require changes to work properly." } ;

HELP: deploy-compiler?
{ $description "Deploy flag. If set, words in the deployed image will be compiled when possible."
$nl
"On by default. Most programs should be compiled, not only for performance but because features which depend on the C library interface only function after compilation." } ;

HELP: deploy-ui?
{ $description "Deploy flag. If set, the Factor UI will be included in the deployed image."
$nl
"Off by default. Programs wishing to use the UI must be deployed with this flag on." } ;

HELP: deploy-io
{ $description "The level of I/O support required by the deployed image." } ;

HELP: deploy-reflection
{ $description "The level of reflection support required by the deployed image." } ;

HELP: default-config
{ $values { "assoc" assoc } }
{ $description "Outputs the default deployment configuration." } ;

HELP: deploy-config
{ $values { "vocab" "a vocabulary specifier" } { "assoc" assoc } }
{ $description "Loads a vocabulary's deployment configuration from the " { $snippet "deploy.factor" } " file in the vocabulary's directory. If the file does not exist, the " { $link default-config } " is output." } ;

HELP: set-deploy-config
{ $values { "assoc" assoc } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a vocabulary's deployment configuration to the " { $snippet "deploy.factor" } " file in the vocabulary's directory." } ;

HELP: set-deploy-flag
{ $values { "value" object } { "key" object } { "vocab" "a vocabulary specifier" } }
{ $description "Modifies an entry in a vocabulary's deployment configuration on disk." } ;
