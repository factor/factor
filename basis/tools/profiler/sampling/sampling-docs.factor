! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays calendar help.markup help.syntax math quotations threads
tools.profiler.sampling tools.profiler.sampling.private ;
IN: tools.profiler.sampling

{ cross-section flat top-down top-down-max-depth profile profile. } related-words
{ cross-section* flat* top-down* top-down-max-depth* most-recent-profile-data } related-words

{ total-sample-count gc-sample-count jit-sample-count foreign-sample-count foreign-thread-sample-count sample-thread sample-callstack } related-words

{ total-time gc-time foreign-time foreign-thread-time } related-words

HELP: cross-section
{ $values
    { "depth" integer }
    { "tree" "a profile report" }
}
{ $description "Generates a cross-section profile at " { $snippet "depth" } " from the results of the most recent " { $link profile } ". Each sample's time will be charged to the function " { $snippet "depth" } " levels deep in the callstack, or to the deepest function in the callstack if the callstack at the time of the sample is fewer than " { $snippet "depth" } " levels deep. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: cross-section*
{ $values
    { "depth" integer } { "profile-data" "raw profile data" }
    { "tree" "a profile report" }
}
{ $description "Generates a cross-section profile at " { $snippet "depth" } " from the profile results in " { $snippet "profile-data" } ". Each sample's time will be charged to the function " { $snippet "depth" } " levels deep in the callstack, or to the deepest function in the callstack if the callstack at the time of the sample is fewer than " { $snippet "depth" } " levels deep. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: flat
{ $values
        { "flat" "a profile report" }
}
{ $description "Generates a flat profile from the results of the most recent " { $link profile } ". Each sample's time will be charged to every function in the callstack at the time of the sample. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: flat*
{ $values
    { "profile-data" "raw profile data" }
    { "flat" "a profile report" }
}
{ $description "Generates a flat profile from the profile results in " { $snippet "profile-data" } ". Each sample's time will be charged to every function in the callstack at the time of the sample. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: foreign-sample-count
{ $values
    { "sample" "a raw profile sample" }
    { "count" integer }
}
{ $description "Returns the number of sample intervals spent in non-Factor code (such as the Factor VM, or FFI calls) during " { $snippet "sample" } "." } ;

HELP: foreign-thread-sample-count
{ $values
    { "sample" "a raw profile sample" }
    { "count" integer }
}
{ $description "Returns the number of sample intervals spent executing non-Factor threads within the Factor process during " { $snippet "sample" } "." } ;

HELP: foreign-thread-time
{ $values
        { "n" duration }
}
{ $description "Returns the total time spent executing non-Factor threads within the Factor process during the last " { $link profile } "." } ;

HELP: foreign-thread-time*
{ $values
    { "profile-data" "raw profile data" }
    { "n" duration }
}
{ $description "Returns the total time spent executing non-Factor threads within the Factor process from the given " { $snippet "profile-data" } "." } ;

HELP: foreign-time
{ $values
        { "n" duration }
}
{ $description "Returns the total time spent in non-Factor code (such as the Factor VM, or FFI calls) during the last " { $link profile } "." } ;

HELP: foreign-time*
{ $values
    { "profile-data" "raw profile data" }
    { "n" duration }
}
{ $description "Returns the total time spent in non-Factor code (such as the Factor VM, or FFI calls) from the given " { $snippet "profile-data" } "." } ;

HELP: gc-sample-count
{ $values
    { "sample" "a raw profile sample" }
    { "count" integer }
}
{ $description "Returns the number of sample intervals spent in the garbage collector during " { $snippet "sample" } "." } ;

HELP: gc-time
{ $values
        { "n" duration }
}
{ $description "Returns the total time spent in the garbage collector during the last " { $link profile } "." } ;

HELP: gc-time*
{ $values
    { "profile-data" "raw profile data" }
    { "n" duration }
}
{ $description "Returns the total time spent in the garbage collector from the given " { $snippet "profile-data" } "." } ;

HELP: jit-sample-count
{ $values
    { "sample" "a raw profile sample" }
    { "count" integer }
}
{ $description "Returns the number of sample intervals spent in the non-optimizing compiler during " { $snippet "sample" } "." } ;

HELP: most-recent-profile-data
{ $values
        { "profile-data" "raw profile data" }
}
{ $description "Returns the raw profile data from the most recent " { $link profile } ". This data can be saved and used with the " { $snippet "*" } " variants of reporting words, such as " { $link top-down* } " and " { $link flat* } ", independent of later executions of the profiler.." } ;

HELP: profile
{ $values
    { "quot" quotation }
}
{ $description "Executes " { $snippet "quot" } " with the sampling profiler enabled. The results of the profile can subsequently be reported with words such as " { $link top-down } " and " { $link flat } ", or the raw data can be saved and inspected with " { $link most-recent-profile-data } "." } ;

HELP: profile-node
{ $class-description "Objects of this type are generated by profile reporting words such as " { $link top-down } ", " { $link top-down-max-depth } ", " { $link cross-section } ", and " { $link flat } "." } ;

HELP: profile.
{ $values
    { "tree" "a profile report" }
}
{ $description "Formats and prints a profile report generated by " { $link top-down } ", " { $link top-down-max-depth } ", " { $link cross-section } ", or " { $link flat } "." } ;

HELP: raw-profile-data
{ $var-description "Holds raw profiling data. Set by the " { $link profile } " word after the profiling run is over." } ;

HELP: sample-callstack
{ $values
    { "sample" "a raw profile sample" }
    { "array" array }
}
{ $description "Returns the callstack (the stack of functions currently executing) at the time of " { $snippet "sample" } "." } ;

HELP: sample-thread
{ $values
    { "sample" "a raw profile sample" }
    { "thread" thread }
}
{ $description "Returns the currently-executing Factor thread at the time of " { $snippet "sample" } "." } ;

HELP: samples-per-second
{ $var-description "This variable controls the rate at which the profiler takes samples during calls to " { $link profile } "." } ;

HELP: samples>time
{ $values
    { "samples" integer }
    { "seconds" integer }
}
{ $description "Converts a sample interval count to an integer based on the value of " { $link samples-per-second } "." } ;

HELP: top-down
{ $values
        { "tree" "a profile report" }
}
{ $description "Generates a top-down tree profile from the results of the most recent " { $link profile } ". The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: top-down*
{ $values
    { "profile-data" "raw profile data" }
    { "tree" "a profile report" }
}
{ $description "Generates a top-down tree profile from the profile results in " { $snippet "profile-data" } ". The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: top-down-max-depth
{ $values
    { "max-depth" integer }
    { "tree" "a profile report" }
}
{ $description "Generates a top-down tree profile from the results of the most recent " { $link profile } ". Functions at a callstack depth greater than " { $snippet "max-depth" } " will be filtered out. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: top-down-max-depth*
{ $values
    { "max-depth" integer } { "profile-data" "raw profile data" }
    { "tree" "a profile report" }
}
{ $description "Generates a top-down tree profile from the profile results in " { $snippet "profile-data" } ". Functions at a callstack depth greater than " { $snippet "max-depth" } " will be filtered out. The output " { $snippet "tree" } " can be printed with the " { $link profile. } " word." } ;

HELP: total-sample-count
{ $values
    { "sample" "a raw profile sample" }
    { "count" integer }
}
{ $description "Returns the total number of sample intervals spent during " { $snippet "sample" } "." } ;

HELP: total-time
{ $values
        { "n" duration }
}
{ $description "Returns the total time spent during the most recent " { $link profile } "." } ;

HELP: total-time*
{ $values
    { "profile-data" "raw profile data" }
    { "n" duration }
}
{ $description "Returns the total time spent from the given " { $snippet "profile-data" } "." } ;

ARTICLE: "tools.profiler.sampling" "Sampling profiler"
"The " { $vocab-link "tools.profiler.sampling" } " vocabulary provides an interface to Factor's sampling profiler. It provides words for running the profiler:"
{ $subsections profile }
"General statistics can then be collected:"
{ $subsections total-time gc-time foreign-time foreign-thread-time }
"More detailed by-function profile reports can be generated:"
{ $subsections top-down top-down-max-depth cross-section flat }
"The report data can then be printed:"
{ $subsections profile. }
"Profile data can be saved for future reporting:"
{ $subsections most-recent-profile-data top-down* top-down-max-depth* cross-section* flat* }
"For example, the following will profile a call to the foo word, and generate and display a top-down tree profile from the results:"
{ $code "[ foo ] profile
top-down profile." }
;

ABOUT: "tools.profiler.sampling"

! Implementation

! Inaccuracies
!   epilogue bias
!   sample count phase
!   not compensated for sample collection time
!   nearest-neighbor reporting
