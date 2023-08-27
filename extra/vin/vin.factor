! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs combinators combinators.short-circuit kernel make
math sequences strings ;

IN: vin

<PRIVATE

CONSTANT: TRANSLITERATION H{ }

"0123456789" [ swap TRANSLITERATION set-at ] each-index
"ABCDEFGH" [ 1 + swap TRANSLITERATION set-at ] each-index
"JKLMNOPQR" [ 1 + swap TRANSLITERATION set-at ] each-index
"STUVWXYZ" [ 2 + swap TRANSLITERATION set-at ] each-index
CHAR: O TRANSLITERATION delete-at
CHAR: Q TRANSLITERATION delete-at

CONSTANT: WEIGHTS { 8 7 6 5 4 3 2 10 0 9 8 7 6 5 4 3 2 }

PRIVATE>

: valid-vin? ( vin -- ? )
    {
        [ length 17 = ]
        [ [ "ABCDEFGHJKLMNPRSTUVWXYZ0123456789" member? ] all? ]
        [
            [ 8 swap nth ]
            [ WEIGHTS swap 0 [ TRANSLITERATION at * + ] 2reduce 11 mod ] bi
            dup 10 = [ drop CHAR: X = ] [ CHAR: 0 + = ] if
        ]
    } 1&& ;

<PRIVATE

CONSTANT: MANUFACTURERS H{
    { "AFA" "Ford South Africa" }
    { "AAV" "Volkswagen South Africa" }
    { "JA3" "Mitsubishi" }
    { "JHM" "Honda" }
    { "JHG" "Honda" }
    { "JHL" "Honda" }
    { "KM8" "Hyundai" }
    { "KMH" "Hyundai" }
    { "KNA" "Kia" }
    { "KNB" "Kia" }
    { "KNC" "Kia" }
    { "KNM" "Renault Samsung" }
    { "KPA" "Ssangyong" }
    { "KPT" "Ssangyong" }
    { "L56" "Renault Samsung" }
    { "L5Y" "Merato Motorcycle Taizhou Zhongneng" }
    { "LDY" "Zhongtong Coach, China" }
    { "LGH" "Dong Feng (DFM), China" }
    { "LKL" "Suzhou King Long, China" }
    { "LSY" "Brilliance Zhonghua" }
    { "LTV" "Toyota Tian Jin" }
    { "LVS" "Ford Chang An" }
    { "LVV" "Chery, China" }
    { "LZM" "MAN China" }
    { "LZE" "Isuzu Guangzhou, China" }
    { "LZG" "Shaanxi Automobile Group, China" }
    { "LZY" "Yutong Zhengzhou, China" }
    { "MA1" "Mahindra" }
    { "MA3" "Suzuki India" }
    { "MA7" "Honda Siel Cars India" }
    { "MAL" "Hyundai" }
    { "MC2" "Volvo Eicher commercial vehicles limited." }
    { "MHR" "Honda Indonesia" }
    { "MNB" "Ford Thailand" }
    { "MNT" "Nissan Thailand" }
    { "MMB" "Mitsubishi Thailand" }
    { "MMM" "Chevrolet Thailand" }
    { "MMT" "Mitsubishi Thailand" }
    { "MM8" "Mazda Thailand" }
    { "MPA" "Isuzu Thailand" }
    { "MP1" "Isuzu Thailand" }
    { "MRH" "Honda Thailand" }
    { "MR0" "Toyota Thailand" }
    { "NLE" "Mercedes-Benz Turk Truck" }
    { "NM0" "Ford Turkey" }
    { "NM4" "Tofas Turk" }
    { "NMT" "Toyota Turkiye" }
    { "PE1" "Ford Phillipines" }
    { "PE3" "Mazda Phillipines" }
    { "PL1" "Proton, Malaysia" }
    { "SAL" "Land Rover" }
    { "SAJ" "Jaguar" }
    { "SAR" "Rover" }
    { "SCA" "Rolls Royce" }
    { "SCC" "Lotus Cars" }
    { "SCE" "DeLorean Motor Cars N. Ireland (UK)" }
    { "SCF" "Aston" }
    { "SDB" "Peugeot UK" }
    { "SFD" "Alexander Dennis UK" }
    { "SHS" "Honda UK" }
    { "SJN" "Nissan UK" }
    { "SU9" "Solaris Bus & Coach (Poland)" }
    { "TK9" "SOR (Czech Republic)" }
    { "TDM" "QUANTYA Swiss Electric Movement (Switzerland)" }
    { "TMB" "Škoda (Czech Republic)" }
    { "TMK" "Karosa (Czech Republic)" }
    { "TMP" "Škoda trolleybuses (Czech Republic)" }
    { "TMT" "Tatra (Czech Republic)" }
    { "TM9" "Škoda trolleybuses (Czech Republic)" }
    { "TN9" "Karosa (Czech Republic)" }
    { "TRA" "Ikarus Bus" }
    { "TRU" "Audi Hungary" }
    { "TSE" "Ikarus Egyedi Autobuszgyar, (Hungary)" }
    { "TSM" "Suzuki, (Hungary)" }
    { "UU1" "Renault Dacia, (Romania)" }
    { "VF1" "Renault" }
    { "VF3" "Peugeot" }
    { "VF6" "Renault (Trucks & Buses)" }
    { "VF7" "Citroën" }
    { "VF8" "Matra" }
    { "VLU" "Scania France" }
    { "VNE" "Irisbus (France)" }
    { "VSE" "Suzuki Spain (Santana Motors)" }
    { "VSK" "Nissan Spain" }
    { "VSS" "SEAT" }
    { "VSX" "Opel Spain" }
    { "VS6" "Ford Spain" }
    { "VS9" "Carrocerias Ayats (Spain)" }
    { "VV9" "TAUROSpain" }
    { "VWV" "Volkswagen Spain" }
    { "VX1" "Zastava / Yugo Serbia" }
    { "WAG" "Neoplan" }
    { "WAU" "Audi" }
    { "WBA" "BMW" }
    { "WBS" "BMW M" }
    { "WDB" "Mercedes-Benz" }
    { "WDC" "DaimlerChrysler" }
    { "WDD" "McLaren" }
    { "WEB" "Evobus GmbH (Mercedes-Bus)" }
    { "WF0" "Ford Germany" }
    { "WMA" "MAN Germany" }
    { "WMW" "MINI" }
    { "WP0" "Porsche" }
    { "W0L" "Opel" }
    { "WVW" "Volkswagen" }
    { "WV1" "Volkswagen Commercial Vehicles" }
    { "WV2" "Volkswagen Bus/Van" }
    { "XL9" "Spyker" }
    { "XMC" "Mitsubishi (NedCar)" }
    { "XTA" "Lada/AutoVaz (Russia)" }
    { "YK1" "Saab" }
    { "YS2" "Scania AB" }
    { "YS3" "Saab" }
    { "YS4" "Scania Bus" }
    { "YV1" "Volvo Cars" }
    { "YV4" "Volvo Cars" }
    { "YV2" "Volvo Trucks" }
    { "YV3" "Volvo Buses" }
    { "ZAM" "Maserati Biturbo" }
    { "ZAP" "Piaggio/Vespa/Gilera" }
    { "ZAR" "Alfa Romeo" }
    { "ZCG" "Cagiva SpA" }
    { "ZDM" "Ducati Motor Holdings SpA" }
    { "ZDF" "Ferrari Dino" }
    { "ZD4" "Aprilia" }
    { "ZFA" "Fiat" }
    { "ZFC" "Fiat V.I." }
    { "ZFF" "Ferrari" }
    { "ZHW" "Lamborghini" }
    { "ZLA" "Lancia" }
    { "ZOM" "OM" }
    { "1C3" "Chrysler" }
    { "1C6" "Chrysler" }
    { "1D3" "Dodge" }
    { "1FA" "Ford Motor Company" }
    { "1FB" "Ford Motor Company" }
    { "1FC" "Ford Motor Company" }
    { "1FD" "Ford Motor Company" }
    { "1FM" "Ford Motor Company" }
    { "1FT" "Ford Motor Company" }
    { "1FU" "Freightliner" }
    { "1FV" "Freightliner" }
    { "1F9" "FWD Corp." }
    { "1GC" "Chevrolet Truck USA" }
    { "1GT" "GMC Truck USA" }
    { "1G1" "Chevrolet USA" }
    { "1G2" "Pontiac USA" }
    { "1G3" "Oldsmobile USA" }
    { "1G4" "Buick USA" }
    { "1G6" "Cadillac USA" }
    { "1GM" "Pontiac USA" }
    { "1G8" "Saturn USA" }
    { "1HD" "Harley-Davidson" }
    { "1J4" "Jeep" }
    { "1ME" "Mercury USA" }
    { "1M1" "Mack Truck USA" }
    { "1M2" "Mack Truck USA" }
    { "1M3" "Mack Truck USA" }
    { "1M4" "Mack Truck USA" }
    { "1M9" "Mynatt Truck & Equipment" }
    { "1NX" "NUMMI USA" }
    { "1P3" "Plymouth USA" }
    { "1R9" "Roadrunner Hay Squeeze USA" }
    { "1VW" "Volkswagen USA" }
    { "1XK" "Kenworth USA" }
    { "1XP" "Peterbilt USA" }
    { "1YV" "Mazda USA (AutoAlliance International)" }
    { "2C3" "Chrysler Canada" }
    { "2CN" "CAMI" }
    { "2D3" "Dodge Canada" }
    { "2FA" "Ford Motor Company Canada" }
    { "2FB" "Ford Motor Company Canada" }
    { "2FC" "Ford Motor Company Canada" }
    { "2FM" "Ford Motor Company Canada" }
    { "2FT" "Ford Motor Company Canada" }
    { "2FU" "Freightliner" }
    { "2FV" "Freightliner" }
    { "2FZ" "Sterling" }
    { "2G1" "Chevrolet Canada" }
    { "2G2" "Pontiac Canada" }
    { "2G3" "Oldsmobile Canada" }
    { "2G4" "Buick Canada" }
    { "2HG" "Honda Canada" }
    { "2HK" "Honda Canada" }
    { "2HM" "Hyundai Canada" }
    { "2NV" "Nova Bus Canada" }
    { "2P3" "Plymouth Canada" }
    { "2V4" "Volkswagen Canada" }
    { "2WK" "Western Star" }
    { "2WL" "Western Star" }
    { "2WM" "Western Star" }
    { "3D3" "Dodge Mexico" }
    { "3FA" "Ford Motor Company Mexico" }
    { "3FE" "Ford Motor Company Mexico" }
    { "3P3" "Plymouth Mexico" }
    { "3VW" "Volkswagen Mexico" }
    { "4RK" "Nova Bus USA" }
    { "4US" "BMW USA" }
    { "4UZ" "Frt-Thomas Bus" }
    { "4V1" "Volvo" }
    { "4V2" "Volvo" }
    { "4V3" "Volvo" }
    { "4V4" "Volvo" }
    { "4V5" "Volvo" }
    { "4V6" "Volvo" }
    { "4VL" "Volvo" }
    { "4VM" "Volvo" }
    { "4VZ" "Volvo" }
    { "5N1" "Nissan USA" }
    { "5NP" "Hyundai USA" }
    { "6AB" "MAN Australia" }
    { "6F4" "Nissan Motor Company Australia" }
    { "6F5" "Kenworth Australia" }
    { "6FP" "Ford Motor Company Australia" }
    { "6G1" "General Motors-Holden (post Nov 2002)" }
    { "6G2" "Pontiac Australia (GTO & G8)" }
    { "6H8" "General Motors-Holden (pre Nov 2002)" }
    { "6MM" "Mitsubishi Motors Australia" }
    { "6T1" "Toyota Motor Corporation Australia" }
    { "6U9" "Privately Imported car in Australia" }
    { "8AG" "Chevrolet Argentina" }
    { "8GG" "Chevrolet Chile" }
    { "8AP" "Fiat Argentina" }
    { "8AF" "Ford Motor Company Argentina" }
    { "8AD" "Peugeot Argentina" }
    { "8GD" "Peugeot Chile" }
    { "8A1" "Renault Argentina" }
    { "8AK" "Suzuki Argentina" }
    { "8AJ" "Toyota Argentina" }
    { "8AW" "Volkswagen Argentina" }
    { "93U" "Audi Brazil" }
    { "9BG" "Chevrolet Brazil" }
    { "935" "Citroën Brazil" }
    { "9BD" "Fiat Brazil" }
    { "9BF" "Ford Motor Company Brazil" }
    { "93H" "Honda Brazil" }
    { "9BM" "Mercedes-Benz Brazil" }
    { "936" "Peugeot Brazil" }
    { "93Y" "Renault Brazil" }
    { "9BS" "Scania Brazil" }
    { "93R" "Toyota Brazil" }
    { "9BW" "Volkswagen Brazil" }
    { "9FB" "Renault Colombia" }
}

H{
    { "JA" "Isuzu" }
    { "JF" "Fuji Heavy Industries" }
    { "JK" "Kawasaki" }
    { "JM" "Mazda" }
    { "JN" "Nissan" }
    { "JS" "Suzuki" }
    { "JT" "Toyota" }
    { "KL" "Daewoo General Motors South Korea" }
    { "1G" "General Motors USA" }
    { "1H" "Honda USA" }
    { "1L" "Lincoln USA" }
    { "1N" "Nissan USA" }
    { "2G" "General Motors Canada" }
    { "2M" "Mercury" }
    { "2T" "Toyota Canada" }
    { "3G" "General Motors Mexico" }
    { "3H" "Honda Mexico" }
    { "3N" "Nissan Mexico" }
    { "4F" "Mazda USA" }
    { "4M" "Mercury" }
    { "4S" "Subaru-Isuzu Automotive" }
    { "4T" "Toyota" }
    { "5F" "Honda USA-Alabama" }
    { "5L" "Lincoln" }
    { "5T" "Toyota USA - trucks" }
} [
    swap "ABCDEFGHJKLMNPRSTUVWXYZ1234567890"
    [ suffix MANUFACTURERS set-at ] 2with each
] assoc-each

CONSTANT: REGIONS H{ }

{
    { "12345" "North America" }
    { "STUVWXYZ" "Europe" }
    { "ABCDEFGH" "Africa" }
    { "JKLMNPR" "Asia" }
    { "67" "Oceania" }
    { "890" "South America" }
} [
    swap [ REGIONS set-at ] with each
] assoc-each

CONSTANT: COUNTRIES H{ }

{
    { "South Africa" "A" "ABCDEFGH" }
    { "Japan" "J" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "South Korea" "K" "LMNPR" }
    { "China" "L" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "India" "M" "ABCDE" }
    { "Indonesia" "M" "FGHJK" }
    { "Thailand" "M" "LMNPR" }
    { "Philippines" "P" "ABCDE" }
    { "Malaysia" "P" "LMNPR" }
    { "Taiwan" "R" "FG" }
    { "United Kingdom" "A" "ABCDEFGHJKLM" }
    { "Germany" "S" "NPRST" }
    { "Germany" "W" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "Poland" "S" "UVWXYZ" }
    { "Switzerland" "T" "ABCDEFGH" }
    { "Czech Republic" "T" "JKLMNP" }
    { "Hungary" "T" "RSTUV" }
    { "Portugal" "T" "W" }
    { "Austria" "V" "ABCDE" }
    { "France" "V" "FGHJKLMNPR" }
    { "Spain" "V" "STUVW" }
    { "Yugoslavia" "V" "XYZ12" }
    { "Netherlands" "X" "LMN" }
    { "USSR" "X" "STUVW" }
    { "Russia" "X" "34567890" }
    { "Belgium" "Y" "ABCDE" }
    { "Finland" "Y" "FGHJK" }
    { "Sweden" "Y" "STUVW" }
    { "Italy" "Z" "ABCDEFGHJKLMNPR" }
    { "United States" "1" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "United States" "4" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "United States" "5" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "Canada" "2" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "Mexico" "3" "ABCDEFGHJKLMNPRSTUVWXYZ1234567890" }
    { "Australia" "6" "ABCDEFGHJKLMNPRSTUVW" }
    { "New Zealand" "7" "ABCDE" }
    { "Argentina" "8" "ABCDE" }
    { "Chile" "8" "FGHJ" }
    { "Venezuela" "8" "XYZ12" }
    { "Brazil" "9" "ABCDE" }
    { "Brazil" "9" "3456789" }
    { "Columbia" "9" "FGHJ" }
} [
    first3 [ suffix COUNTRIES set-at ] 2with each
] each

: wmi% ( wmi -- )
    {
        [ "wmi" ,, ]
        [ MANUFACTURERS at "manufacturer" ,, ]
        [ first REGIONS at "region" ,, ]
        [ 2 head COUNTRIES at "country" ,, ]
    } cleave ;

: vds% ( vds -- )
    {
        [ "vds" ,, ]
    } cleave ;

: vis% ( vis -- )
    {
        [ "vis" ,, ]
        [ first "123456789ABCDEFGHJKLMNPRSTVWXY" index [ 2001 + "year" ,, ] when* ]
        [ second 1string "assembly_plant" ,, ]
    } cleave ;

PRIVATE>

: parse-vin ( vin -- details )
    [
        {
            [ [ 0 3 ] dip subseq wmi% ]
            [ [ 3 9 ] dip subseq vds% ]
            [ [ 9 17 ] dip subseq vis% ]
        } cleave
    ] H{ } make ;
