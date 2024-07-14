USING: help.markup help.syntax continuations destructors io ;
IN: io.pipes

HELP: pipe
{ $class-description "A low-level pipe. Instances are created by calling " { $link (pipe) } " and closed by calling " { $link dispose } "." } ;

HELP: (pipe)
{ $values { "pipe" pipe } }
{ $description "Opens a new pipe. This is a low-level word; the " { $link <pipe> } " and " { $link run-pipeline } " words can be used in most cases instead." } ;

HELP: <pipe>
{ $values { "encoding" "an encoding specifier" } { "stream" "a bidirectional stream" } }
{ $description "Opens a new pipe and wraps it in a stream. Data written from the stream can be read back from the same stream instance." }
{ $notes "Pipe streams must be disposed by calling " { $link dispose } " or " { $link with-disposal } " to avoid resource leaks." } ;

HELP: <connected-pair>
{ $values { "encoding" "an encoding specifier" } { "stream" "a bidirectional stream" } }
{ $description "Opens two pipes wrapped into a stream. These are connected so that their " { $link input-stream } " redirects to the other pipe." } ;

HELP: run-pipeline
{ $values { "seq" "a sequence of pipeline components" } { "results" "a sequence of pipeline results" } }
{ $description
    "Creates a pipe between each pipeline component, with the output of each component becoming the input of the next."
    $nl
    "The first component reads input from " { $link input-stream } " and the last component writes output to " { $link output-stream } "."
    $nl
    "Each component runs in its own thread, and the word returns when all components finish executing. Each component outputs a result value."
    $nl
    "Pipeline components must be one of the following:"
    { $list
        { "A quotation. The quotation is called with both " { $link input-stream } " and " { $link output-stream } " rebound, except for the first and last pipeline components, and it must output a single value." }
        { "A process launch descriptor. See " { $link "io.launcher.descriptors" } "." }
    }
}
{ $examples
    "Print the lines of a log file which contain the string \"error\", sort them and filter out duplicates, using Unix shell commands only:"
    { $code "{ \"cat log.txt\" \"grep error\" \"sort\" \"uniq\" } run-pipeline" }
} ;

ARTICLE: "io.pipes" "Pipes"
"A " { $emphasis "pipe" } " is a unidirectional channel for transfer of bytes. Data written to one end of the pipe can be read from the other. Pipes can be used to pass data between processes; they can also be used within a single process to implement communication between coroutines."
$nl
"Low-level pipes:"
{ $subsections
    pipe
    (pipe)
}
"High-level pipe streams:"
{ $subsections <pipe> }
"Pipelines of coroutines and processes:"
{ $subsections run-pipeline } ;

ABOUT: "io.pipes"
