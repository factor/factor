! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings openai ui.commands ;
IN: openai.ui

HELP: <ask>
{ $values
    { "gpt-gadget" object }
}
{ $description "Creates the ask entry field for the prompt to the API" } ;

HELP: <gpt-gadget>
{ $values
    { "gadget" object }
}
{ $description "Creates the gadget for the UI" } ;

HELP: <response>
{ $values
    { "gpt-gadget" object }
}
{ $description "Creates a scrolling pane for the response" } ;

HELP: >q
{ $values
    { "question" object }
}
{ $description "Sends the question to OpenAI API. Intended for simple questions using the listener." } ;

HELP: gpt-gadget
{ $class-description "Definition of a track gadget containing an ask and response element." } ;

HELP: gpt-new
{ $description "Opens a new window for asking a question using openai." } ;

HELP: init-api-key
{ $description
  "Initialize the API key which MUST be located in the path set in "
  { $link OPENAI-KEY-PATH }
} ;

HELP: OPENAI-KEY-PATH
{ $description "Holds the path to the users API key file." }
    ;

HELP: openai-doc
{ $description "Opens a URL to the OpenAI web site documentation." } ;

HELP: openai-test
{ $description "Simple code to test connection to OpenAI API." } ;

HELP: wrap-result
{ $values
    { "string" string } { "maxwidth" object }
    { "string'" string }
}
{ $description "Takes a long string from the response and wraps it according to the repsonse pane width." } ;

ARTICLE: "openai.ui" "A GUI interface for OpenAI API"
"This is intended to serve as a simple implementation to interface to the OpenAI API"

"It can also be opened using words:"
{ $subsections
    gpt-new
}

{ $command-map gpt-gadget "toolbar" }

{ $vocab-link "openai" }
;

ABOUT: "openai.ui"
