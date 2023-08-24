! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien byte-arrays help.markup help.syntax math memory ;
IN: audio

HELP: <audio>
{ $values
    { "channels" integer } { "sample-bits" integer } { "sample-rate" integer } { "size" integer } { "data" c-ptr }
    { "audio" integer }
}
{ $description "Constructs an " { $link audio } " object with the given parameters." } ;

HELP: audio
{ $class-description "Objects of this class contain uncompressed PCM audio data. The " { $snippet "data" } " slot contains an " { $link alien } " pointer or " { $link byte-array } " with the binary PCM data, and the " { $link size } " slot indicates the length in bytes of the data. The " { $snippet "channels" } ", " { $snippet "sample-bits" } " and " { $snippet "sample-rate" } " slots indicate the number of channels (1 for mono, 2 for stereo), bits per sample, and sample rate of the data." } ;

HELP: format-unsupported-by-openal
{ $values
    { "audio" audio }
}
{ $description "Errors of this class are thrown when " { $link openal-format } " is called on an " { $link audio } " object for which there is no OpenAL-supported format." } ;

HELP: openal-format
{ $values
    { "audio" audio }
    { "format" "an ALenum value" }
}
{ $description "Returns the OpenAL format value that corresponds to the format of the " { $snippet "audio" } " object. If the object's format doesn't match an OpenAL-supported format, a " { $link format-unsupported-by-openal } " error is thrown." } ;

ARTICLE: "audio" "Audio framework"
"The " { $vocab-link "audio" } " vocabulary and its child vocabularies provide a framework for reading audio data from disk and playing back audio using prerendered, streaming, or generated audio sources. By itself, the " { $snippet "audio" } " vocabulary provides a container class for prerendered PCM audio data:"
{ $subsections
    audio
    <audio>
    openal-format
}
"The following child vocabularies provide additional audio features:"
{ $list
{ { $vocab-link "audio.engine" } " provides a high-level OpenAL-based engine for playing audio clips." }
{ { $vocab-link "audio.loader" } " reads PCM data from files on disk into " { $link audio } " objects. " { $vocab-link "audio.wav" } " and " { $vocab-link "audio.aiff" } " support specific audio file formats." }
{ { $vocab-link "audio.vorbis" } " implements an " { $snippet "audio.engine" } " compatible generator object for decoding Ogg Vorbis audio data from a stream." }
} ;

ABOUT: "audio"
