! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: audio.engine destructors help.markup help.syntax
io.files kernel math strings ;
IN: audio.vorbis

HELP: <vorbis-stream>
{ $values
    { "stream" "a binary input stream" } { "buffer-size" integer }
    { "vorbis-stream" vorbis-stream }
}
{ $description "Constructs " { $link vorbis-stream } " over the contents of " { $snippet "stream" } ". When used as an audio generator, the Vorbis stream will supply data to the audio engine in " { $snippet "buffer-size" } " byte blocks. If the Vorbis stream is created successfully, it will take ownership of " { $snippet "stream" } ", disposing it when " { $link dispose } " is called on the " { $snippet "vorbis-stream" } "." } ;

HELP: no-vorbis-in-ogg
{ $description { $link <vorbis-stream> } " throws this error when the Ogg stream it reads contains no Vorbis channel." } ;

HELP: ogg-error
{ $values
    { "code" integer }
}
{ $description { $link <vorbis-stream> } " throws this error when the Ogg library raises an error while trying to parse the stream." } ;

HELP: read-vorbis-stream
{ $values
    { "filename" string } { "buffer-size" integer }
    { "vorbis-stream" vorbis-stream }
}
{ $description "Opens a binary " { $link <file-reader> } " for the file named " { $snippet "filename" } ", and construct a " { $link vorbis-stream } " over the file contents using " { $link <vorbis-stream> } "." } ;

{ read-vorbis-stream <vorbis-stream> } related-words

HELP: vorbis-error
{ $values
    { "code" integer }
}
{ $description { $link <vorbis-stream> } " throws this error when the Vorbis library raises an error while trying to parse the stream." } ;

HELP: vorbis-stream
{ $class-description "Objects of this class maintain the stream and decoder state for the Ogg Vorbis decoder. " { $snippet "vorbis-stream" } " implements the " { $link "audio.engine-generators" } ", so it can be used as the generator for a " { $link streaming-audio-clip } ". Use " { $link <vorbis-stream> } " or " { $link read-vorbis-stream } " to construct a Vorbis stream." } ;

ARTICLE: "audio.vorbis" "Ogg Vorbis audio streaming"
"The " { $vocab-link "audio.vorbis" } " vocabulary provides Ogg Vorbis decoding and streaming for " { $vocab-link "audio.engine" } "."
{ $subsections
    vorbis-stream
    read-vorbis-stream
    <vorbis-stream>
} ;

ABOUT: "audio.vorbis"
