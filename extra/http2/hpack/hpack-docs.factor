! Copyright (C) 2021 David Mindlin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax sequences strings ;
IN: http2.hpack

HELP: hpack-context
{ $class-description "Stores the context for a hpack decoder or encoder. This is primarily the current state of the dynamic table." } ;

HELP: hpack-decode
{ $values
    { "decode-context" hpack-context } { "block" byte-array }
    { "updated-context" hpack-context } { "decoded" sequence }
}
{ $description "Decodes the given byte array (or byte vector) in the given hpack context. Outputs the updated context, and the decoded header block as a sequence of pairs." } ;

HELP: hpack-decode-error
{ $values
    { "error-msg" string }
}
{ $description "Throws a " { $link hpack-decode-error } " error." }
{ $error-description "Thrown for any of the possible errors specified in RFC7541 for decoding hpack encoded byte strings." } ;

HELP: hpack-encode
{ $values
    { "encode-context" hpack-context } { "headers" sequence }
    { "updated-context" hpack-context } { "block" byte-array }
}
{ $description "Encodes the sequence of headers using the given context. Outputs the updated context and the encoded header block, as a byte array." } ;

ARTICLE: "http2.hpack" "HTTP/2 HPACK"
{ $vocab-link "http2.hpack" }
;

{ hpack-encode hpack-decode } related-words

ABOUT: "http2.hpack"
