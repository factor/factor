USING: help.markup help.syntax words alien.c-types alien.data assocs
kernel math ;
IN: tools.deploy.config

ARTICLE: "deploy-flags" "Deployment flags"
"There are three sets of deployment flags. The first set controls the major subsystems which are to be included in the deployment image:"
{ $subsections
    deploy-unicode?
    deploy-ui?
}
"The second set of flags controls the level of stripping to be performed on the deployment image; there is a trade-off between image size, and retaining functionality which is required by the application:"
{ $subsections
    deploy-reflection
    deploy-word-props?
    deploy-c-types?
}
"Finally, the third set controls the format of the generated product:"
{ $subsections
    deploy-console?
}
{ $heading "Advanced deploy options" }
"There are some flags which may reduce deployed application size in trivial or specialized applications. These settings cannot usually be changed from their defaults and still produce a working application. These settings are not available from the deploy tool UI and must be set by manually editing a vocabulary's " { $snippet "deploy.factor" } " file."
{ $subsections
  deploy-help?
  deploy-math?
  deploy-threads?
  deploy-io
} ;

ABOUT: "deploy-flags"

HELP: deploy-name
{ $description "Deploy setting. The name of the executable."
$nl
"On macOS, this becomes the name of the application bundle, with " { $snippet ".app" } " appended. On Windows, this becomes the name of the directory containing the executable." } ;

HELP: deploy-word-props?
{ $description "Deploy flag. If set, the deploy tool retains all word properties. Otherwise, it applies various heuristics to strip out un-needed word properties from words in the dictionary."
$nl
"Off by default. Enable this if the heuristics strip out required word properties." } ;

HELP: deploy-word-defs?
{ $description "Deploy flag. If set, the deploy tool retains word definition quotations for words compiled with the optimizing compiler. Otherwise, word definitions are stripped from words compiled with the optimizing compiler."
$nl
"Off by default. During normal execution, the word definition quotation of a word compiled with the optimizing compiler is not used, so disabling this flag can save space. However, some libraries introspect word definitions dynamically (for example, " { $vocab-link "inverse" } ") and so programs using these libraries must retain word definition quotations." } ;

HELP: deploy-c-types?
{ $description "Deploy flag. If set, the deploy tool retains word properties containing metadata for C types and struct classes; otherwise, these properties are stripped out, saving space."
$nl
"Off by default."
$nl
"The optimizing compiler is able to fold away calls to various words which take a C type as an input if the C type is a literal string, for example,"
{ $list
    { $link c-type }
    { $link heap-size }
    { $link <c-array> }
    { $link <c-direct-array> }
    { $link malloc-array }
    { $link <ref> }
    { $link deref }
}
"If your program looks up C types dynamically or from words which do not have a stack effect, you must enable this flag, because in these situations the C type lookup code is not folded away and the word properties must be consulted at runtime." } ;

HELP: deploy-help?
{ $description "Deploy flag. If set, the deployed image will contain documentation for all included words." } ;

HELP: deploy-math?
{ $description "Deploy flag. If set, the deployed image will contain support for " { $link ratio } " and " { $link complex } " types."
$nl
"On by default."
{ $warning "It is unlikely that math support can be safely removed in most nontrivial applications because the library makes extensive use of ratios." } } ;

HELP: deploy-threads?
{ $description "Deploy flag. If set, thread support will be included in the final image."
$nl
"On by default."
{ $warning "It is unlikely that thread support can be safely removed in most nontrivial applications because thread support is required by the native IO library, the UI, and other fundamental libraries." } } ;

HELP: deploy-ui?
{ $description "Deploy flag. If set, the Factor UI will be included in the deployed image."
$nl
"Off by default. Programs wishing to use the UI must be deployed with this flag on." } ;

HELP: deploy-unicode?
{ $description "Deploy flag. If set, full Unicode " { $link POSTPONE: CHAR: } " syntax is included."
$nl
"Off by default. If your program needs to use " { $link POSTPONE: CHAR: } " with named characters, enable this flag." } ;

HELP: deploy-console?
{ $description "Deploy flag. If set, the deployed executable will be configured as a console application. On Windows, this means the application will be deployed in the console subsystem and will be attached to a console window. On macOS, this means the application will be deployed as a Unix executable instead of a macOS application bundle. On other Unix platforms, the flag has no effect."
$nl
"On by default."
{ $notes "On macOS, if " { $link deploy-ui? } " is set, the application will always be deployed as an application bundle regardless of the " { $snippet "deploy-console?" } " setting. The UI implementation on macOS relies on the application being in a bundle." } } ;

HELP: deploy-directory
{ $description "Used to specify the directory where the deployed executable will be created." } ;

HELP: deploy-io
{ $description "The level of I/O support required by the deployed image:"
    { $table
        { { $strong "Value" } { $strong "Description" } }
        { "1" "No input/output" }
        { "2" "Basic ANSI C streams" }
        { "3" "Non-blocking streams and networking" }
    }
"The default value is 3."
{ $warning "It is unlikely that the reflection level can be safely lowered in most nontrivial applications. Factor's networking libraries rely on level 3 support, and IO with ANSI C streams is blocking, which may cause unwanted behavior changes in applications that expect non-blocking IO behavior." } } ;

HELP: deploy-reflection
{ $description "The level of reflection support required by the deployed image."
    { $table
        { { $strong "Value" } { $strong "Description" } }
        { "1" "No reflection" }
        { "2" "Retain word names" }
        { "3" "Prettyprinter" }
        { "4" "Debugger" }
        { "5" "Parser" }
        { "6" "Full environment" }
    }
"The default value is 1, no reflection. Programs which use the above features will need to be deployed with a higher level of reflection support." } ;

HELP: default-config
{ $values { "vocab" "a vocabulary specifier" } { "assoc" assoc } }
{ $description "Outputs the default deployment configuration for a vocabulary." } ;
