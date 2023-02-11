! Copyright (C) 2022 Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types help.markup help.syntax kernel system ;
IN: unix.scheduler

ARTICLE: "unix.scheduler" "Unix Process Scheduling"
"The " { $vocab-link "unix.scheduler" } "vocabulary provides an interface to the POSIX process scheduler. " { $link macosx } " does not implement POSIX Process Scheduling, but does have other similar low-level APIs exposed by this vocabulary."
$nl "Cross platform constants:"
{ $subsections MOST_IDLE_SCHED_POLICY }
"Utility words:"
{ $subsections policy-priority-range priority-allowed? } ;

ABOUT: "unix.scheduler"

HELP: MOST_IDLE_SCHED_POLICY
{ $description
    "The scheduling policy value which is, or is most like, the " { $snippet "SCHED_IDLE" } " policy on Linux. The value of this word is platform specific, and differs between " { $link linux } ", " { $link macosx } " and " { $link freebsd } "." }
    $nl
    { $snippet "sched(7)" } " describes " { $snippet "SCHED_IDLE" } " to be " { $emphasis "intended for running jobs at extremely low priority (lower even than a +19 nice value with the SCHED_OTHER or SCHED_BATCH policies)."
} ;

HELP: policy-priority-range
{ $values { "policy" int } { "high" int } { "low" int } }
{ $description
    "Find the upper and lower bound on scheduler priority value, for a given scheduler policy. Each available scheduler policy ("
    { $snippet "SCHED_OTHER" } ", " { $snippet "SCHED_FIFO" } ", etc) may have its own range of allowable priorities."
}
{ $examples
    { $unchecked-example
        "USING: formatting unix.scheduler ;"
        "SCHED_OTHER policy-priority-range \"High: %d Low: %d\\n\" printf"
        "High: 0 Low: 0"
    }
    { $unchecked-example
        "USING: formatting unix.scheduler ;"
        "SCHED_FIFO policy-priority-range \"High: %d Low: %d\\n\" printf"
        "High: 99 Low: 1"
    }
} ;

HELP: priority-allowed?
{ $values { "policy" int } { "?" boolean } }
{ $description
    { $link t } " if the input scheduling policy can be used with a non-zero static priority, " { $link POSTPONE: f } " otherwise. This word allows a platform's real-time policies to be distinguished from normal scheduling policies."
    $nl
    "Depending on platform, normal scheduling policies (such as " { $snippet "SCHED_OTHER" } ", " { $snippet "SCHED_BATCH" } ", and " { $snippet "SCHED_IDLE" }
    ") must be used with a static scheduling priority of " { $snippet "0" } ". Similarly, the real-time policies must be used with a non-zero priority, within the"
    " range found by " { $link policy-priority-range } "."
}
{ $examples
    { $unchecked-example
        "USE: unix.scheduler"
        "SCHED_OTHER priority-allowed? ."
        "f"
    }
    { $unchecked-example
        "USE: unix.scheduler"
        "SCHED_FIFO priority-allowed? ."
        "t"
    }
} ;
