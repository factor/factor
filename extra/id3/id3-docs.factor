! Copyright (C) 2008 Tim Wawrzynczak
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax id3.private kernel sequences
strings ;
IN: id3

HELP: mp3>id3
{ $values
    { "path" "a path string" }
    { "id3/f" { $maybe "tuple storing ID3v2 metadata" } } }
    { $description "Return a tuple containing the ID3 information parsed out of the MP3 file, or " { $link f } " if no metadata is present. Words to access the ID3v1 information are here:"
        { $list
          { $link title }
          { $link artist }
          { $link album }
          { $link year }
          { $link genre }
          { $link comment }
        }
        "For other fields, use the " { $link find-id3-frame } " word."
    } ;

HELP: album
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the album, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: artist
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the artist, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: comment
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the comment, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: genre
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the genre, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: title
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the title, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: year
{ $values
    { "id3" id3 }
    { "string/f" { $maybe string } }
}
{ $description "Returns the year, or " { $link f } " if this field is missing, from a parsed id3 tag." } ;

HELP: find-id3-frame
{ $values
    { "id3" id3 } { "name" string }
    { "obj/f" { $maybe object } }
}
{ $description "Returns the " { $slot "data" } " slot of the ID3 frame with the given name, or " { $link f } "." } ;

HELP: mp3-paths>id3s
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "From a sequence of pathnames, parses each ID3 header and returns a sequence of key/value pairs of pathnames and ID3 objects." } ;

HELP: find-mp3s
{ $values
    { "path" "a pathname string" }
    { "seq" sequence }
}
{ $description "Returns a sequence of MP3 pathnames from a directory and all of its subdirectories." } ;

HELP: parse-mp3-directory
{ $values
    { "path" "a pathname string" }
    { "seq" sequence }
}
{ $description "Returns a sequence of key/value pairs where the key is the path of an MP3 and the value is the parsed ID3 header or " { $link f } " recursively for each MP3 file in the directory and all subdirectories." } ;

ARTICLE: "id3" "ID3 tags"
"The " { $vocab-link "id3" } " vocabulary contains words for parsing " { $emphasis "ID3" } " tags, which are textual fields storing an MP3's title, artist, and other metadata." $nl
"Parsing ID3 tags for a directory of MP3s, recursively:"
{ $subsections parse-mp3-directory }
"Finding MP3 files recursively:"
{ $subsections find-mp3s }
"Parsing a sequence of MP3 pathnames:"
{ $subsections mp3-paths>id3s }
"Parsing an MP3 file's ID3 tags:"
{ $subsections mp3>id3 }
"ID3v1 frame tag accessors:"
{ $subsections
    album
    artist
    comment
    genre
    title
    year
}
"Access any frame tag:"
{ $subsections find-id3-frame } ;

ABOUT: "id3"
