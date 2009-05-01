USING: help.markup help.syntax parser vocabs.loader strings ;
IN: command-line

HELP: run-bootstrap-init
{ $description "Runs the bootstrap initialization file in the user's home directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-boot-rc" } " on Unix and " { $snippet "factor-boot-rc" } " on Windows." } ;

HELP: run-user-init
{ $description "Runs the startup initialization file in the user's home directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-rc" } " on Unix and " { $snippet "factor-rc" } " on Windows." } ;

HELP: load-vocab-roots
{ $description "Loads the newline-separated list of additional vocabulary roots from the file named " { $snippet ".factor-roots" } " on Unix and " { $snippet "factor-roots" } " on Windows." } ;

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
{ $description "Outputs the command line parameters which were passed to the Factor VM on startup." } ;

HELP: command-line
{ $var-description "The command line parameters which follow the name of the script on the command line." } ;

HELP: main-vocab-hook
{ $var-description "Global variable holding a quotation which outputs a vocabulary name. UI backends set this so that the UI can automatically start if the prerequisites are met (for example, " { $snippet "$DISPLAY" } " being set on X11)." } ;

HELP: main-vocab
{ $values { "vocab" string } }
{ $description "Outputs the name of the vocabulary which is to be run on startup using the " { $link run } " word. The " { $snippet "-run" } " command line switch overrides this setting." } ;

HELP: default-cli-args
{ $description "Sets global variables corresponding to default command line arguments." } ;

HELP: ignore-cli-args?
{ $values { "?" "a boolean" } }
{ $description "On Mac OS X, source files to run are supplied by the Cocoa API, so to avoid running them twice the startup code has to call this word." } ;

ARTICLE: "runtime-cli-args" "Command line switches for the VM"
"A handful of command line switches are processed by the VM and not the library. They control low-level features."
{ $table
    { { $snippet "-i=" { $emphasis "image" } } { "Specifies the image file to use; see " { $link "images" } } }
    { { $snippet "-datastack=" { $emphasis "n" } } "Data stack size, kilobytes" }
    { { $snippet "-retainstack=" { $emphasis "n" } } "Retain stack size, kilobytes" }
    { { $snippet "-generations=" { $emphasis "n" } } "Number of generations, must equal 1, 2 or 3" }
    { { $snippet "-young=" { $emphasis "n" } } { "Size of youngest generation (0), megabytes" } }
    { { $snippet "-aging=" { $emphasis "n" } } "Size of aging generation (1), megabytes" }
    { { $snippet "-tenured=" { $emphasis "n" } } "Size of oldest generation (2), megabytes" }
    { { $snippet "-codeheap=" { $emphasis "n" } } "Code heap size, megabytes" }
    { { $snippet "-pic=" { $emphasis "n" } } "Maximum inline cache size. Setting of 0 disables inline caching, > 1 enables polymorphic inline caching" }
    { { $snippet "-securegc" } "If specified, unused portions of the data heap will be zeroed out after every garbage collection" }
}
"If an " { $snippet "-i=" } " switch is not present, the default image file is used, which is usually a file named " { $snippet "factor.image" } " in the same directory as the runtime executable (on Windows and Mac OS X) or the current directory (on Unix)." ;

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
    { { $snippet "help.handbook" } "The help handbook." }
    { { $snippet "ui" } "The graphical user interface." }
    { { $snippet "ui.tools" } "Graphical developer tools." }
    { { $snippet "io" } "Non-blocking I/O and networking." }
}
"By default, all optional components are loaded. To load all optional components except for a given list, use the " { $snippet "-exclude=" } " switch; to only load specified optional components, use the " { $snippet "-include=" } "."
$nl
"For example, to build an image with the compiler but no other components, you could do:"
{ $code "./factor -i=boot.macosx-ppc.image -include=compiler" }
"To build an image with everything except for the user interface and graphical tools,"
{ $code "./factor -i=boot.macosx-ppc.image -exclude=\"ui ui.tools\"" }
"To generate a bootstrap image in the first place, see " { $link "bootstrap.image" } "." ;

ARTICLE: "standard-cli-args" "Command line switches for general usage"
"The following command line switches can be passed to a bootstrapped Factor image:"
{ $table
    { { $snippet "-e=" { $emphasis "code" } } { "This specifies a code snippet to evaluate. If you want Factor to exit immediately after, also specify " { $snippet "-run=none" } "." } }
    { { $snippet "-run=" { $emphasis "vocab" } } { { $snippet { $emphasis "vocab" } } " is the name of a vocabulary with a " { $link POSTPONE: MAIN: } " hook to run on startup, for example " { $vocab-link "listener" } ", " { $vocab-link "ui" } " or " { $vocab-link "none" } "." } }
    { { $snippet "-no-user-init" } { "Inhibits the running of user initialization files on startup. See " { $link "rc-files" } "." } }
    { { $snippet "-quiet" } { "If set, " { $link run-file } " and " { $link require } " will not print load messages." } }
} ;

ARTICLE: "factor-boot-rc" "Bootstrap initialization file"
"The botstrap initialization file is named " { $snippet "factor-boot-rc" } " on Windows and " { $snippet ".factor-boot-rc" } " on Unix. This file can contain " { $link require } " calls for vocabularies you use frequently, and other such long-running tasks that you do not want to perform every time Factor starts."
$nl
"A word to run this file from an existing Factor session:"
{ $subsection run-bootstrap-init }
"For example, if you changed " { $snippet ".factor-boot-rc" } " and do not want to bootstrap again, you can just invoke " { $link run-bootstrap-init } " in the listener." ;

ARTICLE: "factor-rc" "Startup initialization file"
"The startup initialization file is named " { $snippet "factor-rc" } " on Windows and " { $snippet ".factor-rc" } " on Unix. If it exists, it is run every time Factor starts."
$nl
"A word to run this file from an existing Factor session:"
{ $subsection run-user-init } ;

ARTICLE: "factor-roots" "Additional vocabulary roots file"
"The vocabulary roots file is named " { $snippet "factor-roots" } " on Windows and " { $snippet ".factor-roots" } " on Unix. If it exists, it is loaded every time Factor starts. It contains a newline-separated list of " { $link "vocabs.roots" } "."
$nl
"A word to run this file from an existing Factor session:"
{ $subsection load-vocab-roots } ;

ARTICLE: "rc-files" "Running code on startup"
"Factor looks for three optional files in your home directory."
{ $subsection "factor-boot-rc" }
{ $subsection "factor-rc" }
{ $subsection "factor-roots" }
"The " { $snippet "-no-user-init" } " command line switch will inhibit loading running of these files."
$nl
"If you are unsure where the files should be located, evaluate the following code:"
{ $code
    "USE: command-line"
    "\"factor-rc\" rc-path print"
    "\"factor-boot-rc\" rc-path print"
}
"Here is an example " { $snippet ".factor-boot-rc" } " which sets up GVIM editor integration, adds an additional vocabulary root (see " { $link "vocabs.roots" } "), and increases the font size in the UI by setting the DPI (dots-per-inch) variable:"
{ $code
    "USING: editors.gvim vocabs.loader ui.freetype namespaces sequences ;"
    "\"/opt/local/bin\" \\ gvim-path set-global"
    "\"/home/jane/src/\" vocab-roots get push"
    "100 dpi set-global"
} ;

ARTICLE: "cli" "Command line arguments"
"Factor command line usage:"
{ $code "factor [system switches...] [script args...]" }
"Zero or more system switches can be passed in, followed by an optional script file name. If the script file is specified, it will be run on startup, any arguments after the script file are stored in a variable, with no further processing by Factor itself:"
{ $subsection command-line }
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
{ $subsection "runtime-cli-args" }
{ $subsection "bootstrap-cli-args" }
{ $subsection "standard-cli-args" }
"The raw list of command line arguments can also be obtained and inspected directly:"
{ $subsection (command-line) }
"There is a way to override the default vocabulary to run on startup, if no script name or " { $snippet "-run" } " switch is specified:"
{ $subsection main-vocab-hook } ;

ABOUT: "cli"
