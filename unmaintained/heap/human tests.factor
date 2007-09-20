: test-agg2 ( -- )
    {
    } >vector
    {
      "bbbbbbb"
      "bbbbbbb"
    } >vector
    aggregate2 [ print ] each "" print

    {
      "aa"
      "aa"
    } >vector
    {
    } >vector
    aggregate2 [ print ] each "" print

    {
    } >vector
    {
    } >vector
    aggregate2 [ print ] each "" print

    {
      "aaaaaaa"
      "aaaaaaa"
      "aaaaaaa"
      "aaaaaaa"
      "aaaaaaa"
      "aaaaaaa"
    } >vector
    {
      "bbbb"
      "bbbb"
      "bbbb"
    } >vector
    aggregate2 [ print ] each "" print

    {
      "aaaa"
      "aaaa"
      "aaaa"
    } >vector
    {
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
      "bbbbbbb"
    } >vector
    aggregate2 [ print ] each "" print
    ;




: test-agg ( -- )
    {
      "....5.."
      "...|.|."
      "..7...9"
      ".|....."
      "8......"
    } >vector
    {
      "..3.."
      ".|.|."
      "4...4"
    } >vector
    {
      ".2."
      "|.|"
    } >vector
    aggregate3 [ print ] each "" print

    {
      "....5.."
      "...|.|."
      "..7...9"
      ".|....."
      "8......"
    } >vector
    {
      "......3...."
      ".....|.|..."
      "....4...4.."
      "...|.|....."
      "..5...6...."
      ".|........."
      "6.........."
    } >vector
    {
      ".2."
      "|.|"
    } >vector
    aggregate3 [ print ] each "" print
    ;