USING: accessors colors.hex prettyprint.custom
prettyprint.backend prettyprint.sections ;

IN: colors.hex.prettyprint

M: hex-color pprint* \ HEXCOLOR: [ hex>> text ] pprint-prefix ;
