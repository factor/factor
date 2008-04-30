USING: help.markup help.syntax ;
IN: checksums.sha1

HELP: sha1
{ $description "SHA1 checksum algorithm." } ;

ARTICLE: "checksums.sha1" "SHA1 checksum"
"The SHA1 checksum algorithm implements a one-way hash function. It is generally considered to be stronger than MD5, however there is a known algorithm for finding collisions more effectively than a brute-force search (" { $url "http://www.schneier.com/blog/archives/2005/02/sha1_broken.html" } ")."
{ $subsection sha1 } ;

ABOUT: "checksums.sha1"
