! Copyright (C) 2009 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: s3

HELP: buckets
{ $values 
  { "seq" "a sequence of " { $link bucket } " objects" } 
}
{ $description 
    "Returns a list of " { $link bucket } " objects containing data on the buckets available on S3."}
{ $examples
  { $unchecked-example "USING: s3 ;" "buckets ." "{ }" }
}
;

HELP: create-bucket
{ $values 
  { "bucket" "a string" } 
}
{ $description 
    "Creates a bucket with the given name."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"testbucket\" create-bucket" "" }
}
;

HELP: delete-bucket
{ $values 
  { "bucket" "a string" } 
}
{ $description 
    "Deletes the bucket with the given name."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"testbucket\" delete-bucket" "" }
}
;

HELP: keys
{ $values 
  { "bucket" "a string" } 
  { "seq" "a sequence of " { $link key } " objects"} 
}
{ $description 
    "Returns a sequence of " { $link key } " objects. Each object in the sequence has information about the keys contained within the bucket."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"testbucket\" keys . " "{ }" }
}
;

HELP: get-object
{ $values 
  { "bucket" "a string" } 
  { "key" "a string" } 
  { "response" "The HTTP response object"} 
  { "data" "The data returned from the http request"} 
}
{ $description 
    "Does an HTTP request to retrieve the object in the bucket with the given key."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"testbucket\" \"mykey\" http-get " "" }
}
;

HELP: put-object
{ $values 
  { "data" "an object" } 
  { "mime-type" "a string" } 
  { "bucket" "a string"} 
  { "key" "a string"} 
  { "headers" "an assoc"} 
}
{ $description 
    "Stores the object under the key in the given bucket. The object has "
"the given mimetype. 'headers' should contain key/values for any headers to "
"be associated with the object. 'data' is any Factor object that can be "
"used as the 'data' slot in <post-data>. If it's a <pathname> it stores "
"the contents of the file. If it's a stream, it's the contents of the "
"stream, etc."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"hello\" binary encode \"text/plain\" \"testbucket\" \"hello.txt\" H{ { \"x-amz-acl\" \"public-read\" } } put-object" "" }
  { $unchecked-example "USING: s3 ;" "\"hello.txt\" <pathname> \"text/plain\" \"testbucket\" \"hello.txt\" H{ { \"x-amz-acl\" \"public-read\" } } put-object" "" }
}
;

HELP: delete-object
{ $values 
  { "bucket" "a string"} 
  { "key" "a string"} 
}
{ $description 
    "Deletes the object in the bucket with the given key."
} 
{ $examples
  { $unchecked-example "USING: s3 ;" "\"testbucket\" \"mykey\" delete-object" "" }
}
;

ARTICLE: "s3" "Amazon S3"
"The " { $vocab-link "s3" } " vocabulary provides a wrapper to the Amazon "
"Simple Storage Service API."
$nl
"To use the api you must set the variables " { $link key-id } " and " 
{ $link secret-key } " to your Amazon S3 key and secret key respectively. Once "
"this is done you can call any of the words below."
{ $subsection buckets }
{ $subsection create-bucket }
{ $subsection delete-bucket }
{ $subsection keys }
{ $subsection get-object }
{ $subsection put-object }
{ $subsection delete-object }
;

ABOUT: "s3"