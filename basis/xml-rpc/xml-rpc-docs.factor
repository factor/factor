USING: help.syntax help.markup math sequences strings ;
IN: xml-rpc

HELP: send-rpc
{ $values { "rpc" "an RPC data type" } { "xml" "an XML document" } }
{ $description "converts an RPC data type into an XML document which can be sent to another computer" }
{ $see-also receive-rpc } ;

HELP: receive-rpc
{ $values { "xml" "an XML document" } { "rpc" "an RPC data type" } }
{ $description "parses an XML document into an RPC data type, for further local processing" }
{ $see-also send-rpc } ;

HELP: <base64>
{ $values { "string" string } { "base64" "a base64 tuple" } }
{ $description "creates a base64 tuple using the data in the string. This marks the data for encoding in the base64 format" }
{ $see-also base64 } ;

HELP: base64
{ $class-description "a piece of data marked for encoding as base64 in an XML-RPC message" }
{ $see-also <base64> } ;

HELP: <rpc-method>
{ $values { "name" string } { "params" sequence } { "rpc-method" rpc-method } }
{ $description "creates a tuple representing a method call which can be translated using send-rpc into an XML-RPC document" }
{ $see-also rpc-method <rpc-response> <rpc-fault> } ;

HELP: rpc-method
{ $class-description "a tuple which is equivalent to an XML-RPC method send. Contains two fields, name and params" }
{ $see-also <rpc-method> rpc-response rpc-fault } ;

HELP: <rpc-response>
{ $values { "params" sequence } { "rpc-response" rpc-response } }
{ $description "creates a tuple representing a data response in XML-RPC" }
{ $see-also rpc-response <rpc-method> <rpc-fault> } ;

HELP: rpc-response
{ $class-description "represents an XML-RPC method response, with a number of parameters holding data. Contains one field, params, a sequence" }
{ $see-also <rpc-response> rpc-method rpc-fault } ;

HELP: <rpc-fault>
{ $values { "code" integer } { "string" string } { "rpc-fault" rpc-fault } }
{ $description "creates a tuple representing an exception in RPC, to be returned to the caller. The code is a number representing what type of error it is, and the string is a description" }
{ $see-also rpc-fault <rpc-method> <rpc-response> } ;

HELP: rpc-fault
{ $class-description "represents an XML-RPC fault" }
{ $see-also <rpc-fault> rpc-method rpc-response } ;

HELP: post-rpc
{ $values { "rpc" "an XML-RPC input tuple" } { "url" "a URL" }
    { "rpc'" "an XML-RPC output tuple" } }
{ $description "posts an XML-RPC document to the specified URL, receives the response and parses it as XML-RPC, returning the tuple" } ;

ARTICLE: { "xml-rpc" "intro" } "XML-RPC"
"This is the XML-RPC library. XML-RPC is used instead of SOAP because it is far simpler and easier to use for most tasks. The library was implemented by Daniel Ehrenberg."
$nl
"The most important words that this library implements are:"
{ $subsections
    send-rpc
    receive-rpc
}
"data types in XML-RPC"
{ $subsections
    base64
    rpc-method
    rpc-response
    rpc-fault
}
"the constructors for these are"
{ $subsections
    <base64>
    <rpc-method>
    <rpc-response>
    <rpc-fault>
}
"other words include"
{ $subsections post-rpc } ;
