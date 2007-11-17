! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.launcher.private quotations
kernel ;
IN: io.launcher

HELP: +command+
{ $description "Launch descriptor key. A command line string, to be processed by the system's shell." } ;

HELP: +arguments+
{ $description "Launch descriptor key. A sequence of command line argument strings. The first element is the program to launch and the remaining arguments are passed to the program without further processing." } ;

HELP: +detached+
{ $description "Launch descriptor key. A boolean indicating whether " { $link run-process } " will return immediately, rather than wait for the program to complete."
$nl
"Default value is " { $link f } "." }
{ $notes "Cannot be used with " { $link <process-stream> } "." }
{ $see-also run-detached } ;

HELP: +environment+
{ $description "Launch descriptor key. An association mapping strings to strings, specifying environment variables to set for the spawned process. The association is combined with the current environment using the operation specified by the " { $link +environment-mode+ } " launch descriptor key."
$nl
"Default value is an empty association." } ;

HELP: +environment-mode+
{ $description "Launch descriptor key. Must equal of the following:"
    { $list
        { $link prepend-environment }
        { $link replace-environment }
        { $link append-environment }
    }
"Default value is " { $link append-environment } "."
} ;

HELP: prepend-environment
{ $description "Possible value of " { $link +environment-mode+ } " launch descriptor key. The child process environment consists of the value of the " { $link +environment+ } " key together with the current environment, with entries from the current environment taking precedence."
$nl
"This is used in situations where you want to spawn a child process with some default environment variables set, but allowing the user to override these defaults by changing the environment before launching Factor." } ;

HELP: replace-environment
{ $description "Possible value of " { $link +environment-mode+ } " launch descriptor key. The child process environment consists of the value of the " { $link +environment+ } " key."
$nl
"This is used in situations where you want full control over a child process environment, perhaps for security or testing." } ;

HELP: append-environment
{ $description "Possible value of " { $link +environment-mode+ } " launch descriptor key. The child process environment consists of the current environment together with the value of the " { $link +environment+ } " key, with entries from the " { $link +environment+ } " key taking precedence."
$nl
"This is used in situations where you want a spawn child process with some overridden environment variables." } ;

HELP: default-descriptor
{ $description "Association storing default values for launch descriptor keys." } ;

HELP: with-descriptor
{ $values { "desc" "a launch descriptor" } { "quot" quotation } } 
{ $description "Calls the quotation in a dynamic scope where keys from " { $snippet "desc" } " can be read as variables, and any keys not supplied assume their default value as set in " { $link default-descriptor } "." } ;

HELP: get-environment
{ $values { "env" "an association" } }
{ $description "Combines the current environment with the value of " { $link +environment+ } " using " { $link +environment-mode+ } "." } ;

HELP: run-process*
{ $values { "desc" "a launch descriptor" } }
{ $contract "Launches a process using the launch descriptor." }
{ $notes "User code should call " { $link run-process } " instead." } ;

HELP: >descriptor
{ $values { "obj" object } { "desc" "a launch descriptor" } }
{ $description "Creates a launch descriptor from an object, which must be one of the following:"
    { $list
        { "a string -- this is wrapped in a launch descriptor with a single " { $link +command+ } " key" }
        { "a sequence of strings -- this is wrapped in a launch descriptor with a single " { $link +arguments+ } " key" }
        { "an association, used to set launch parameters for additional control" }
    }
} ;

HELP: run-process
{ $values { "obj" object } }
{ $contract "Launches a process. The object can either be a string, a sequence of strings or a launch descriptor. See " { $link >descriptor } " for details." } ;

HELP: run-detached
{ $values { "obj" object } }
{ $contract "Launches a process without waiting for it to complete. The object can either be a string, a sequence of strings or a launch descriptor. See " { $link >descriptor } " for details." }
{ $notes
    "This word is functionally identical to passing a launch descriptor to " { $link run-process } " having the " { $link +detached+ } " key set."
} ;

HELP: <process-stream>
{ $values { "obj" object } { "stream" "a bidirectional stream" } }
{ $description "Launches a process and redirects its input and output via a paper of pipes which may be read and written as a stream." }
{ $notes "Closing the stream will block until the process exits." } ;

{ run-process run-detached <process-stream> } related-words

ARTICLE: "io.launcher" "Launching OS processes"
"The " { $vocab-link "io.launcher" } " vocabulary implements cross-platform process launching."
$nl
"Words which launch processes can take either a command line string, a sequence of command line arguments, or a launch descriptor:"
{ $list
    { "strings are wrapped in a launch descriptor with a single " { $link +command+ } " key" }
    { "sequences of strings are wrapped in a launch descriptor with a single " { $link +arguments+ } " key" }
    { "launch descriptors are associations, which can set extra launch parameters for finer control" }
}
"A launch descriptor is an association containing keys from the below set:"
{ $subsection +command+ }
{ $subsection +arguments+ }
{ $subsection +detached+ }
{ $subsection +environment+ }
{ $subsection +environment-mode+ }
"The following words are used to launch processes:"
{ $subsection run-process }
{ $subsection run-detached }
{ $subsection <process-stream> } ;

ABOUT: "io.launcher"
