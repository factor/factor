! Copyright (C) 2025 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax kernel sequences ;
IN: crypto.utils

ARTICLE: "crypto.utils" "Cryptographic utilities"
"This vocabulary provides common utility functions for cryptographic implementations."
$nl
"These utilities are designed to avoid side-channel vulnerabilities that can leak secret information through timing, cache behavior, or other observable effects."
$nl
{ $heading "Constant-time operations" }
{ $subsections
    constant-time=
    constant-time-zero?
    constant-time-select
}
{ $heading "Security notes" }
"Timing attacks exploit the fact that many operations take different amounts of time depending on the data being processed. For example, a naive byte-by-byte comparison returns early on the first mismatch, allowing an attacker to determine how many bytes of a secret value they have guessed correctly."
$nl
"The functions in this vocabulary are designed to take the same amount of time regardless of the input values, preventing such attacks." ;

HELP: constant-time=
{ $values
  { "a" sequence }
  { "b" sequence }
  { "?" "t if equal, f otherwise" }
}
{ $description "Compares two sequences for equality in constant time. Unlike " { $link = } " or " { $link sequence= } ", this function always examines all bytes of both sequences (when lengths match), preventing timing attacks that could reveal information about the contents." }
{ $notes "If the sequences have different lengths, returns " { $link f } " immediately. This length check is not constant-time, but sequence lengths are typically not secret in cryptographic protocols." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.utils ;"
    "B{ 1 2 3 4 } B{ 1 2 3 4 } constant-time="
    "! => t"
  }
} ;

HELP: constant-time-zero?
{ $values
  { "seq" sequence }
  { "?" "t if all zeros, f otherwise" }
}
{ $description "Checks if all bytes in a sequence are zero in constant time. Always examines all bytes regardless of where non-zero bytes occur." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.utils ;"
    "B{ 0 0 0 0 } constant-time-zero?"
    "! => t"
  }
  { $unchecked-example
    "USING: byte-arrays crypto.utils ;"
    "B{ 0 0 1 0 } constant-time-zero?"
    "! => f"
  }
} ;

HELP: constant-time-select
{ $values
  { "flag" "0 or 1" }
  { "a" "integer" }
  { "b" "integer" }
  { "a/b" "a if flag=1, b if flag=0" }
}
{ $description "Selects between two integers in constant time without branching. If flag is 1, returns a. If flag is 0, returns b. Uses arithmetic masking to avoid conditional branches." }
{ $warning "Flag MUST be exactly 0 or 1. Other values produce undefined results." }
{ $examples
  { $unchecked-example
    "USING: crypto.utils ;"
    "1 42 99 constant-time-select"
    "! => 42"
  }
  { $unchecked-example
    "USING: crypto.utils ;"
    "0 42 99 constant-time-select"
    "! => 99"
  }
} ;

ABOUT: "crypto.utils"
