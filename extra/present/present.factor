USING: math math.parser calendar calendar.format strings words
kernel ;
IN: present

GENERIC: present ( object -- string )

M: real present number>string ;

M: timestamp present timestamp>string ;

M: string present ;

M: word present word-name ;

M: effect present effect>string ;

M: f present drop "" ;
