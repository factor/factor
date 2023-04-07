! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING:   accessors alien.enums cnc cnc.bit db.tuples math ;
IN: cnc.bit.local

: define-bits ( -- )
    [
        <bit>
        "Surface End Mill" >>name
        endmill enum>number >>tool_type
        straight enum>number >>bit_type
        1.0 >>diameter
        1 >>stepdown-mm
        .250 >>stepover
        1/4 >>shank  mm/min enum>number >>rate_units  3000 >>feed_rate  1500 >>plunge_rate 
        "BINSTAK" >>make  "B08SKYYN7P" >>model
        "https://www.amazon.com/gp/product/B08SKYYN7P/ref=ppx_yo_dt_b_search_asin_title" >>source 
        replace-tuple

        <bit>
        "Carving bit flat nose" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        3.175 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "/B08CD99PW" >>model "https://www.amazon.com/gp/product/B08CD99PWL" >>source
        replace-tuple

        <bit>
        "Carving bit ball nose" >>name
        +mm+ enum>number >>units
        ballnose enum>number >>tool_type
        compression enum>number >>bit_type
        3.175 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make "B08CD99PWL" >>model   "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        0.8 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.0 >>diameter
        1 >>stepdown
        1 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.2 >>diameter
        1 >>stepdown
        1.2 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.4 >>diameter
        1 >>stepdown
        1.4 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.6 >>diameter
        1 >>stepdown
        1.6 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.8 >>diameter
        1 >>stepdown
        1.8 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.8 >>diameter
        1 >>stepdown
        1.8 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        2.0 >>diameter
        1 >>stepdown
        2.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        2.5 >>diameter
        1 >>stepdown
        2.5 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
         "Downcut End Mill Sprial" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        downcut enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "HOZLY" >>make  "B073TXSLQK" >>model "https://www.amazon.com/gp/product/B073TXSLQK" >>source 
        replace-tuple

        <bit>
         "Downcut End Mill Sprial" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        downcut enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple
] with-cncdb
;
