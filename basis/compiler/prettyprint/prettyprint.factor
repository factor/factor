USING: accessors compiler.cfg.registers prettyprint.backend
prettyprint.custom prettyprint.sections ;
IN: compiler.prettyprint

: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

M: ds-loc pprint* \ d: pprint-loc ;

M: rs-loc pprint* \ r: pprint-loc ;
