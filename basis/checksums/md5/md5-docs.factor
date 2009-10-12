USING: help.markup help.syntax ;
IN: checksums.md5

HELP: md5
{ $class-description "MD5 checksum algorithm." } ;

ARTICLE: "checksums.md5" "MD5 checksum"
"The MD5 checksum algorithm implements a one-way hash function. While it is widely used, many weaknesses are known and it should not be used in new applications (" { $url "http://www.schneier.com/blog/archives/2005/03/more_hash_funct.html" } ")."
{ $subsections md5 } ;

ABOUT: "checksums.md5"
