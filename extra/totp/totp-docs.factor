! Copyright (C) 2018, 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar checksums checksums.sha help.markup
help.syntax kernel math strings ;
IN: totp

ABOUT: "totp"

ARTICLE: "totp" "Time-Based One-Time Passwords"
"The " { $vocab-link "totp" } " vocab implements time-based one-time password generation as described in RFC 6238 (" { $url "https://tools.ietf.org/html/rfc6238" } ")."
$nl
"The idea is that a client is able to prove its identity to a server by submitting a password that is only valid for a short period of time. The password needs to be sent via a secure channel inside that time period, and client and server must have a shared secret established in advance. The TOTP protocol uses the number of whole 30-second intervals passed in Unix time as a counter value, which it authenticates with an HMAC and converts into a string of " { $link digits } ". Client and server must use the same secret key, the same hash for the HMAC, the same time reference point (not necessarily Unix time) and the same time interval length for the counter. The string of digits used as the password should be long enough to balance convenience and brute-force attack resistance. For 30-second intervals 6 or more digits are typically used."
$nl
"Both client and server are able to generate exactly the same digits from the shared secret using their current time as the counter. Server can be programmed to accept values from the adjacent time slots, so that time drift and network delays are compensated for, though that somewhat weakens the system."
$nl
"Simple high-level interface:"
{ $subsections totp-hash totp-digits totp }
"Customizable implementation:"
{ $subsections timestamp>count* totp* digits }
;

HELP: totp-hash
{ $var-description "A cryptographically secure " { $link checksum } " to be used by " { $link totp } " for the HMAC. See " { $url "https://en.wikipedia.org/wiki/HMAC" } " for more information."
$nl
"Default value is " { $link sha1 } ", same as used by Google Authenticator." } ;

HELP: totp-digits
{ $var-description "The number of digits returned by " { $link totp } "."
$nl
"Default value is 6." } ;

HELP: totp
{ $values
    { "key" object }
    { "string" string }
}
{ $description "Generate a one-time password for the " { $snippet "key" } " based on the current system time. If " { $snippet "key" } " is a " { $link string } ", it is expected to contain the key data in Base 32 encoding, otherwise it should be a " { $link byte-array } ". The " { $snippet "string" } " length is " { $link totp-digits } ", and the hash used for HMAC is " { $link totp-hash } "." } ;

{ totp totp* } related-words

HELP: timestamp>count
{ $values
    { "timestamp" timestamp }
    { "count" byte-array }
}
{ $description "Return the number of 30-second intervals between the Unix time and the " { $snippet "timestamp" } " as an 8-byte " { $link byte-array } "." } ;

HELP: timestamp>count*
{ $values
    { "timestamp" timestamp } { "secs/count" number }
    { "count" byte-array }
}
{ $description "Return the number of " { $snippet "secs/count" } "-second intervals between the Unix time and the " { $snippet "timestamp" } " as an 8-byte " { $link byte-array } "." } ;

{ timestamp>count timestamp>count* } related-words

HELP: totp*
{ $values
    { "count" "a number of time intervals elapsed since a fixed time point" }
    { "key" "a secret key shared between the client and the server" }
    { "hash" checksum }
    { "n" fixnum }
}
{ $description "This is a fully customizable version of " { $link totp } ". To convert a " { $link timestamp } " into the " { $snippet "count" } " value, use " { $link timestamp>count } ". " { $snippet "n" } " is a positive 31-bit integer. To convert the returned value into a string of a predetermined length, use " { $link digits } "." } ;

HELP: digits
{ $values
    { "n" number } { "digits" number }
    { "string" string }
}
{ $description "Convert integer " { $snippet "n" } " into a decimal string of length " { $snippet "digits" } ", padding with zeroes on the left if necessary. If the string representation of " { $snippet "n" } " is longer than " { $snippet "digits" } ", return the rightmost part of the requested length." } ;
