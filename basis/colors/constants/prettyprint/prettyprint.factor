USING: accessors colors.constants prettyprint.custom
prettyprint.backend prettyprint.sections ;

IN: colors.constants.prettyprint

M: named-color pprint* \ COLOR: [ name>> text ] pprint-prefix ;

