USING: help.markup help.syntax kernel math ;
IN: hashcash

ARTICLE: "hashcash" "Hashcash"
"Hashcash is a denial-of-service counter measure tool."
$nl
"A hashcash stamp constitutes a proof-of-work which takes a parameterizable amount of work to compute for the sender. The recipient can verify received hashcash stamps efficiently."
$nl
"More info on hashcash:"
$nl
{ $url "http://www.hashcash.org/" } $nl
{ $url "http://en.wikipedia.org/wiki/Hashcash" } $nl
{ $url "http://www.ibm.com/developerworks/linux/library/l-hashcash.html?ca=dgr-lnxw01HashCash" } $nl
"This library provide basic utilities for hashcash creation and validation."
$nl
"Creating stamps:"
{ $subsection mint }
{ $subsection mint* }
"Validation:"
{ $subsection check-stamp }
"Hashcash tuple and constructor:"
{ $subsection hashcash }
{ $subsection <hashcash> }
"Utilities:"
{ $subsection salt } ;

{ mint mint* <hashcash> check-stamp salt } related-words

HELP: mint
{ $values { "resource" "a string" } { "stamp" "generated stamp" } }
{ $description "This word generate a valid stamp with default parameters and the specified resource." } ;

HELP: mint*
{ $values { "tuple" "a tuple" } { "stamp" "generated stamp" } }
{ $description "As " { $snippet "mint" } " but it takes an hashcash tuple as a parameter." } ;

HELP: check-stamp
{ $values { "stamp" "a string" } { "?" boolean } }
{ $description "Check for stamp's validity. Only supports hashcash version 1." } ;

HELP: salt
{ $values { "length" integer } { "salted" "a string" } }
{ $description "It generates a random string of " { $snippet "length" } " characters." } ;

HELP: <hashcash>
{ $values { "tuple" object } }
{ $description "It fill an hashcash tuple with the default values: 1 as hashcash version, 20 as bits, today's date as date and a random 8 character long salt" } ;

HELP: hashcash
{ $class-description "An hashcash object. An hashcash have the following slots:"
    { $table
        { { $slot "version" } "The version number. Only version 1 is supported." }
        { { $slot "bits" } "The claimed bit value." }
        { { $slot "date" } "The date a stamp was minted." }
        { { $slot "resource" } "The resource for which a stamp is minted." }
        { { $slot "ext" } "Extensions that a specialized application may want." }
        { { $slot "salt" } "A random salt." }
        { { $slot "suffix" } "The computed suffix. This is supposed to be manipulated by the library." }
    }
} ;
