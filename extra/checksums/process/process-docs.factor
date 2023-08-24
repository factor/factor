! Copyright (C) 2016 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii checksums checksums.common destructors help.markup
help.syntax ;
IN: checksums.process

ABOUT: "checksums.process"

ARTICLE: "checksums.process" "Checksumming with External Utilities"
"With the " { $vocab-link "checksums.process" } " vocabulary any console utility can be used to checksum data, provided it supports a certain interface: it should accept input data on STDIN and output result to STDOUT. The output should consist of the hexadecimal checksum string, terminated with a " { $link blank? } " character. For instance, all the checksums from the GNU CoreUtils package support this mode of operation as the default."
$nl
"The " { $link checksum-process } " tuple holds a launch descriptor (see " { $link "io.launcher.descriptors" } ") of the utility, e.g. \"sha1sum\". When the " { $link initialize-checksum-state } " method is called on it, a new instance of the checksum utility is started in the background. In Factor it is represented by the " { $link process-state } " tuple. You can then use " { $link add-checksum-bytes } " to stream data to it. When done, call " { $link get-checksum } " to read the resulting checksum and dispose of the tuple in one step. If you want to cancel the work without calling " { $link get-checksum } ", you must " { $link dispose } " of the tuple so that the underlying process is terminated."
$nl
"The " { $link checksum-bytes } " and the " { $link checksum-stream } " methods encapsulate the above protocol, including instantiation and disposal of the " { $link process-state } " tuple."
{ $examples
    { $unchecked-example "USING: byte-arrays checksums checksums.process ;"
    "\"test\" >byte-array \"sha1sum\" <checksum-process> checksum-bytes ."
    "B{
    169 74 143 229 204 177 155 166 28 76 8 115 211 145 233 135
    152 47 187 211
}" }
    $nl
    { $unchecked-example "USING: checksums checksums.common checksums.process"
    "io io.encodings.binary namespaces ;"
    "\"LICENSE.txt\" binary ["
    "    input-stream get \"sha1sum\" <checksum-process> checksum-stream"
    "] with-file-reader ."
    "B{
    125 80 102 9 175 178 81 111 33 59 33 149 187 70 193 32 81
    188 89 156
}" }
} ;

HELP: <checksum-process>
{ $values
    { "launch-desc" "see " { $link "io.launcher.descriptors" } }
    { "checksum-process" "a new instance of " { $link checksum-process } }
}
{ $description "This is a simple constructor for the " { $link checksum-process } " tuple." } ;

HELP: checksum-process
{ $class-description "This is an instance of the " { $link block-checksum } " mixin. It calculates checksums by running a console utility as described in the " { $slot "launch-desc" } " slot, piping data to it and receiving the output at the end. Each call to " { $link initialize-checksum-state } " starts a new external process, which is represented by a " { $link process-state } " instance. The latter also holds the resulting checksum." } ;

HELP: process-state
{ $class-description "This class represents the current state of a " { $link checksum-process } " checksum calculation. It has an associated external console application running until it is disposed. You may call " { $link add-checksum-bytes } " multiple times to pipe data to the external utility. When finished, call " { $link get-checksum } " to receive the result and terminate the process, or " { $link dispose } " to discard the result and terminate the process. After the first " { $link get-checksum } " call the returned value is stored in the " { $slot "result" } " slot, and subsequent calls return the same value." }
{ $notes "It is not possible to add more data to the checksum after the first get-checksum call."
$nl
"Most code should use " { $link with-checksum-state } " to make sure the external process is disposed of. Higher level words like " { $link checksum-bytes } " and " { $link checksum-stream } " use it to perform the disposal." } ;

HELP: trim-hash
{ $values
    { "str" "a string returned by a console hashing utility" }
    { "str'" "extracted hash string" }
}
{ $description "This is a helper word for " { $link process-state } "'s " { $link get-checksum } " implementation. It looks for the hash terminator string \" *-\" and returns everything before it." } ;
