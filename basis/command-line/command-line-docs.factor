USING: help.markup help.syntax io.pathnames strings system vocabs vocabs.loader ;
IN: command-line

HELP: run-bootstrap-init
{ $description "Runs the bootstrap initialization file in the user's " { $link home } " directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-boot-rc" } "." } ;

HELP: run-user-init
{ $description "Runs the startup initialization file in the user's " { $link home } " directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-rc" } "." } ;

HELP: load-vocab-roots
{ $description "Loads the newline-separated list of additional vocabulary roots from the file named " { $snippet ".factor-roots" } "." } ;

HELP: param
{ $values { "param" string } }
{ $description "Process a command-line switch."
$nl
"If the parameter contains " { $snippet "=" } ", the global variable named by the string before the equals sign is set to the string after the equals sign."
$nl
"If the parameter begins with " { $snippet "no-" } ", sets the global variable named by the parameter with the prefix removed to " { $link f } "."
$nl
"Otherwise, sets the global variable named by the parameter to " { $link t } "." } ;

HELP: (command-line)
{ $values { "args" "a sequence of strings" } }
{ $description "Outputs the raw command line parameters which were passed to the Factor VM on startup."
$nl
"We recommend using the " { $link vm-path } " and " { $link command-line } " symbols instead." } ;

HELP: command-line
{ $var-description "When Factor is run with a script, this variable contains the list of command line arguments which follow the name of the script on the command line. In deployed applications, it contains the full list of command line arguments. In all other cases it is set to " { $link f } "." }
{ $see-also vm-path } ;

HELP: main-vocab-hook
{ $var-description "Global variable holding a quotation which outputs a vocabulary name. UI backends set this so that the UI can automatically start if the prerequisites are met (for example, " { $snippet "$DISPLAY" } " being set on X11)." } ;

HELP: main-vocab
{ $values { "vocab" string } }
{ $description "Outputs the name of the vocabulary which is to be run on startup using the " { $link run } " word. The " { $snippet "-run" } " command line switch overrides this setting." } ;

HELP: default-cli-args
{ $description "Sets global variables corresponding to default command line arguments." } ;

ARTICLE: "runtime-cli-args" "Command line switches for the VM"
"A handful of command line switches are processed by the VM and not the library. They control low-level features."
{ $table
    { { $snippet "-i=" { $emphasis "image" } } { "Specifies the image file to use; see " { $link "images" } } }
    { { $snippet "-datastack=" { $emphasis "n" } } "Datastack size, kilobytes" }
    { { $snippet "-retainstack=" { $emphasis "n" } } "Retainstack size, kilobytes" }
    { { $snippet "-callstack=" { $emphasis "n" } } "Callstack size, kilobytes" }
    { { $snippet "-callbacks=" { $emphasis "n" } } "Callback heap size, kilobytes" }
    { { $snippet "-young=" { $emphasis "n" } } { "Size of youngest generation (0), megabytes" } }
    { { $snippet "-aging=" { $emphasis "n" } } "Size of aging generation (1), megabytes" }
    { { $snippet "-tenured=" { $emphasis "n" } } "Size of oldest generation (2), megabytes" }
    { { $snippet "-codeheap=" { $emphasis "n" } } "Code heap size, megabytes" }
    { { $snippet "-pic=" { $emphasis "n" } } "Maximum inline cache size. Setting of 0 disables inline caching, >= 1 enables polymorphic inline caching" }
    { { $snippet "-fep" } "enter low-level debbugger, aka fep mode immediately" }
    { { $snippet "-no-signals" } "turn off OS signal handling" }
    { { $snippet "-console" } "open console if possible" }
}
"If an " { $snippet "-i=" } " switch is not present, the default image file is used, which is usually a file named " { $snippet "factor.image" } " in the same directory as the Factor executable." ;

ARTICLE: "bootstrap-cli-args" "Command line switches for bootstrap"
"A number of command line switches can be passed to a bootstrap image to modify the behavior of the resulting image:"
{ $table
    { { $snippet "-output-image=" { $emphasis "image" } } { "Save the result to " { $snippet "image" } ". The default is " { $snippet "factor.image" } "." } }
    { { $snippet "-no-user-init" } { "Inhibits the running of user initialization files on startup. See " { $link "rc-files" } "." } }
    { { $snippet "-include=" { $emphasis "components..." } } "A list of components to include (see below)." }
    { { $snippet "-exclude=" { $emphasis "components..." } } "A list of components to exclude." }
    { { $snippet "-ui-backend=" { $emphasis "backend" } } { "One of " { $snippet "x11" } ", " { $snippet "windows" } ", or " { $snippet "cocoa" } ". The default is platform-specific." } }
}
"Bootstrap can load various optional components:"
{ $table
    { { $snippet "math" } "Rational and complex number support." }
    { { $snippet "threads" } "Thread support." }
    { { $snippet "compiler" } "The compiler." }
    { { $snippet "tools" } "Terminal-based developer tools." }
    { { $snippet "help" } "The help system." }
    { { $snippet "handbook" } "The help handbook." }
    { { $snippet "ui" } "The graphical user interface." }
    { { $snippet "ui.tools" } "Graphical developer tools." }
    { { $snippet "io" } "Non-blocking I/O and networking." }
}
"By default, all optional components are loaded. To load all optional components except for a given list, use the " { $snippet "-exclude=" } " switch; to only load specified optional components, use the " { $snippet "-include=" } "."
$nl
"For example, to build an image with the compiler but no other components, you could do:"
{ $code "./factor -i=boot.unix-x86.64.image -include=compiler" }
"To build an image with everything except for the user interface and graphical tools,"
{ $code "./factor -i=boot.unix-x86.64.image -exclude=\"ui ui.tools\"" }
"To generate a bootstrap image in the first place, see " { $link "bootstrap.image" } "." ;

ARTICLE: "standard-cli-args" "Command line switches for general usage"
"The following command line switches can be passed to a bootstrapped Factor image:"
{ $table
    { { $snippet "-help" } { "Show help for the command line switches." } }
    { { $snippet "-e=" { $emphasis "code" } } { "This specifies a code snippet to evaluate and then exit Factor." } }
    { { $snippet "-run=" { $emphasis "vocab" } } { { $snippet { $emphasis "vocab" } } " is the name of a vocabulary with a " { $link POSTPONE: MAIN: } " hook to run on startup, for example " { $vocab-link "listener" } " or " { $vocab-link "ui.tools" } "." } }
    { { $snippet "-no-user-init" } { "Inhibits the running of user initialization files on startup. See " { $link "rc-files" } "." } }
    { { $snippet "-roots=" { $emphasis "paths" } } { "Specify additional vocabulary roots. The list is colon-separated on Unix and semicolon-separated on Windows." } }
} ;

ARTICLE: ".factor-boot-rc" "Bootstrap initialization file"
"The bootstrap initialization file is named " { $snippet ".factor-boot-rc" } ". This file can contain " { $link require } " calls for vocabularies you use frequently, and other such long-running tasks that you do not want to perform every time Factor starts."
$nl
"A word to run this file from an existing Factor session:"
{ $subsections run-bootstrap-init }
"For example, if you changed " { $snippet ".factor-boot-rc" } " and do not want to bootstrap again, you can just invoke " { $link run-bootstrap-init } " in the listener." ;

ARTICLE: ".factor-rc" "Startup initialization file"
"The startup initialization file is named " { $snippet ".factor-rc" } ". If it exists, it is run every time Factor starts."
$nl
"A word to run this file from an existing Factor session:"
{ $subsections run-user-init } ;

ARTICLE: ".factor-roots" "Additional vocabulary roots file"
"The vocabulary roots file is named " { $snippet ".factor-roots" } ". If it exists, it is loaded every time Factor starts. It contains a newline-separated list of " { $link "vocabs.roots" } "."
$nl
"A word to load this file from an existing Factor session:"
{ $subsections load-vocab-roots } ;

ARTICLE: "rc-files" "Running code on startup"
"Factor looks for three optional files in the user's " { $link home } " directory."
{ $subsections
    ".factor-boot-rc"
    ".factor-rc"
    ".factor-roots"
}
"The " { $snippet "-no-user-init" } " command line switch will inhibit loading running of these files."
$nl
"Here is an example " { $snippet ".factor-boot-rc" } " which sets up your developer name:"
{ $code
    "USING: tools.scaffold namespaces ;"
    "\"Sheeple Sheepleton\" developer-name set-global"
} ;

ARTICLE: "command-line" "Command line arguments"
"Factor command line usage:"
{ $code "factor [options] [script] [arguments]" }
"Zero or more options can be passed in, followed by an optional script file name. If the script file is specified, it will be run on startup. Any arguments after the script file are stored in the following variable, with no further processing by Factor itself:"
{ $subsections command-line }
"Instead of running a script, it is also possible to run a vocabulary; this invokes the vocabulary's " { $link POSTPONE: MAIN: } " word:"
{ $code "factor [system switches...] -run=<vocab name>" }
"If no script file or " { $snippet "-run=" } " switch is specified, Factor will start " { $link "listener" } " or " { $link "ui-tools" } ", depending on the operating system."
$nl
"As stated above, arguments in the first part of the command line, before the optional script name, are interpreted by to the Factor system. These arguments all start with a dash (" { $snippet "-" } ")."
$nl
"Switches can take one of the following three forms:"
{ $list
    { { $snippet "-" { $emphasis "foo" } } " - sets the global variable " { $snippet "\"" { $emphasis "foo" } "\"" } " to " { $link t } }
    { { $snippet "-no-" { $emphasis "foo" } } " - sets the global variable " { $snippet "\"" { $emphasis "foo" } "\"" } " to " { $link f } }
    { { $snippet "-" { $emphasis "foo" } "=" { $emphasis "bar" } } " - sets the global variable " { $snippet "\"" { $emphasis "foo" } "\"" } " to " { $snippet "\"" { $emphasis "bar" } "\"" } }
}
{ $subsections
    "runtime-cli-args"
    "bootstrap-cli-args"
    "standard-cli-args"
}
"The raw list of command line arguments can also be obtained and inspected directly:"
{ $subsections (command-line) }
"There is a way to override the default vocabulary to run on startup, if no script name or " { $snippet "-run" } " switch is specified:"
{ $subsections main-vocab-hook } ;

ABOUT: "command-line"
