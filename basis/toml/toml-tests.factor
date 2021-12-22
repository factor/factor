USING: multiline toml tools.test ;

{
    H{
        { "title" "TOML Example" }
        { "hosts" { "alpha" "omega" } }
        {
            "owner"
            H{
                { "name" "Tom Preston-Werner" }
                { "organization" "GitHub" }
                {
                    "bio"
                    "GitHub Cofounder & CEO\nLikes tater tots and beer."
                }
                { "dob" "1979-05-27T07:32:00Z" }
            }
        }
        {
            "database"
            H{
                { "server" "192.168.1.1" }
                { "ports" { 8001 8001 8002 } }
                { "connection_max" 5000 }
                { "enabled" t }
            }
        }
        {
            "servers"
            H{
                {
                    "alpha"
                    H{
                        { "ip" "10.0.0.1" }
                        { "dc" "eqdc10" }
                    }
                }
                {
                    "beta"
                    H{
                        { "ip" "10.0.0.2" }
                        { "dc" "eqdc10" }
                        { "country" "中国" }
                    }
                }
            }
        }
        {
            "clients"
            H{
                { "data" { { "gamma" "delta" } { 1 2 } } }
            }
        }
        {
            "products"
            V{
                H{
                    { "name" "Hammer" }
                    { "sku" 738594937 }
                }
                H{
                    { "name" "Nail" }
                    { "sku" 284758393 }
                    { "color" "gray" }
                }
            }
        }
    }
} [
    [=[

# This is a TOML document. Boom.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z # First class dates? Why not?

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # You can indent as you please. Tabs or spaces. TOML don't care.
  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"
  country = "中国" # This should be parsed as UTF-8

[clients]
data = [ ["gamma", "delta"], [1, 2] ] # just an update to make sure parsers support it

# Line breaks are OK when inside arrays
hosts = [
  "alpha",
  "omega"
]

# Products

  [[products]]
  name = "Hammer"
  sku = 738594937

  [[products]]
  name = "Nail"
  sku = 284758393
  color = "gray"

    ]=] toml>
] unit-test

{
    H{
        { "deps" H{
            { "temp_targets" H{ { "case" 72.0 } } } }
        }
    }
} [
    "[deps]
    temp_targets = { case = 72.0 }" toml>
] unit-test
