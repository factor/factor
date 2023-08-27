! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: checksums checksums.common checksums.md5 checksums.sha
destructors help.markup help.syntax sequences ;
IN: checksums.multi

ABOUT: "checksums.multi"

ARTICLE: "checksums.multi" "Checksumming with Multiple Algorithms"
"The " { $vocab-link "checksums.multi" } " vocabulary makes it possible to calculate multiple checksums with just one pass over a data stream."
$nl
"The " { $link multi-checksum } " tuple holds a sequence of " { $link block-checksum } " instances, such as " { $link md5 } " or " { $link sha1 } ". When the " { $link initialize-checksum-state } " method is called on it, a new instance of " { $link block-checksum-state } " is created for all the " { $slot "checksums" } ", and returned as a new " { $link multi-state } " instance. You can then use " { $link add-checksum-bytes } " to stream data to it. When done, call " { $link get-checksum } " to finalize the process, read the resulting checksums and dispose of the tuple in one step. If you want to cancel the work without calling " { $link get-checksum } ", you must " { $link dispose } " of the tuple so that all implementation-specific resources are released."
$nl
"The " { $link checksum-bytes } " and the " { $link checksum-stream } " methods encapsulate the above protocol, including instantiation and disposal of the " { $link multi-state } " tuple."
{ $examples
    { $example "USING: byte-arrays checksums checksums.md5 "
    " checksums.multi checksums.sha ;"
    "\"test\" >byte-array { md5 sha1 } <multi-checksum> checksum-bytes ."
"{
    B{
        9 143 107 205 70 33 211 115 202 222 78 131 38 39 180 246
    }
    B{
        169 74 143 229 204 177 155 166 28 76 8 115 211 145 233
        135 152 47 187 211
    }
}"
    }
} ;

HELP: <multi-checksum>
{ $values
    { "checksums" sequence }
    { "multi-checksum" multi-checksum }
}
{ $description "This is a simple constructor for the " { $link multi-checksum } " tuple. The " { $snippet "checksums" } " must be a sequence of " { $link block-checksum } " instances." } ;

HELP: multi-checksum
{ $class-description "This is an instance of the " { $link block-checksum } " mixin. It calculates multiple checksums by sequentially passing the data it receives to all the checksums in its " { $slot "checksums" } " slot. This way, even though the individual checksums are not calculated in parallel, you still can have the performance benefits of only reading a disk file once, or not having to temporarily store the data streamed from a network." } ;

HELP: multi-state
{ $class-description "This class represents the current state of a " { $link multi-checksum } " checksum calculation. It has an array of associated checksum states until it is disposed. You may call " { $link add-checksum-bytes } " multiple times to pipe data to all the checksum states in the " { $slot "states" } " slot. When finished, call " { $link get-checksum } " to receive the results and release implementation-specific resources, or " { $link dispose } " to release the resources and discard the result. After the first " { $link get-checksum } " call the returned value is stored in the " { $slot "results" } " slot, and subsequent calls return the same value." }
{ $notes "It is not possible to add more data to the checksum after the first " { $link get-checksum } " call."
$nl
"Most code should use " { $link with-checksum-state } " to make sure the resources are properly disposed of. Higher level words like " { $link checksum-bytes } " and " { $link checksum-stream } " use it to perform the disposal." } ;

{ multi-checksum multi-state } related-words
