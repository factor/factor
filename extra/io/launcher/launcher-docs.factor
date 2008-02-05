! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations kernel io math ;
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

HELP: +stdin+
{ $description "Launch descriptor key. Must equal one of the following:"
    { $list
        { { $link f } " - standard input is inherited" }
        { { $link +closed+ } " - standard input is closed" }
        { "a path name - standard input is read from the given file, which must exist" }
    }
} ;

HELP: +stdout+
{ $description "Launch descriptor key. Must equal one of the following:"
    { $list
        { { $link f } " - standard output is inherited" }
        { { $link +closed+ } " - standard output is closed" }
        { "a path name - standard output is written to the given file, which is overwritten if it already exists" }
    }
} ;

HELP: +stderr+
{ $description "Launch descriptor key. Must equal one of the following:"
    { $list
        { { $link f } " - standard error is inherited" }
        { { $link +closed+ } " - standard error is closed" }
        { "a path name - standard error is written to the given file, which is overwritten if it already exists" }
    }
} ;

HELP: +closed+
{ $description "Possible value for " { $link +stdin+ } ", " { $link +stdout+ } ", and " { $link +stderr+ } " launch descriptors." } ;

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
{ $values { "desc" "a launch descriptor" } { "handle" "a process handle" } }
{ $contract "Launches a process using the launch descriptor." }
{ $notes "User code should call " { $link run-process } " instead." } ;

HELP: >descriptor
{ $values { "desc" "a launch descriptor" } { "desc" "a launch descriptor" } }
{ $description "Creates a launch descriptor from an object, which must be one of the following:"
    { $list
        { "a string -- this is wrapped in a launch descriptor with a single " { $link +command+ } " key" }
        { "a sequence of strings -- this is wrapped in a launch descriptor with a single " { $link +arguments+ } " key" }
        { "an association, used to set launch parameters for additional control" }
    }
} ;

HELP: run-process
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $description "Launches a process. The object can either be a string, a sequence of strings or a launch descriptor. See " { $link >descriptor } " for details." }
{ $notes "The output value can be passed to " { $link wait-for-process } " to get an exit code." } ;

HELP: run-detached
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $contract "Launches a process without waiting for it to complete. The object can either be a string, a sequence of strings or a launch descriptor. See " { $link >descriptor } " for details." }
{ $notes
    "This word is functionally identical to passing a launch descriptor to " { $link run-process } " having the " { $link +detached+ } " key set."
    $nl
    "The output value can be passed to " { $link wait-for-process } " to get an exit code."
} ;

HELP: kill-process
{ $values { "process" process } }
{ $description "Kills a running process. Does nothing if the process has already exited." } ;

HELP: kill-process*
{ $values { "handle" "a process handle" } }
{ $contract "Kills a running process." }
{ $notes "User code should call " { $link kill-process } " intead." } ;

HELP: process
{ $class-description "A class representing an active or finished process."
$nl
"Processes are output by " { $link run-process } " and " { $link run-detached } ", and are stored in the " { $link process-stream-process } " slot of " { $link process-stream } " instances."
$nl
"Processes can be passed to " { $link wait-for-process } "." } ;

HELP: process-stream
{ $class-description "A bidirectional stream for interacting with a running process. Instances are created by calling " { $link <process-stream> } ". The " { $link process-stream-process } " slot holds a " { $link process } " instance." } ;

HELP: <process-stream>
{ $values
  { "desc" "a launch descriptor" }
  { "stream" "a bidirectional stream" } }
{ $description "Launches a process and redirects its input and output via a pair of pipes which may be read and written as a stream." }
{ $notes "Closing the stream will block until the process exits." } ;

HELP: with-process-stream
{ $values
  { "desc" "a launch descriptor" }
  { "quot" quotation }
  { "status" "an exit code" } }
{ $description "Calls " { $snippet "quot" } " in a dynamic scope where " { $link stdio } " is rebound to a " { $link process-stream } ". After the quotation returns, waits for the process to end and outputs the exit code." } ;

HELP: wait-for-process
{ $values { "process" process } { "status" integer } }
{ $description "If the process is still running, waits for it to exit, otherwise outputs the exit code immediately. Can be called multiple times on the same process." } ;

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
"Redirecting standard input and output to files:"
{ $subsection +stdin+ }
{ $subsection +stdout+ }
{ $subsection +stderr+ }
"The following words are used to launch processes:"
{ $subsection run-process }
{ $subsection run-detached }
"Stopping processes:"
{ $subsection kill-process }
"Redirecting standard input and output to a pipe:"
{ $subsection <process-stream> }
{ $subsection with-process-stream }
"A class representing an active or finished process:"
{ $subsection process }
"Waiting for a process to end, or getting the exit code of a finished process:"
{ $subsection wait-for-process } ;

ABOUT: "io.launcher"
