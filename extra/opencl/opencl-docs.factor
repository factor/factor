! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations strings opencl.private
math byte-arrays alien ;
IN: opencl

HELP: sampler>cl-addressing-mode
{ $values
    { "sampler" cl-sampler }
    { "addressing-mode" cl-addressing-mode }
}
{ $description "Returns the addressing mode of the given sampler." } ;

HELP: cl-barrier
{ $description "Insert a synchronization barrier into the current command queue." } ;

HELP: cl-barrier-events
{ $values
    { "event/events" "a single event or sequence of events" }
}
{ $description "Insert a synchronization barrier for the specified events into the current command queue." } ;

HELP: cl-buffer
{ $var-description "Tuple wrapper which will release the memory object handle when disposed." } ;

HELP: cl-buffer-ptr
{ $var-description "A buffer and offset pair for specifying a starting point for a copy." } ;

HELP: cl-buffer-range
{ $var-description "A buffer, offset and size triplet for specifying copy ranges." } ;

HELP: cl-context
{ $var-description "Tuple wrapper which will release the context handle when disposed." } ;

HELP: cl-current-context
{ $var-description "Symbol for the current cl-context tuple." } ;

HELP: cl-current-device
{ $var-description "Symbol for the current cl-device tuple." } ;

HELP: cl-current-queue
{ $var-description "Symbol for the current cl-queue tuple." } ;

HELP: cl-device
{ $var-description "Tuple wrapper which will release the device handle when disposed." } ;

HELP: cl-event
{ $var-description "Tuple wrapper which will release the event handle when disposed." } ;

HELP: cl-event-status
{ $values
    { "event" cl-event }
    { "execution-status" cl-execution-status }
}
{ $description "Returns the current execution status of the operation represented by the event." } ;

HELP: cl-event-type
{ $values
    { "event" cl-event }
    { "command-type" cl-execution-status }
}
{ $description "Returns the type of operation that created the event." } ;

HELP: sampler>cl-filter-mode
{ $values
    { "sampler" cl-sampler }
    { "filter-mode" cl-filter-mode }
}
{ $description "Returns the filter mode of the sampler object." } ;

HELP: cl-finish
{ $description "Flush the current command queue and wait till all operations are completed." } ;

HELP: cl-flush
{ $description "Flush the current command queue to kick off pending operations." } ;

HELP: cl-kernel
{ $var-description "Tuple wrapper which will release the kernel handle when disposed." } ;

HELP: cl-kernel-arity
{ $values
    { "kernel" cl-kernel }
    { "arity" integer }
}
{ $description "Returns the number of inputs that this kernel function accepts." } ;

HELP: cl-kernel-local-size
{ $values
    { "kernel" cl-kernel }
    { "size" integer }
}
{ $description "Returns the maximum size of a local work group for this kernel." } ;

HELP: cl-kernel-name
{ $values
    { "kernel" cl-kernel }
    { "string" string }
}
{ $description "Returns the name of the kernel function." } ;

HELP: cl-marker
{ $values

    { "event" cl-event }
}
{ $description "Inserts a marker into the current command queue." } ;

HELP: cl-normalized-coords?
{ $values
    { "sampler" cl-sampler }
    { "?" boolean }
}
{ $description "Returns whether the sampler uses normalized coords or not." } ;

HELP: cl-out-of-order-execution?
{ $values
    { "command-queue" cl-queue }
    { "?" boolean }
}
{ $description "Returns whether the given command queue allows out of order execution or not." } ;

HELP: cl-platform
{ $var-description "Tuple summarizing the capabilities and devices of an OpenCL platform." } ;

HELP: cl-platforms
{ $values

    { "platforms" "sequence of cl-platform" }
}
{ $description "Returns the platforms available for OpenCL computation on this hardware." } ;

HELP: cl-profile-counters
{ $values
    { "event" cl-event }
    { "queued" integer } { "submitted" integer } { "started" integer } { "finished" integer }
}
{ $description "Returns the profiling counters for the operation represented by event." } ;

HELP: cl-profiling?
{ $values
    { "command-queue" cl-queue }
    { "?" boolean }
}
{ $description "Returns true if the command queue allows profiling." } ;

HELP: cl-program
{ $var-description "Tuple wrapper which will release the program handle when disposed." } ;

HELP: cl-queue
{ $var-description "Tuple wrapper which will release the command queue handle when disposed." } ;

HELP: cl-read-buffer
{ $values
    { "buffer-range" cl-buffer-range }
    { "byte-array" byte-array }
}
{ $description "Synchronously read a byte-array from the specified buffer location." } ;

HELP: cl-sampler
{ $var-description "Tuple wrapper which will release the sampler handle when disposed." } ;

HELP: cl-queue-copy-buffer
{ $values
    { "src-buffer-ptr" cl-buffer-ptr } { "dst-buffer-ptr" cl-buffer-ptr } { "size" integer } { "dependent-events" "sequence of events" }
    { "event" cl-event }
}
{ $description "Queue a copy operation from " { $snippet "src-buffer-ptr" } " to " { $snippet "dst-buffer-ptr" } ". Dependent events can be passed to order the operation relative to other operations." } ;

HELP: cl-queue-kernel
{ $values
    { "kernel" cl-kernel } { "args" "sequence of cl-buffer or byte-array" } { "sizes" "sequence of integers" } { "dependent-events" "sequence of events" }
    { "event" cl-event }
}
{ $description "Queue a kernel for execution with the given arguments. The " { $snippet "sizes" } " argument specifies input array sizes for each dimension. Dependent events can be passed to order the operation relative to other operations." } ;

HELP: cl-queue-read-buffer
{ $values
    { "buffer-range" cl-buffer-range } { "alien" alien } { "dependent-events" "a sequence of events" }
    { "event" cl-event }
}
{ $description "Queue a read operation from " { $snippet "buffer-range" } " to " { $snippet "alien" } ". Dependent events can be passed to order the operation relative to other operations." } ;

HELP: cl-queue-write-buffer
{ $values
    { "buffer-range" cl-buffer-range } { "alien" alien } { "dependent-events" "a sequence of events" }
    { "event" cl-event }
}
{ $description "Queue a write operation from " { $snippet "alien" } " to " { $snippet "buffer-range" } ". Dependent events can be passed to order the operation relative to other operations." } ;

HELP: cl-wait
{ $values
    { "event/events" "a single event or sequence of events" }
}
{ $description "Synchronously wait for the events to complete." } ;

HELP: cl-write-buffer
{ $values
    { "buffer-range" cl-buffer-range } { "byte-array" byte-array }
}
{ $description "Synchronously write a byte-array to the specified buffer location." } ;

HELP: <cl-program>
{ $values
    { "options" string } { "strings" "sequence of source code strings" }
    { "program" "compiled cl-program" }
}
{ $description "Compile the given source code and return a program object. A " { $link cl-error } " is thrown in the event of a compile error." } ;

HELP: with-cl-state
{ $values
  { "context/f" { $maybe cl-context } } { "device/f" { $maybe cl-device } } { "queue/f" { $maybe cl-queue } } { "quot" quotation }
}
{ $description "Run the specified quotation with the given context, device and command queue. False arguments are not bound." } ;

ARTICLE: "opencl" "OpenCL"
"The " { $vocab-link "opencl" } " vocabulary provides high-level words for using OpenCL."
{ $subsections
  cl-platforms
  <cl-queue>
  with-cl-state
}
"Memory Objects:"
{ $subsections
  <cl-buffer>
  cl-queue-copy-buffer
  cl-read-buffer
  cl-queue-read-buffer
  cl-write-buffer
  cl-queue-write-buffer
}
"Programs and Kernels:"
{ $subsections
  <cl-program>
  <cl-kernel>
}

"Running and Waiting for Completion:"
{ $subsections
  cl-queue-kernel
  cl-wait
  cl-flush
  cl-finish
}
;

ABOUT: "opencl"
