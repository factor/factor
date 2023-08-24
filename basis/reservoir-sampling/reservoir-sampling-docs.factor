! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math multiline vectors ;
IN: reservoir-sampling

HELP: <reservoir-sampler>
{ $values k: integer sampler: object }
{ $description Creates an object that will hold k samples from everything it sees with equal probability. To show a reservoir-sampler an object, call \ reservoir-sample . } ;

HELP: reservoir-sample
{ $values obj: object sampler: object }
{ $description Feeds a sample to a \ reservoir-sampler which will maintain a vector of samples with equal probability. This word is especially useful when you do not know how many objects will appear but wish to sample them with equal probability, such as in a stream with unknown length. }
{ $unchecked-example
    [=[ 
        USING: prettyprint io strings math reservoir-sampling
        kernel accessors io.streams.string ;
        
        "Nothing will fundamentally change." [
            10 <reservoir-sampler>
            [ [ read1 dup ] swap '[ dup 1string . _ reservoir-sample ] while ] keep nip sampled>> >string .
        ] with-string-reader
        ""
    ]=]
} ;

HELP: reservoir-sample-iteration
{ $values iteration: integer k: integer obj: object sampled: vector sampled': vector }
{ $description Sample with equal probabilty without using a \ reservoir-sampler object. } ;

HELP: reservoir-sampler
{ $class-description The class of a reservoir sampler object. Create one with \ <reservoir-sampler> . } ;

ARTICLE: "reservoir-sampling" "Reservoir Sampling"
The { $vocab-link "reservoir-sampling" } vocabulary is a way to take k samples with equal probability from all the objects shown to the sampler. This means that you do not have to know how many objects the sampler will eventually see, and that the probability will still be equivalent.

Create a sampler:
{ $subsections
    <reservoir-sampler>
}

Show it samples:
{ $subsections
    reservoir-sample
}

Reservoir sampling without an object: 
{ $subsections
    reservoir-sample-iteration
} ;

ABOUT: "reservoir-sampling"
