USING: help.syntax help.markup ;
IN: fonts.syntax

HELP: FONT:
{ $syntax "\"testing\" <label> FONT: 18 serif bold ... ;" }
{ $description "Used after a gadget to change font settings.  Attributes can be in any order: the first number is set as the size, the style attributes like bold and italic will set the bold? and italic? slots, and font-names like serif or monospace will set the name slot." } ;
