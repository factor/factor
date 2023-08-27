! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: audio help.markup help.syntax kernel quotations strings ;
IN: audio.loader

HELP: read-audio
{ $values
    { "path" "a pathname string" }
    { "audio" audio }
}
{ $description "Reads the audio data from the file on disk named " { $snippet "path" } ", saving the data in an " { $link audio } " object. If the file's extension is not recognized, an " { $link unknown-audio-extension } " error is thrown." } ;

HELP: register-audio-extension
{ $values
    { "extension" string } { "quot" quotation }
}
{ $description "Registers a quotation for " { $link read-audio } " to use when reading audio files with filenames ending in " { $snippet ".extension" } ". The quotation should have the effect " { $snippet "( path -- audio )" } ", where " { $snippet "path" } " is the file's pathname and " { $snippet "audio" } " is the resulting " { $link audio } " object." } ;

HELP: unknown-audio-extension
{ $values
    { "extension" string }
}
{ $description "Errors of this class are thrown by " { $link read-audio } " when it cannot recognize the extension of the file it is given to open." } ;

ARTICLE: "audio.loader" "Audio file loader"
"The " { $vocab-link "audio.loader" } " vocabulary provides words for reading uncompressed PCM data from files on disk."
{ $subsections
    read-audio
}
"Other vocabularies can extend " { $link read-audio } " by adding support for other audio file formats."
{ $subsections
    register-audio-extension
    unknown-audio-extension
}
"By default, " { $snippet "audio.loader" } " supports WAV (with the file extension " { $snippet ".wav" } ") and AIFF (with extension " { $snippet ".aif" } " or " { $snippet ".aiff" } ")." ;

ABOUT: "audio.loader"
