USING: help.markup help.syntax ;
IN: io.encodings

ARTICLE: "encodings" "I/O encodings"
"Many streams deal with bytes, rather than Unicode code points, at some level. The translation between these two things is specified by an encoding. To abstract this away from the programmer, Factor provides a system where these streams are associated with an encoding which is always used when the stream is read from or written to. For most purposes, an encoding descriptor consisting of a symbol is all that is needed when initializing a stream."
"To make an encoded stream directly (something which is normally handled by the appropriate stream constructor), use the following words:"
{ $subsection <encoder> }
{ $subsection <decoder> }
{ $subsection <encoder-duplex> }
"To encode or decode a string, use"
{ $subsection encode-string }
! { $subsection decode-string }
;
