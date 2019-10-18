USING: accessors compiler.cfg.registers prettyprint.backend
prettyprint.custom prettyprint.sections ;
IN: compiler.prettyprint

: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

M: ds-loc pprint* \ D: pprint-loc ;

M: rs-loc pprint* \ R: pprint-loc ;
