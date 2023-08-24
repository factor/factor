! Copyright (C) 2022 Zoltán Kéri.
! See https://factorcode.org/license.txt for BSD license.
USING: hashcash.private help.markup help.syntax kernel math
random.passwords strings ;
IN: hashcash

ARTICLE: "hashcash" "Hashcash"
"Hashcash is an anti-spam / denial of service counter-measure tool."
$nl
"A hashcash stamp constitutes a proof-of-work which takes a parameterizable amount of work to compute for the sender. The recipient (and indeed anyone as it is publicly auditable) can verify received hashcash stamps efficiently."
$nl
"E-mail senders attach hashcash stamps with the " { $snippet X-Hashcash } " header. Vendors and authors of anti-spam tools are encouraged to exempt e-mail sent with hashcash from their blacklists and content-based filtering rules."
$nl
"This library provides basic utilities for hashcash creation and validation."
$nl
{ $subheading "Creating stamps" }
{ $subsections
  mint
  mint*
}
{ $subheading "Validation" }
{ $subsections
  valid-stamp?
  valid-date?
}
{ $subheading "Hashcash tuple and constructor" }
{ $subsections
  hashcash
  <hashcash>
  expiry-days
}
{ $subheading "Private utilities" }
{ $subsections
  on-or-before-today?
  now-gmt-yymmdd
  yymmdd-gmt-diff
  yymmdd-gmt>timestamp
  timestamp>yymmdd
  lastn-digits
}
{ $see-also ascii-password }
{ $heading "Further readings" }
{ $url "https://en.wikipedia.org/wiki/Hashcash" } $nl
{ $url "https://www.hashcash.org/" } $nl
{ $url "https://www.hashcash.org/papers/hashcash.pdf" } $nl
{ $url "https://dbpedia.org/page/Hashcash" } $nl
{ $url "https://nakamoto.com/hashcash/" } ;

HELP: mint
{ $values { "resource" string } { "stamp" "generated stamp" } }
{ $description "This word generates a valid stamp with default parameters and the specified resource." }
{ $examples
  { $subheading "Generate a valid stamp" }
  "The value " { $snippet "foo@bar.com" } " represents the resource string. "
  "The generated stamp is pushed on the data stack." }
{ $unchecked-example
  "USING: hashcash ;"
  "\"foo@bar.com\" mint"
  "\n--- Data stack:\n1:20:220401:foo@bar.com::^Xt'xHT;:1eab9d"
}
"Generated stamp tabulated for better readability:"
{ $slots
  { { $slot "version" } { $snippet "1" } }
  { { $slot "bits" } { $snippet "20" } }
  { { $slot "date" } { $snippet "220401" } }
  { { $slot "resource" } { $snippet "foo@bar.com" } }
  { { $slot "salt" } { $snippet "^Xt'xHT;:1eab9d" } }
}
{ $notes "Examples of common resource strings:"
  { $list
    { "IP address" }
    { "E-mail address" }
  }
} ;

HELP: mint*
{ $values { "tuple" "a tuple" } { "stamp" "generated stamp" } }
{ $description "As " { $snippet "mint" } " but it takes a hashcash tuple as a parameter." } ;

HELP: hashcash
{ $class-description "A hashcash object. A hashcash have the following slots:"
  { $slots
    { { $slot "version" } "The version number. Only version 1 is supported." }
    { { $slot "bits" } "The claimed bit value." }
    { { $slot "date" } { "The date on which a stamp was minted. Expiry time is 28 days by default. See " { $link valid-stamp? } " for more." } }
    { { $slot "resource" } "The resource string for which a stamp is minted." }
    { { $slot "ext" } "Extensions that a specialized application may want. Ignored in version 1 (?)." }
    { { $slot "salt" } { "A random salt generated with " { $link ascii-password } "." } }
    { { $slot "suffix" } "The computed suffix. This is supposed to be manipulated by the library." }
  }
} ;

HELP: <hashcash>
{ $values { "tuple" object } }
{ $description "It fills a hashcash tuple with the default values: " { $snippet 1 } " as hashcash version, " { $snippet 20 } " as bits, " { $snippet "today's date" } " as date, and a " { $snippet "8-character long random string" } " as salt." } ;

HELP: valid-stamp?
{ $values { "stamp" string } { "?" boolean } }
{ $description "Verify the stamp's validity. Only supports hashcash version 1. Expiry time / validity period is 28 days by default as it is the recommended value."
  $nl
  "The decision about how long the stamp should be considered valid is up to the verifier. If it is too short, then it is possible for some applications that the stamp will expire before arriving at the recipient (e.g. with e-mail). The suggested value of 28 days should be safe for normal e-mail delivery delays. The choice is a trade-off between database size and risk of expiry prior to arrival, and depends on the application."
  $nl
  "Different stamps in the same database can have different validity periods, so for example stamps for different resources with different validity periods can be stored in the same database, or the recipient may change the validity period for future stamps without affecting the validity of old stamps." }
$nl
{ "You can obtain the current value by executing the following line of code: " }
{ $code "expiry-days get" }
{ "You can modify the expiry time by modifying the value of the symbol " { $snippet "expiry-days" } "." }
{ $code "32 expiry-days set" }
{ "This changes the expiry period to 32 days." }
{ $examples
  { $example
    "USING: hashcash ;"
    "\"foo@bar.com\" mint valid-stamp?"
    "\n--- Data stack:\nt"
  }
} ;
