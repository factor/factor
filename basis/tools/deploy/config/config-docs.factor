USING: help.markup help.syntax words alien.c-types assocs
kernel math ;
IN: tools.deploy.config

ARTICLE: "deploy-flags" "Deployment flags"
"There are two sets of deployment flags. The first set controls the major subsystems which are to be included in the deployment image:"
{ $subsection deploy-math?     }
{ $subsection deploy-unicode?   }
{ $subsection deploy-threads?  }
{ $subsection deploy-ui?       }
"The second set of flags controls the level of stripping to be performed on the deployment image; there is a trade-off between image size, and retaining functionality which is required by the application:"
{ $subsection deploy-io          }
{ $subsection deploy-reflection  }
{ $subsection deploy-word-props? }
{ $subsection deploy-c-types?    } ;

ABOUT: "deploy-flags"

HELP: deploy-name
{ $description "Deploy setting. The name of the executable."
$nl
"On Mac OS X, this becomes the name of the application bundle, with " { $snippet ".app" } " appended. On Windows, this becomes the name of the directory containing the executable." } ;

HELP: deploy-word-props?
{ $description "Deploy flag. If set, the deploy tool retains all word properties. Otherwise, it applies various heuristics to strip out un-needed word properties from words in the dictionary."
$nl
"Off by default. Enable this if the heuristics strip out required word properties." } ;

HELP: deploy-word-defs?
{ $description "Deploy flag. If set, the deploy tool retains word definition quotations for words compiled with the optimizing compiler. Otherwise, word definitions are stripped from words compiled with the optimizing compiler."
$nl
"Off by default. During normal execution, the word definition quotation of a word compiled with the optimizing compiler is not used, so disabling this flag can save space. However, some libraries introspect word definitions dynamically (for example, " { $vocab-link "inverse" } ") and so programs using these libraries must retain word definition quotations." } ;

HELP: deploy-c-types?
{ $description "Deploy flag. If set, the deploy tool retains the " { $link c-types } " table, otherwise this table is stripped out, saving space."
$nl
"Off by default."
$nl
"The optimizing compiler is able to fold away calls to various words which take a C type as an input if the C type is a literal string:"
{ $list
    { $link c-type }
    { $link heap-size }
    { $link <c-object> }
    { $link <c-array> }
    { $link malloc-object }
    { $link malloc-array }
}
"If your program looks up C types dynamically or from words which do not have a stack effect, you must enable this flag, because in these situations the C type lookup is not folded away and the global table must be consulted at runtime." } ;

HELP: deploy-math?
{ $description "Deploy flag. If set, the deployed image will contain support for " { $link ratio } " and " { $link complex } " types."
$nl
"On by default. Often the programmer will use rationals without realizing it. A small amount of space can be saved by stripping these features out, but some code may require changes to work properly." } ;

HELP: deploy-unicode?
{ $description "Deploy flag. If set, full Unicode " { $link POSTPONE: CHAR: } " syntax is included."
$nl
"Off by default. If your program needs to use " { $link POSTPONE: CHAR: } " with named characters, enable this flag." } ;

HELP: deploy-threads?
{ $description "Deploy flag. If set, thread support will be included in the final image."
$nl
"On by default. Most programs depend on libraries which use threads even if they don't use threads directly; for example, alarms, non-blocking I/O, and the UI are built on top of threads. If after testing your program still works without threads, you can disable this feature to save some space." } ;

HELP: deploy-ui?
{ $description "Deploy flag. If set, the Factor UI will be included in the deployed image."
$nl
"Off by default. Programs wishing to use the UI must be deployed with this flag on." } ;

HELP: deploy-io
{ $description "The level of I/O support required by the deployed image:"
    { $table
        { "Value" "Description" }
        { "1" "No input/output" }
        { "2" "Basic ANSI C streams" }
        { "3" "Non-blocking streams and networking" }
    }
"The default value is 2, basic ANSI C streams. This enables basic console and file I/O, however more advanced features such as networking are not available." } ;

HELP: deploy-reflection
{ $description "The level of reflection support required by the deployed image."
    { $table
        { "Value" "Description" }
        { "1" "No reflection" }
        { "2" "Retain word names" }
        { "3" "Prettyprinter" }
        { "4" "Debugger" }
        { "5" "Parser" }
        { "6" "Full environment" }
    }
"The defalut value is 1, no reflection. Programs which use the above features will need to be deployed with a higher level of reflection support." } ;

HELP: default-config
{ $values { "vocab" "a vocabulary specifier" } { "assoc" assoc } }
{ $description "Outputs the default deployment configuration for a vocabulary." } ;
