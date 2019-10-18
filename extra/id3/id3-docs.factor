! Coyright (C) 2007 Adam Wendt
! See http://factorcode.org/license.txt for BSD license.
USING: id3 help.syntax help.markup ;

ARTICLE: "id3-tags" "ID3 Tags"
"The " { $vocab-link "id3" } " vocabulary is used to read ID3 tags from MP3 audio streams."
{ $subsection id3v2 }
{ $subsection read-tag }
{ $subsection id3v2? }
{ $subsection read-id3v2 } ;

ABOUT: "id3-tags"

HELP: id3v2
{ $values { "filename" "a pathname string" } { "tag/f" "a tag or f" } }
{ $description "Outputs a " { $link tag } " or " { $link f } " if file does not start with an ID3 tag." } ;

HELP: read-tag
{ $values { "stream" "a stream" } { "tag/f" "a tag or f" } }
{ $description "Outputs a " { $link tag } " or " { $link f } " if stream does not start with an ID3 tag." } ;

HELP: id3v2?
{ $values { "?" "a boolean" } }
{ $description "Tests if the current input stream begins with an ID3 tag." } ;

HELP: read-id3v2
{ $values { "tag/f" "a tag or f" } }
{ $description "Outputs a " { $link tag } " or " { $link f } " if the current input stream does not start with an ID3 tag." } ;
