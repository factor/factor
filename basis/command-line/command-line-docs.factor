USING: help.markup help.syntax parser vocabs.loader strings ;
IN: command-line

HELP: run-bootstrap-init
{ $description "Runs the bootstrap initialization file in the user's home directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-boot-rc" } " on Unix and " { $snippet "factor-boot-rc" } " on Windows." } ;

HELP: run-user-init
{ $description "Runs the startup initialization file in the user's home directory, unless the " { $snippet "-no-user-init" } " command line switch was given. This file is named " { $snippet ".factor-rc" } " on Unix and " { $snippet "factor-rc" } " on Windows." } ;

HELP: cli-param
{ $values { "param" string } }
{ $description "Process a command-line switch."
$nl
"If the parameter contains " { $snippet "=" } ", the global variable named by the string before the equals sign is set to the string after the equals sign."
$nl
"If the parameter begins with " { $snippet "no-" } ", sets the global variable named by the parameter with the prefix removed to " { $link f } "."
$nl
"Otherwise, sets the global variable named by the parameter to " { $link t } "." } ;

HELP: cli-args
{ $values { "args" "a sequence of strings" } }
{ $description "Outputs the command line parameters which were passed to the Factor VM on startup." } ;

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

HELP: parse-command-line
{ $description "Called on startup to process command line arguments. This sets global variables with " { $link cli-param } ", runs source files, and evaluates the string given by the " { $snippet "-e" } " switch, if there is one." } ;

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
    { { $snippet "compiler" } "The compiler." }
    { { $snippet "tools" } "Terminal-based developer tools." }
    { { $snippet "help" } "The help system." }
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
    { { $snippet "-script" } { "Equivalent to " { $snippet "-quiet -run=none" } "." $nl "On Unix systems, Factor can be used for scripting - just create an executable text file whose first line is:" { $code "#! /usr/local/bin/factor -script" } "The space after " { $snippet "#!" } " is necessary because of Factor syntax." } }
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

ARTICLE: "rc-files" "Running code on startup"
"Factor looks for two files in your home directory."
{ $subsection "factor-boot-rc" }
{ $subsection "factor-rc" }
"The " { $snippet "-no-user-init" } " command line switch will inhibit the running of these files."
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

ARTICLE: "cli" "Command line usage"
"Zero or more command line arguments may be passed to the Factor runtime. Command line arguments starting with a dash (" { $snippet "-" } ") is interpreted as switches. All other arguments are taken to be file names to be run by " { $link run-file } "."
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
"The list of command line arguments can be obtained and inspected directly:"
{ $subsection cli-args }
"There is a way to override the default vocabulary to run on startup:"
{ $subsection main-vocab-hook } ;

ABOUT: "cli"
