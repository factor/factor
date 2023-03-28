! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs calendar help.markup help.syntax io io.files
io.launcher.private kernel literals quotations splitting ;
IN: io.launcher

ARTICLE: "io.launcher.command" "Specifying a command"
"The " { $snippet "command" } " slot of a " { $link process } " can contain either a string or a sequence of strings. In the first case, the string is processed in an operating system-specific manner. In the second case, the first element is a program name and the remaining elements are passed to the program as command-line arguments." ;

ARTICLE: "io.launcher.detached" "Running processes in the background"
"By default, " { $link run-process } " waits for the process to complete. To run a process without waiting for it to finish, set the " { $snippet "detached" } " slot of a " { $link process } ", or use the following word:"
{ $subsections run-detached } ;

ARTICLE: "io.launcher.hidden" "Running hidden processes"
"By default, child processes can create and display their own (console and other) windows. To signal to a process that it should stay hidden, set the " { $slot "hidden" } " slot of the " { $link process } " before running it. The processes are free to ignore this signal."
$nl
"The " { $link <process-stream> } " and " { $link with-process-stream } " words set this flag. On Windows this helps to run console applications without flashing their windows in the foreground." ;

ARTICLE: "io.launcher.environment" "Setting environment variables"
"The " { $snippet "environment" } " slot of a " { $link process } " contains an association mapping environment variable names to values. The interpretation of environment variables is operating system-specific."
$nl
"The " { $snippet "environment-mode" } " slot controls how the environment of the current Factor instance is composed with the value of the " { $snippet "environment" } " slot:"
{ $subsections
    +prepend-environment+
    +replace-environment+
    +append-environment+
}
"The default value is " { $link +append-environment+ } "." ;

ARTICLE: "io.launcher.redirection" "Input/output redirection"
"On all operating systems, the default input/output/error streams can be redirected."
$nl
"To specify redirection, set the " { $snippet "stdin" } ", " { $snippet "stdout" } " and " { $snippet "stderr" } " slots of a " { $link process } " to one of the following values:"
{ $list
    { { $link f } " - default value; the stream is either inherited from the current process, or is a " { $link <process-stream> } " pipe" }
    { { $link +closed+ } " - the stream is closed; reads will return end of file and writes will fail" }
    { { $link +stdout+ } " - a special value for the " { $snippet "stderr" } " slot only, indicating that the standard output and standard error streams should be merged" }
    { "a path name - the stream is sent to the given file, which must exist for input and is created automatically on output" }
    { "an " { $link appender } " wrapping a path name - output is sent to the end of the given file, as with " { $link <file-appender> } }
    { "a file stream or a socket - the stream is connected to the given Factor stream, which cannot be used again from within Factor and must be closed after the process has been started" }
} ;

ARTICLE: "io.launcher.group" "Setting process groups"
"The process group of a child process can be controlled by setting the " { $snippet "group" } " slot of a " { $link process } " tuple:"
{ $list
    { $link +same-group+ }
    { $link +new-group+ }
    { $link +new-session+ }
}
"The default value is " { $link +same-group+ } ", which denotes that the child process should be part of the process group of the parent process. The " { $link +new-group+ } " option creates a new process group, while the " { $link +new-session+ } " creates a new session." ;

ARTICLE: "io.launcher.priority" "Setting process priority"
"The priority of the child process can be set by storing one of the below symbols in the " { $snippet "priority" } " slot of a " { $link process } " tuple:"
{ $list
    { $link +lowest-priority+ }
    { $link +low-priority+ }
    { $link +normal-priority+ }
    { $link +high-priority+ }
    { $link +highest-priority+ }
}
"The default value is " { $link f } ", which denotes that the child process should inherit the current process priority." ;

HELP: +closed+
{ $description "Possible value for the " { $snippet "stdin" } ", " { $snippet "stdout" } ", and " { $snippet "stderr" } " slots of a " { $link process } "." } ;

HELP: +stdout+
{ $description "Possible value for the " { $snippet "stderr" } " slot of a " { $link process } "." } ;

HELP: appender
{ $class-description "An object representing a file to append to. Instances are created with " { $link <appender> } "." } ;

HELP: <appender>
{ $values { "path" "a pathname string" } { "appender" appender } }
{ $description "Creates an object which may be stored in the " { $snippet "stdout" } " or " { $snippet "stderr" } " slot of a " { $link process } " instance." } ;

HELP: +prepend-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"If this value is set, the child process environment consists of the value of the " { $snippet "environment" } " slot together with the current environment, with entries from the current environment taking precedence."
$nl
"This is used in situations where you want to spawn a child process with some default environment variables set, but allowing the user to override these defaults by changing the environment before launching Factor." } ;

HELP: +replace-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"The child process environment consists of the value of the " { $snippet "environment" } " slot."
$nl
"This is used in situations where you want full control over a child process environment, perhaps for security or testing." } ;

HELP: +append-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"The child process environment consists of the current environment together with the value of the " { $snippet "environment" } " key, with entries from the " { $snippet "environment" } " key taking precedence."
$nl
"This is used in situations where you want a spawn child process with some overridden environment variables." } ;

ARTICLE: "io.launcher.timeouts" "Process run-time timeouts"
"The " { $snippet "timeout" } " slot of a " { $link process } " can be set to a " { $link duration } " specifying a maximum running time for the process. If " { $link wait-for-process } " is called and the process does not exit before the duration expires, it will be killed." ;

HELP: get-environment
{ $values { "process" process } { "env" assoc } }
{ $description "Combines the current environment with the value of the " { $snippet "environment" } " slot of the " { $link process } " using the " { $snippet "environment-mode" } " slot." } ;

HELP: (current-process)
{ $values { "handle" "a process handle" } }
{ $description "Returns the handle of the current process." }
{ $examples
  { $example
    "USING: io.launcher math prettyprint ;"
    "(current-process) number? ."
    "t"
  }
} ;

HELP: (run-process)
{ $values { "process" process } { "handle" "a process handle" } }
{ $contract "Launches a process." }
{ $notes "User code should call " { $link run-process } " instead." } ;

HELP: run-process
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $description "Launches a process. The object can either be a string, a sequence of strings or a " { $link process } ". See " { $link "io.launcher.descriptors" } " for details." }
{ $examples
  { $unchecked-example
    "USING: io.launcher prettyprint ;"
    "\"pwd\" run-process ."
    "T{ process\n    { command \"pwd\" }\n    { environment H{ } }\n    { environment-mode +append-environment+ }\n    { group +same-group+ }\n    { status 0 }\n}"
  }
}
{ $notes "The output value will either have the exit code set or can be passed to " { $link wait-for-process } " to get an exit code in the case of a " { $snippet "detached" } " process." } ;

HELP: run-processes
{ $values { "descs" "a sequence of launch descriptors" } { "processes" "a sequence of " { $link process } } }
{ $description "Launches a sequence of processes that will execute in serial by default or in parallel if " { $snippet "detached" } " is true. Each desc can either be a string, a sequence of strings or a " { $link process } ". See " { $link "io.launcher.descriptors" } " for details." }
{ $examples
  { $unchecked-example
    "USING: io.launcher prettyprint ;"
    "{ \"ls\" \"ls\" } run-processes ."
    "{ T{ process\n    { command \"ls\" }\n    { environment H{ } }\n    { environment-mode +append-environment+ }\n    { group +same-group+ }\n    { status 0 }\n}\nT{ process\n    { command \"ls\" }\n    { environment H{ } }\n    { environment-mode +append-environment+ }\n    { group +same-group+ }\n    { status 0 }\n} }"
  }
}
{ $notes "The output values will have an exit code set or can be passed to " { $link wait-for-process } " to get an exit code in the case of " { $snippet "detached" } " processes." } ;

HELP: run-detached
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $contract "Launches a process without waiting for it to complete. The object can either be a string, a sequence of strings or a " { $link process } ". See " { $link "io.launcher.descriptors" } " for details." }
{ $notes
    "This word is functionally identical to passing a " { $link process } " to " { $link run-process } " having the " { $snippet "detached" } " slot set."
    $nl
    "The output value can be passed to " { $link wait-for-process } " to get an exit code."
} ;

HELP: process-failed
{ $values { "code" "an exit status" } }
{ $description "Throws a " { $link process-failed } " error." }
{ $error-description "Thrown by " { $link try-process } " if the process exited with a non-zero status code." } ;

HELP: try-process
{ $values { "desc" "a launch descriptor" } }
{ $description "Launches a process and waits for it to complete. If it exits with a non-zero status code, throws a " { $link process-failed } " error." }
{ $examples
  { $unchecked-example
    "USING: continuations io.launcher prettyprint ;"
    "[ \"i-dont-exist\" try-process ] [ ] recover ."
    $[
        {
            "T{ process-failed"
            "    { process"
            "        T{ process"
            "            { command \"i-dont-exist\" }"
            "            { environment H{ } }"
            "            { environment-mode +append-environment+ }"
            "            { group +same-group+ }"
            "            { status 255 }"
            "        }"
            "    }"
            "}"
        } join-lines
    ]
  }
} ;

{ run-process run-processes try-process run-detached } related-words

HELP: kill-process
{ $values { "process" process } }
{ $description "Kills a running process. Does nothing if the process has already exited." }
{ $examples
  { $unchecked-example
    "USING: io.launcher ;"
    "\"cat\" run-detached kill-process"
    ""
  }
} ;

HELP: (kill-process)
{ $values { "process" "process" } }
{ $contract "Kills a running process." }
{ $notes "User code should call " { $link kill-process } " instead." } ;

HELP: process
{ $class-description "A class representing a process. Instances are created by calling " { $link <process> } "." } ;

HELP: <process>
{ $values { "process" process } }
{ $description "Creates a new, empty process. It must be filled in before being passed to " { $link run-process } "." } ;

HELP: <process-stream>
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "stream" "a bidirectional stream" } }
{ $description "Launches a process and redirects its input and output via a pair of pipes which may be read and written as a stream with the given encoding." }
{ $notes "The process is started with the " { $slot "hidden" } " slot set to " { $link t } "." }
{ $see-also "io.launcher.hidden" } ;

HELP: <process-reader>
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "stream" "an input stream" } }
{ $description "Launches a process and redirects its output via a pipe which may be read as a stream with the given encoding." } ;

HELP: <process-writer>
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "stream" "an output stream" }
}
{ $description "Launches a process and redirects its input via a pipe which may be written to as a stream with the given encoding." } ;

HELP: with-process-stream
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "quot" quotation }
}
{ $description "Launches a process and redirects its input and output via a pair of pipes. The quotation is called with " { $link input-stream } " and " { $link output-stream } " rebound to these pipes." }
{ $notes "The process is started with the " { $slot "hidden" } " slot set to " { $link t } "." }
{ $see-also "io.launcher.hidden" } ;

HELP: with-process-reader
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "quot" quotation }
}
{ $description "Launches a process and redirects its output via a pipe. The quotation is called with " { $link input-stream } " rebound to this pipe." }
{ $examples
  { $unchecked-example
    "USING: io.launcher prettyprint io.encodings.utf8 ;"
    "\"ls -dl /etc\" utf8 [ read-contents ] with-process-reader ."
    "\"drwxr-xr-x 213 root root 12288 mar 11 18:52 /etc\\n\""
  }
} ;

HELP: with-process-writer
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "quot" quotation }
}
{ $description "Launches a process and redirects its input via a pipe. The quotation is called with " { $link output-stream } " rebound to this pipe." } ;

HELP: wait-for-process
{ $values { "process" process } { "status" object } }
{ $description "If the process is still running, waits for it to exit, otherwise outputs the status code immediately. Can be called multiple times on the same process." }
{ $notes "The status code is operating system specific; it may be an integer, or another object (the latter is the case on Unix if the process was killed by a signal). However, one cross-platform behavior code can rely on is that a status code of 0 indicates success." } ;

ARTICLE: "io.launcher.descriptors" "Launch descriptors"
"Words which launch processes can take either a command line string, a sequence of command line arguments, or a " { $link process } "."
$nl
"Strings and string arrays are wrapped in a new empty " { $link process } " with the " { $snippet "command" } " slot set. This covers basic use-cases where no launch parameters need to be set."
$nl
"A " { $link process } " instance can be created directly and passed to launching words for more control. It must be a fresh instance which has never been spawned before. To spawn a process several times from the same descriptor, " { $link clone } " the descriptor first." ;

ARTICLE: "io.launcher.lifecycle" "The process lifecycle"
"A freshly instantiated " { $link process } " represents a set of launch parameters."
{ $subsections
    process
    <process>
}
"Words for launching processes take a fresh process which has never been started before as input, and output a copy as output."
{ $subsections process-started? }
"The " { $link process } " instance output by launching words contains all original slot values in addition to the " { $snippet "handle" } " slot, which indicates the process is currently running."
{ $subsections process-running? }
"It is possible to wait for a process to exit:"
{ $subsections wait-for-process }
"A running process can also be killed:"
{ $subsections kill-process } ;

ARTICLE: "io.launcher.launch" "Launching processes"
"Launching processes:"
{ $subsections
    run-process
    run-processes
    try-process
    run-detached
}
"Waiting for detached processes:"
{ $subsections
    wait-for-process
}
"Redirecting standard input and output to a pipe:"
{ $subsections
    <process-reader>
    <process-writer>
    <process-stream>
}
"Combinators built on top of the above:"
{ $subsections
    with-process-reader
    with-process-writer
    with-process-stream
} ;

ARTICLE: "io.launcher.examples" "Launcher examples"
"Starting a command and waiting for it to finish:"
{ $code
    "\"ls /etc\" run-process wait-for-process"
}
"Starting a program in the background:"
{ $code
    "{ \"emacs\" \"foo.txt\" } run-detached"
}
"Running a command, throwing an exception if it exits unsuccessfully:"
{ $code
    "\"make clean all\" try-process"
}
"Running a command, throwing an exception if it exits unsuccessfully or if it takes too long to run:"
{ $code
    "<process>"
    "    \"make test\" >>command"
    "    5 minutes >>timeout"
    "try-process"
}
"Running a command, throwing an exception if it exits unsuccessfully, and redirecting output and error messages to a log file:"
{ $code
    "<process>"
    "    \"make clean all\" >>command"
    "    \"log.txt\" >>stdout"
    "    +stdout+ >>stderr"
    "try-process"
}
"Running a command, appending error messages to a log file, and reading the output for further processing:"
{ $code
    "\"log.txt\" ascii <file-appender> ["
    "    <process>"
    "        swap >>stderr"
    "        \"report\" >>command"
    "    ascii <process-reader> stream-lines sort reverse [ print ] each"
    "] with-disposal"
} ;

ARTICLE: "io.launcher" "Operating system processes"
"The " { $vocab-link "io.launcher" } " vocabulary implements cross-platform process launching."
{ $subsections
    "io.launcher.examples"
    "io.launcher.descriptors"
    "io.launcher.launch"
}
"Advanced topics:"
{ $subsections
    "io.launcher.lifecycle"
    "io.launcher.command"
    "io.launcher.detached"
    "io.launcher.hidden"
    "io.launcher.environment"
    "io.launcher.redirection"
    "io.launcher.priority"
    "io.launcher.group"
    "io.launcher.timeouts"
} ;

ABOUT: "io.launcher"
