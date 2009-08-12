! (c)Joe Groff bsd license
USING: classes.struct kernel prettyprint.backend
prettyprint.sections see.private sequences words ;
IN: classes.struct.prettyprint

M: struct-class see-class*
    <colon \ STRUCT: pprint-word dup pprint-word
    <block "struct-slots" word-prop [ pprint-slot ] each
    block> pprint-; block> ;


