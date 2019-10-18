USING: ui.gestures help.markup help.syntax strings kernel
hashtables quotations words classes sequences namespaces
arrays assocs ;
IN: ui.commands

: command-map-row
    [
        dup first gesture>string ,
        second dup command-name ,
        dup command-word \ $link swap 2array ,
        command-description ,
    ] [ ] make ;

: command-map. ( command-map -- )
    [ command-map-row ] map
    { "Shortcut" "Command" "Word" "Notes" }
    [ \ $strong swap ] { } map>assoc add*
    $table ;

: $command-map ( element -- )
    first2
    dup (command-name) " commands" append $heading
    swap command-map
    dup command-map-blurb print-element command-map. ;

: $command ( element -- )
    reverse first3 command-map value-at gesture>string $snippet ;

HELP: +nullary+
{ $description "A key which may be set in the hashtable passed to " { $link define-command } ". If set to a true value, the command does not take any inputs, and the value passed to " { $link invoke-command } " will be ignored. Otherwise, it takes one input." } ;

HELP: +listener+
{ $description "A key which may be set in the hashtable passed to " { $link define-command } ". If set to a true value, " { $link invoke-command } " will run the command in the listener. Otherwise it will run in the event loop." } ;

HELP: +description+
{ $description "A key which may be set in the hashtable passed to " { $link define-command } ". The value is a string displayed as part of the command's documentation by " { $link $command-map } "." } ;

HELP: invoke-command
{ $values { "target" object } { "command" "a command" } }
{ $description "Invokes a command on the given target object." } ;

{ invoke-command +nullary+ } related-words

HELP: command-name
{ $values { "command" "a command" } { "str" "a string" } }
{ $description "Outputs a human-readable name for the command." }
{ $examples
    { $example
        "USE: ui.commands"
        ": com-my-command ;"
        "\\ com-my-command command-name write"
        "My command"
    }
} ;

HELP: command-description
{ $values { "command" "a command" } { "str/f" "a string or " { $link f } } }
{ $description "Outputs the command's description." } ;

{ command-description +description+ } related-words

HELP: command-word
{ $values { "command" "a command" } { "word" word } }
{ $description "Outputs the word that will be executed by " { $link invoke-command } ". This is only used for documentation purposes." } ;

HELP: command-map
{ $values { "group" string } { "class" "a class word" } { "command-map" "a " { $link command-map } " or " { $link f } } }
{ $description "Outputs a named command map defined on a class." }
{ $class-description "A command map stores a group of related commands. Instances of this class delegate to arrays so behave like sequences; additionally the " { $link command-map-blurb } " slot stores a string description of the command group, or " { $link f } "."
$nl
"Command maps are created by calling " { $link <command-map> } " or " { $link define-command-map } "." } ;

HELP: commands
{ $values { "class" "a class word" } { "hash" hashtable } }
{ $description "Outputs a hashtable mapping command map names to " { $link command-map } " instances." } ;

HELP: define-command-map
{ $values { "class" "a class word" } { "group" string } { "blurb" "a " { $link string } " or " { $link f } } { "pairs" "a sequence of gesture/word pairs" } }
{ $description
    "Defines a command map on the specified gadget class. The " { $snippet "specs" } " parameter is a sequence of pairs " { $snippet "{ gesture word }" } ". The words must be valid commands; see " { $link define-command } "."
}
{ $notes "Only one of " { $link define-command-map } " and " { $link set-gestures } " can be used on a given gadget class, since each word will overwrite the other word's definitions." } ;

HELP: $command-map
{ $values { "element" "a pair " { $snippet "{ class map }" } } }
{ $description "Prints a command map, where the first element of the pair is a class word and the second is a command map name." } ;

HELP: $command
{ $values { "element" "a triple " { $snippet "{ class map command }" } } }
{ $description "Prints the keyboard shortcut associated with " { $snippet "command" } " in the command map named " { $snippet "map" } " on the class " { $snippet "class" } "." } ;

HELP: define-command
{ $values { "word" word } { "hash" hashtable } } 
{ $description "Defines a command. The hashtable can contain the following keys:"
    { $list
        { { $link +nullary+ } " - if set to a true value, the word must have stack effect " { $snippet "( -- )" } "; otherwise it must have stack effect " { $snippet "( target -- )" } }
        { { $link +listener+ } " - if set to a true value, the command will run in the listener" }
        { { $link +description+ } " - can be set to a string description of the command" }
    }
} ;

HELP: command-string
{ $values { "gesture" "a gesture" } { "command" "a command" } { "string" string } }
{ $description "Outputs a string containing the command name followed by the gesture." }
{ $examples
    { $example
        "USING: ui.commands ui.gestures ;"
        ": com-my-command ;"
        "T{ key-down f { C+ } \"s\" } \\ com-my-command command-string write"
        "My command (C+s)"
    }
} ;

ARTICLE: "ui-commands" "Commands"
"Commands are an abstraction layered on top of gestures. Their main advantage is that they are identified by words and can be organized into " { $emphasis "command maps" } ". This allows easy construction of buttons and tool bars for invoking commands."
{ $subsection define-command }
"Command groups are defined on gadget classes:"
{ $subsection define-command-map }
"Commands can be introspected and invoked:"
{ $subsection commands }
{ $subsection command-map }
{ $subsection invoke-command }
"Gadgets for invoking commands are documented in " { $link "ui.gadgets.buttons" } "."
$nl
"When documenting gadgets, command documentation can be automatically generated:"
{ $subsection $command-map }
{ $subsection $command } ;

ABOUT: "ui-commands"
