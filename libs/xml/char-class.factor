IN: char-classes
USING: kernel sequences math ;

: in-range-seq? ( number seq -- ? )
    #! seq: { { min max } { min max }* }
    [ first2 between? ] contains-with? ;

PREDICATE: integer 1.1name-start-char
    {
        { CHAR: _    CHAR: _    }
        { CHAR: A    CHAR: Z    }
        { CHAR: a    CHAR: z    }
        { HEX: C0    HEX: D6    }
        { HEX: D8    HEX: F6    }
        { HEX: F8    HEX: 2FF   }
        { HEX: 370   HEX: 37D   }
        { HEX: 37F   HEX: 1FFF  }
        { HEX: 200C  HEX: 200D  }
        { HEX: 2070  HEX: 218F  }
        { HEX: 2C00  HEX: 2FEF  }
        { HEX: 3001  HEX: D7FF  }
        { HEX: F900  HEX: FDCF  }
        { HEX: FDF0  HEX: FFFD  }
        { HEX: 10000 HEX: EFFFF }
    } in-range-seq? ;

PREDICATE: integer 1.1name-char
    dup 1.1name-start-char? swap {
        { CHAR: -   CHAR: -   }
        { CHAR: .   CHAR: .   }
        { CHAR: 0   CHAR: 9   }
        { HEX: b7   HEX: b7   }
        { HEX: 300  HEX: 36F  }
        { HEX: 203F HEX: 2040 }
    } in-range-seq? or ;

! The following 335 lines were automatically generated
! from Appendix B of the XML 1.0 standard, version 3

PREDICATE: integer base-char {
    { HEX: 0041 HEX: 005A } 
    { HEX: 0061 HEX: 007A } 
    { HEX: 00C0 HEX: 00D6 } 
    { HEX: 00D8 HEX: 00F6 } 
    { HEX: 00F8 HEX: 00FF } 
    { HEX: 0100 HEX: 0131 } 
    { HEX: 0134 HEX: 013E } 
    { HEX: 0141 HEX: 0148 } 
    { HEX: 014A HEX: 017E } 
    { HEX: 0180 HEX: 01C3 } 
    { HEX: 01CD HEX: 01F0 } 
    { HEX: 01F4 HEX: 01F5 } 
    { HEX: 01FA HEX: 0217 } 
    { HEX: 0250 HEX: 02A8 } 
    { HEX: 02BB HEX: 02C1 } 
    { HEX: 0386 HEX: 0386 } 
    { HEX: 0388 HEX: 038A } 
    { HEX: 038C HEX: 038C } 
    { HEX: 038E HEX: 03A1 } 
    { HEX: 03A3 HEX: 03CE } 
    { HEX: 03D0 HEX: 03D6 } 
    { HEX: 03DA HEX: 03DA } 
    { HEX: 03DC HEX: 03DC } 
    { HEX: 03DE HEX: 03DE } 
    { HEX: 03E0 HEX: 03E0 } 
    { HEX: 03E2 HEX: 03F3 } 
    { HEX: 0401 HEX: 040C } 
    { HEX: 040E HEX: 044F } 
    { HEX: 0451 HEX: 045C } 
    { HEX: 045E HEX: 0481 } 
    { HEX: 0490 HEX: 04C4 } 
    { HEX: 04C7 HEX: 04C8 } 
    { HEX: 04CB HEX: 04CC } 
    { HEX: 04D0 HEX: 04EB } 
    { HEX: 04EE HEX: 04F5 } 
    { HEX: 04F8 HEX: 04F9 } 
    { HEX: 0531 HEX: 0556 } 
    { HEX: 0559 HEX: 0559 } 
    { HEX: 0561 HEX: 0586 } 
    { HEX: 05D0 HEX: 05EA } 
    { HEX: 05F0 HEX: 05F2 } 
    { HEX: 0621 HEX: 063A } 
    { HEX: 0641 HEX: 064A } 
    { HEX: 0671 HEX: 06B7 } 
    { HEX: 06BA HEX: 06BE } 
    { HEX: 06C0 HEX: 06CE } 
    { HEX: 06D0 HEX: 06D3 } 
    { HEX: 06D5 HEX: 06D5 } 
    { HEX: 06E5 HEX: 06E6 } 
    { HEX: 0905 HEX: 0939 } 
    { HEX: 093D HEX: 093D } 
    { HEX: 0958 HEX: 0961 } 
    { HEX: 0985 HEX: 098C } 
    { HEX: 098F HEX: 0990 } 
    { HEX: 0993 HEX: 09A8 } 
    { HEX: 09AA HEX: 09B0 } 
    { HEX: 09B2 HEX: 09B2 } 
    { HEX: 09B6 HEX: 09B9 } 
    { HEX: 09DC HEX: 09DD } 
    { HEX: 09DF HEX: 09E1 } 
    { HEX: 09F0 HEX: 09F1 } 
    { HEX: 0A05 HEX: 0A0A } 
    { HEX: 0A0F HEX: 0A10 } 
    { HEX: 0A13 HEX: 0A28 } 
    { HEX: 0A2A HEX: 0A30 } 
    { HEX: 0A32 HEX: 0A33 } 
    { HEX: 0A35 HEX: 0A36 } 
    { HEX: 0A38 HEX: 0A39 } 
    { HEX: 0A59 HEX: 0A5C } 
    { HEX: 0A5E HEX: 0A5E } 
    { HEX: 0A72 HEX: 0A74 } 
    { HEX: 0A85 HEX: 0A8B } 
    { HEX: 0A8D HEX: 0A8D } 
    { HEX: 0A8F HEX: 0A91 } 
    { HEX: 0A93 HEX: 0AA8 } 
    { HEX: 0AAA HEX: 0AB0 } 
    { HEX: 0AB2 HEX: 0AB3 } 
    { HEX: 0AB5 HEX: 0AB9 } 
    { HEX: 0ABD HEX: 0ABD } 
    { HEX: 0AE0 HEX: 0AE0 } 
    { HEX: 0B05 HEX: 0B0C } 
    { HEX: 0B0F HEX: 0B10 } 
    { HEX: 0B13 HEX: 0B28 } 
    { HEX: 0B2A HEX: 0B30 } 
    { HEX: 0B32 HEX: 0B33 } 
    { HEX: 0B36 HEX: 0B39 } 
    { HEX: 0B3D HEX: 0B3D } 
    { HEX: 0B5C HEX: 0B5D } 
    { HEX: 0B5F HEX: 0B61 } 
    { HEX: 0B85 HEX: 0B8A } 
    { HEX: 0B8E HEX: 0B90 } 
    { HEX: 0B92 HEX: 0B95 } 
    { HEX: 0B99 HEX: 0B9A } 
    { HEX: 0B9C HEX: 0B9C } 
    { HEX: 0B9E HEX: 0B9F } 
    { HEX: 0BA3 HEX: 0BA4 } 
    { HEX: 0BA8 HEX: 0BAA } 
    { HEX: 0BAE HEX: 0BB5 } 
    { HEX: 0BB7 HEX: 0BB9 } 
    { HEX: 0C05 HEX: 0C0C } 
    { HEX: 0C0E HEX: 0C10 } 
    { HEX: 0C12 HEX: 0C28 } 
    { HEX: 0C2A HEX: 0C33 } 
    { HEX: 0C35 HEX: 0C39 } 
    { HEX: 0C60 HEX: 0C61 } 
    { HEX: 0C85 HEX: 0C8C } 
    { HEX: 0C8E HEX: 0C90 } 
    { HEX: 0C92 HEX: 0CA8 } 
    { HEX: 0CAA HEX: 0CB3 } 
    { HEX: 0CB5 HEX: 0CB9 } 
    { HEX: 0CDE HEX: 0CDE } 
    { HEX: 0CE0 HEX: 0CE1 } 
    { HEX: 0D05 HEX: 0D0C } 
    { HEX: 0D0E HEX: 0D10 } 
    { HEX: 0D12 HEX: 0D28 } 
    { HEX: 0D2A HEX: 0D39 } 
    { HEX: 0D60 HEX: 0D61 } 
    { HEX: 0E01 HEX: 0E2E } 
    { HEX: 0E30 HEX: 0E30 } 
    { HEX: 0E32 HEX: 0E33 } 
    { HEX: 0E40 HEX: 0E45 } 
    { HEX: 0E81 HEX: 0E82 } 
    { HEX: 0E84 HEX: 0E84 } 
    { HEX: 0E87 HEX: 0E88 } 
    { HEX: 0E8A HEX: 0E8A } 
    { HEX: 0E8D HEX: 0E8D } 
    { HEX: 0E94 HEX: 0E97 } 
    { HEX: 0E99 HEX: 0E9F } 
    { HEX: 0EA1 HEX: 0EA3 } 
    { HEX: 0EA5 HEX: 0EA5 } 
    { HEX: 0EA7 HEX: 0EA7 } 
    { HEX: 0EAA HEX: 0EAB } 
    { HEX: 0EAD HEX: 0EAE } 
    { HEX: 0EB0 HEX: 0EB0 } 
    { HEX: 0EB2 HEX: 0EB3 } 
    { HEX: 0EBD HEX: 0EBD } 
    { HEX: 0EC0 HEX: 0EC4 } 
    { HEX: 0F40 HEX: 0F47 } 
    { HEX: 0F49 HEX: 0F69 } 
    { HEX: 10A0 HEX: 10C5 } 
    { HEX: 10D0 HEX: 10F6 } 
    { HEX: 1100 HEX: 1100 } 
    { HEX: 1102 HEX: 1103 } 
    { HEX: 1105 HEX: 1107 } 
    { HEX: 1109 HEX: 1109 } 
    { HEX: 110B HEX: 110C } 
    { HEX: 110E HEX: 1112 } 
    { HEX: 113C HEX: 113C } 
    { HEX: 113E HEX: 113E } 
    { HEX: 1140 HEX: 1140 } 
    { HEX: 114C HEX: 114C } 
    { HEX: 114E HEX: 114E } 
    { HEX: 1150 HEX: 1150 } 
    { HEX: 1154 HEX: 1155 } 
    { HEX: 1159 HEX: 1159 } 
    { HEX: 115F HEX: 1161 } 
    { HEX: 1163 HEX: 1163 } 
    { HEX: 1165 HEX: 1165 } 
    { HEX: 1167 HEX: 1167 } 
    { HEX: 1169 HEX: 1169 } 
    { HEX: 116D HEX: 116E } 
    { HEX: 1172 HEX: 1173 } 
    { HEX: 1175 HEX: 1175 } 
    { HEX: 119E HEX: 119E } 
    { HEX: 11A8 HEX: 11A8 } 
    { HEX: 11AB HEX: 11AB } 
    { HEX: 11AE HEX: 11AF } 
    { HEX: 11B7 HEX: 11B8 } 
    { HEX: 11BA HEX: 11BA } 
    { HEX: 11BC HEX: 11C2 } 
    { HEX: 11EB HEX: 11EB } 
    { HEX: 11F0 HEX: 11F0 } 
    { HEX: 11F9 HEX: 11F9 } 
    { HEX: 1E00 HEX: 1E9B } 
    { HEX: 1EA0 HEX: 1EF9 } 
    { HEX: 1F00 HEX: 1F15 } 
    { HEX: 1F18 HEX: 1F1D } 
    { HEX: 1F20 HEX: 1F45 } 
    { HEX: 1F48 HEX: 1F4D } 
    { HEX: 1F50 HEX: 1F57 } 
    { HEX: 1F59 HEX: 1F59 } 
    { HEX: 1F5B HEX: 1F5B } 
    { HEX: 1F5D HEX: 1F5D } 
    { HEX: 1F5F HEX: 1F7D } 
    { HEX: 1F80 HEX: 1FB4 } 
    { HEX: 1FB6 HEX: 1FBC } 
    { HEX: 1FBE HEX: 1FBE } 
    { HEX: 1FC2 HEX: 1FC4 } 
    { HEX: 1FC6 HEX: 1FCC } 
    { HEX: 1FD0 HEX: 1FD3 } 
    { HEX: 1FD6 HEX: 1FDB } 
    { HEX: 1FE0 HEX: 1FEC } 
    { HEX: 1FF2 HEX: 1FF4 } 
    { HEX: 1FF6 HEX: 1FFC } 
    { HEX: 2126 HEX: 2126 } 
    { HEX: 212A HEX: 212B } 
    { HEX: 212E HEX: 212E } 
    { HEX: 2180 HEX: 2182 } 
    { HEX: 3041 HEX: 3094 } 
    { HEX: 30A1 HEX: 30FA } 
    { HEX: 3105 HEX: 312C } 
    { HEX: AC00 HEX: D7A3 } } in-range-seq? ;

PREDICATE: integer ideographic {
    { HEX: 4E00 HEX: 9FA5 } 
    { HEX: 3007 HEX: 3007 } 
    { HEX: 3021 HEX: 3029 } } in-range-seq? ;

PREDICATE: integer combining-char {
    { HEX: 0300 HEX: 0345 } 
    { HEX: 0360 HEX: 0361 } 
    { HEX: 0483 HEX: 0486 } 
    { HEX: 0591 HEX: 05A1 } 
    { HEX: 05A3 HEX: 05B9 } 
    { HEX: 05BB HEX: 05BD } 
    { HEX: 05BF HEX: 05BF } 
    { HEX: 05C1 HEX: 05C2 } 
    { HEX: 05C4 HEX: 05C4 } 
    { HEX: 064B HEX: 0652 } 
    { HEX: 0670 HEX: 0670 } 
    { HEX: 06D6 HEX: 06DC } 
    { HEX: 06DD HEX: 06DF } 
    { HEX: 06E0 HEX: 06E4 } 
    { HEX: 06E7 HEX: 06E8 } 
    { HEX: 06EA HEX: 06ED } 
    { HEX: 0901 HEX: 0903 } 
    { HEX: 093C HEX: 093C } 
    { HEX: 093E HEX: 094C } 
    { HEX: 094D HEX: 094D } 
    { HEX: 0951 HEX: 0954 } 
    { HEX: 0962 HEX: 0963 } 
    { HEX: 0981 HEX: 0983 } 
    { HEX: 09BC HEX: 09BC } 
    { HEX: 09BE HEX: 09BE } 
    { HEX: 09BF HEX: 09BF } 
    { HEX: 09C0 HEX: 09C4 } 
    { HEX: 09C7 HEX: 09C8 } 
    { HEX: 09CB HEX: 09CD } 
    { HEX: 09D7 HEX: 09D7 } 
    { HEX: 09E2 HEX: 09E3 } 
    { HEX: 0A02 HEX: 0A02 } 
    { HEX: 0A3C HEX: 0A3C } 
    { HEX: 0A3E HEX: 0A3E } 
    { HEX: 0A3F HEX: 0A3F } 
    { HEX: 0A40 HEX: 0A42 } 
    { HEX: 0A47 HEX: 0A48 } 
    { HEX: 0A4B HEX: 0A4D } 
    { HEX: 0A70 HEX: 0A71 } 
    { HEX: 0A81 HEX: 0A83 } 
    { HEX: 0ABC HEX: 0ABC } 
    { HEX: 0ABE HEX: 0AC5 } 
    { HEX: 0AC7 HEX: 0AC9 } 
    { HEX: 0ACB HEX: 0ACD } 
    { HEX: 0B01 HEX: 0B03 } 
    { HEX: 0B3C HEX: 0B3C } 
    { HEX: 0B3E HEX: 0B43 } 
    { HEX: 0B47 HEX: 0B48 } 
    { HEX: 0B4B HEX: 0B4D } 
    { HEX: 0B56 HEX: 0B57 } 
    { HEX: 0B82 HEX: 0B83 } 
    { HEX: 0BBE HEX: 0BC2 } 
    { HEX: 0BC6 HEX: 0BC8 } 
    { HEX: 0BCA HEX: 0BCD } 
    { HEX: 0BD7 HEX: 0BD7 } 
    { HEX: 0C01 HEX: 0C03 } 
    { HEX: 0C3E HEX: 0C44 } 
    { HEX: 0C46 HEX: 0C48 } 
    { HEX: 0C4A HEX: 0C4D } 
    { HEX: 0C55 HEX: 0C56 } 
    { HEX: 0C82 HEX: 0C83 } 
    { HEX: 0CBE HEX: 0CC4 } 
    { HEX: 0CC6 HEX: 0CC8 } 
    { HEX: 0CCA HEX: 0CCD } 
    { HEX: 0CD5 HEX: 0CD6 } 
    { HEX: 0D02 HEX: 0D03 } 
    { HEX: 0D3E HEX: 0D43 } 
    { HEX: 0D46 HEX: 0D48 } 
    { HEX: 0D4A HEX: 0D4D } 
    { HEX: 0D57 HEX: 0D57 } 
    { HEX: 0E31 HEX: 0E31 } 
    { HEX: 0E34 HEX: 0E3A } 
    { HEX: 0E47 HEX: 0E4E } 
    { HEX: 0EB1 HEX: 0EB1 } 
    { HEX: 0EB4 HEX: 0EB9 } 
    { HEX: 0EBB HEX: 0EBC } 
    { HEX: 0EC8 HEX: 0ECD } 
    { HEX: 0F18 HEX: 0F19 } 
    { HEX: 0F35 HEX: 0F35 } 
    { HEX: 0F37 HEX: 0F37 } 
    { HEX: 0F39 HEX: 0F39 } 
    { HEX: 0F3E HEX: 0F3E } 
    { HEX: 0F3F HEX: 0F3F } 
    { HEX: 0F71 HEX: 0F84 } 
    { HEX: 0F86 HEX: 0F8B } 
    { HEX: 0F90 HEX: 0F95 } 
    { HEX: 0F97 HEX: 0F97 } 
    { HEX: 0F99 HEX: 0FAD } 
    { HEX: 0FB1 HEX: 0FB7 } 
    { HEX: 0FB9 HEX: 0FB9 } 
    { HEX: 20D0 HEX: 20DC } 
    { HEX: 20E1 HEX: 20E1 } 
    { HEX: 302A HEX: 302F } 
    { HEX: 3099 HEX: 3099 } 
    { HEX: 309A HEX: 309A } } in-range-seq? ;

PREDICATE: integer unicode-digit {
    { HEX: 0030 HEX: 0039 } 
    { HEX: 0660 HEX: 0669 } 
    { HEX: 06F0 HEX: 06F9 } 
    { HEX: 0966 HEX: 096F } 
    { HEX: 09E6 HEX: 09EF } 
    { HEX: 0A66 HEX: 0A6F } 
    { HEX: 0AE6 HEX: 0AEF } 
    { HEX: 0B66 HEX: 0B6F } 
    { HEX: 0BE7 HEX: 0BEF } 
    { HEX: 0C66 HEX: 0C6F } 
    { HEX: 0CE6 HEX: 0CEF } 
    { HEX: 0D66 HEX: 0D6F } 
    { HEX: 0E50 HEX: 0E59 } 
    { HEX: 0ED0 HEX: 0ED9 } 
    { HEX: 0F20 HEX: 0F29 } } in-range-seq? ;

PREDICATE: integer extender {
    { HEX: 00B7 HEX: 00B7 }
    { HEX: 02D0 HEX: 02D0 } 
    { HEX: 02D1 HEX: 02D1 } 
    { HEX: 0387 HEX: 0387 } 
    { HEX: 0640 HEX: 0640 } 
    { HEX: 0E46 HEX: 0E46 } 
    { HEX: 0EC6 HEX: 0EC6 } 
    { HEX: 3005 HEX: 3005 } 
    { HEX: 3031 HEX: 3035 } 
    { HEX: 309D HEX: 309E } 
    { HEX: 30FC HEX: 30FE } } in-range-seq? ;

! end automatically generated code

UNION: 1.0letter base-char ideographic ;

PREDICATE: integer 1.0name-start-char
    dup 1.0letter? swap CHAR: _ = or ;

PREDICATE: integer 1.0other-name-chars
    { CHAR: . CHAR: - CHAR: _ } member? ;
UNION: 1.0name-char
    1.0letter unicode-digit 1.0other-name-chars
    combining-char extender ;
