! Copyright (c) 2008 Aaron Schaefer, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs grouping io.encodings.ascii
io.files kernel make math math.parser project-euler.common
sequences sequences.private sets sorting splitting ;
IN: project-euler.059

! https://projecteuler.net/index.php?section=problems&id=59

! DESCRIPTION
! -----------

! Each character on a computer is assigned a unique code and the preferred
! standard is ASCII (American Standard Code for Information Interchange). For
! example, uppercase A = 65, asterisk (*) = 42, and lowercase k = 107.

! A modern encryption method is to take a text file, convert the bytes to
! ASCII, then XOR each byte with a given value, taken from a secret key. The
! advantage with the XOR function is that using the same encryption key on the
! cipher text, restores the plain text; for example, 65 XOR 42 = 107, then 107
! XOR 42 = 65.

! For unbreakable encryption, the key is the same length as the plain text
! message, and the key is made up of random bytes. The user would keep the
! encrypted message and the encryption key in different locations, and without
! both "halves", it is impossible to decrypt the message.

! Unfortunately, this method is impractical for most users, so the modified
! method is to use a password as a key. If the password is shorter than the
! message, which is likely, the key is repeated cyclically throughout the
! message. The balance for this method is using a sufficiently long password
! key for security, but short enough to be memorable.

! Your task has been made easy, as the encryption key consists of three lower
! case characters. Using cipher1.txt (right click and 'Save Link/Target
! As...'), a file containing the encrypted ASCII codes, and the knowledge that
! the plain text must contain common English words, decrypt the message and
! find the sum of the ASCII values in the original text.


! SOLUTION
! --------

! Assume that the space character will be the most common, so XOR the input
! text with a space character then group the text into three "columns" since
! that's how long our key is.  Then do frequency analysis on each column to
! find out what the most likely candidate is for the key.

! NOTE: This technique would probably not work well in all cases, but luckily
! it did for this particular problem.

<PRIVATE

: source-059 ( -- seq )
    "resource:extra/project-euler/059/cipher1.txt"
    ascii file-contents [ blank? ] trim-tail "," split
    [ string>number ] map ;

TUPLE: rollover seq n ;

C: <rollover> rollover

M: rollover length n>> ;

M: rollover nth-unsafe seq>> [ length mod ] keep nth-unsafe ;

INSTANCE: rollover immutable-sequence

: decrypt ( seq key -- seq )
    over length <rollover> swap [ bitxor ] 2map ;

: frequency-analysis ( seq -- seq )
    dup members [
        [ 2dup [ = ] curry count 2array , ] each
    ] { } make nip ; inline

: most-frequent ( seq -- elt )
    frequency-analysis sort-values keys last ;

: crack-key ( seq key-length -- key )
    [ " " decrypt ] dip group but-last-slice
    flip [ most-frequent ] map ;

PRIVATE>

: euler059 ( -- answer )
    source-059 dup 3 crack-key decrypt sum ;

! [ euler059 ] 100 ave-time
! 8 ms ave run time - 1.4 SD (100 trials)

SOLUTION: euler059
