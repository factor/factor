USING: bare multiline prettyprint prettyprint.config tools.test ;

! uint

{ 0 } [ B{ 0x00 } uint bare> ] unit-test
{ B{ 0x00 } } [ 0 uint >bare ] unit-test

{ 1 } [ B{ 0x01 } uint bare> ] unit-test
{ B{ 0x01 } } [ 1 uint >bare ] unit-test

{ 126 } [ B{ 0x7e } uint bare> ] unit-test
{ B{ 0x7e } } [ 126 uint >bare ] unit-test

{ 127 } [ B{ 0x7f } uint bare> ] unit-test
{ B{ 0x7f } } [ 127 uint >bare ] unit-test

{ 128 } [ B{ 0x80 0x01 } uint bare> ] unit-test
{ B{ 0x80 0x01 } } [ 128 uint >bare ] unit-test

{ 129 } [ B{ 0x81 0x01 } uint bare> ] unit-test
{ B{ 0x81 0x01 } } [ 129 uint >bare ] unit-test

{ 255 } [ B{ 0xFF 0x01 } uint bare> ] unit-test
{ B{ 0xFF 0x01 } } [ 255 uint >bare ] unit-test

! int

{ 0 } [ B{ 0x00 } int bare> ] unit-test
{ B{ 0x00 } } [ 0 int >bare ] unit-test

{ 1 } [ B{ 0x02 } int bare> ] unit-test
{ B{ 0x02 } } [ 1 int >bare ] unit-test

{ -1 } [ B{ 0x01 } int bare> ] unit-test
{ B{ 0x01 } } [ -1 int >bare ] unit-test

{ 63 } [ B{ 0x7e } int bare> ] unit-test
{ B{ 0x7e } } [ 63 int >bare ] unit-test

{ -63 } [ B{ 0x7d } int bare> ] unit-test
{ B{ 0x7d } } [ -63 int >bare ] unit-test

{ 64 } [ B{ 0x80 0x01 } int bare> ] unit-test
{ B{ 0x80 0x01 } } [ 64 int >bare ] unit-test

{ -64 } [ B{ 0x7f } int bare> ] unit-test
{ B{ 0x7f } } [ -64 int >bare ] unit-test

{ 65 } [ B{ 0x82 0x01 } int bare> ] unit-test
{ B{ 0x82 0x01 } } [ 65 int >bare ] unit-test

{ -65 } [ B{ 0x81 0x01 } int bare> ] unit-test
{ B{ 0x81 0x01 } } [ -65 int >bare ] unit-test

{ 255 } [ B{ 0xFE 0x03 } int bare> ] unit-test
{ B{ 0xFE 0x03 } } [ 255 int >bare ] unit-test

{ -255 } [ B{ 0xFD 0x03 } int bare> ] unit-test
{ B{ 0xFD 0x03 } } [ -255 int >bare ] unit-test

! u32

{ 0 } [ B{ 0x00 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 } } [ 0 u32 >bare ] unit-test

{ 1 } [ B{ 0x01 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0x01 0x00 0x00 0x00 } } [ 1 u32 >bare ] unit-test

{ 255 } [ B{ 0xFF 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0xFF 0x00 0x00 0x00 } } [ 255 u32 >bare ] unit-test

! i16

{ 0 } [ B{ 0x00 0x00 } i16 bare> ] unit-test
{ B{ 0x00 0x00 } } [ 0 i16 >bare ] unit-test

{ 1 } [ B{ 0x01 0x00 } i16 bare> ] unit-test
{ B{ 0x01 0x00 } } [ 1 i16 >bare ] unit-test

{ -1 } [ B{ 0xFF 0xFF } i16 bare> ] unit-test
{ B{ 0xFF 0xFF } } [ -1 i16 >bare ] unit-test

{ 255 } [ B{ 0xFF 0x00 } i16 bare> ] unit-test
{ B{ 0xFF 0x00 } } [ 255 i16 >bare ] unit-test

{ -255 } [ B{ 0x01 0xFF } i16 bare> ] unit-test
{ B{ 0x01 0xFF } } [ -255 i16 >bare ] unit-test

! f64

{ 0.0 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } } [ 0.0 f64 >bare ] unit-test

{ 1.0 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0xF0 0x3F } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0xF0 0x3F } } [ 1.0 f64 >bare ] unit-test

{ 2.55 } [ B{ 0x66 0x66 0x66 0x66 0x66 0x66 0x04 0x40 } f64 bare> ] unit-test
{ B{ 0x66 0x66 0x66 0x66 0x66 0x66 0x04 0x40 } } [ 2.55 f64 >bare ] unit-test

{ -25.5 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x80 0x39 0xC0 } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x80 0x39 0xC0 } } [ -25.5 f64 >bare ] unit-test

! bool

{ t } [ B{ 0x01 } bool bare> ] unit-test
{ B{ 0x01 } } [ t bool >bare ] unit-test

{ f } [ B{ 0x00 } bool bare> ] unit-test
{ B{ 0x00 } } [ f bool >bare ] unit-test

! str

{ "BARE" } [ B{ 0x04 0x42 0x41 0x52 0x45 } str bare> ] unit-test
{ B{ 0x04 0x42 0x41 0x52 0x45 } } [ "BARE" str >bare ] unit-test

! data

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0x10 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data } bare>
] unit-test

{ B{ 0x10 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data } >bare
] unit-test

! data[length]

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data f 16 } bare>
] unit-test

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data f 16 } >bare
] unit-test

! optional<u32>

{ f } [ B{ 0x00 } T{ optional f u32 } bare> ] unit-test
{ 0 } [ B{ 0x01 0x00 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test
{ 1 } [ B{ 0x01 0x01 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test
{ 255 } [ B{ 0x01 0xFF 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test

! list<str>

{ { "foo" "bar" "buzz" } } [
    B{ 0x03 0x03 0x66 0x6f 0x6f 0x03 0x62 0x61 0x72 0x04 0x62 0x75 0x7A 0x7A }
    T{ list f str f } bare>
] unit-test

{ B{ 0x03 0x03 0x66 0x6f 0x6f 0x03 0x62 0x61 0x72 0x04 0x62 0x75 0x7A 0x7A } } [
    { "foo" "bar" "buzz" } T{ list f str f } >bare
] unit-test

! list<uint>[10]

{ { 0 1 254 255 256 257 126 127 128 129 } } [
    B{ 0x00 0x01 0xFE 0x01 0xFF 0x01 0x80 0x02 0x81 0x02 0x7E 0x7F 0x80 0x01 0x81 0x01 }
    T{ list f uint 10 } bare>
] unit-test

{ B{ 0x00 0x01 0xFE 0x01 0xFF 0x01 0x80 0x02 0x81 0x02 0x7E 0x7F 0x80 0x01 0x81 0x01 } } [
    { 0 1 254 255 256 257 126 127 128 129 } T{ list f uint 10 } >bare
] unit-test

! user types / schema

{
    [=[ T{ schema
    { types
        V{
            T{ user
                { name "PublicKey" }
                { type T{ data { length 128 } } }
            }
            T{ user { name "Time" } { type str } }
            T{ user
                { name "Department" }
                { type
                    T{ enum
                        { values
                            V{
                                { "ACCOUNTING" 0 }
                                { "ADMINISTRATION" 1 }
                                { "CUSTOMER_SERVICE" 2 }
                                { "DEVELOPMENT" 3 }
                                { "JSMITH" 99 }
                            }
                        }
                    }
                }
            }
            T{ user
                { name "Address" }
                { type T{ list { type str } { length 4 } } }
            }
            T{ user
                { name "Customer" }
                { type
                    T{ struct
                        { fields
                            V{
                                { "name" str }
                                { "email" str }
                                {
                                    "address"
                                    T{ user
                                        { name "Address" }
                                        { type
                                            T{ list
                                                { type str }
                                                { length 4 }
                                            }
                                        }
                                    }
                                }
                                {
                                    "orders"
                                    T{ list
                                        { type
                                            T{ struct
                                                { fields
                                                    V{
                                                        {
                                                            "orderId"
                                                            i64
                                                        }
                                                        {
                                                            "quantity"
                                                            i32
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                {
                                    "metadata"
                                    T{ map
                                        { from str }
                                        { to T{ data } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            T{ user
                { name "Employee" }
                { type
                    T{ struct
                        { fields
                            V{
                                { "name" str }
                                { "email" str }
                                {
                                    "address"
                                    T{ user
                                        { name "Address" }
                                        { type
                                            T{ list
                                                { type str }
                                                { length 4 }
                                            }
                                        }
                                    }
                                }
                                {
                                    "department"
                                    T{ user
                                        { name "Department" }
                                        { type
                                            T{ enum
                                                { values
                                                    V{
                                                        {
                                                            "ACCOUNTING"
                                                            0
                                                        }
                                                        {
                                                            "ADMINISTRATION"
                                                            1
                                                        }
                                                        {
                                                            "CUSTOMER_SERVICE"
                                                            2
                                                        }
                                                        {
                                                            "DEVELOPMENT"
                                                            3
                                                        }
                                                        {
                                                            "JSMITH"
                                                            99
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                {
                                    "hireDate"
                                    T{ user
                                        { name "Time" }
                                        { type str }
                                    }
                                }
                                {
                                    "publicKey"
                                    T{ optional
                                        { type
                                            T{ user
                                                { name
                                                    "PublicKey"
                                                }
                                                { type
                                                    T{ data
                                                        { length
                                                            128
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                {
                                    "metadata"
                                    T{ map
                                        { from str }
                                        { to T{ data } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            T{ user
                { name "TerminatedEmployee" }
                { type void }
            }
            T{ user
                { name "Person" }
                { type
                    T{ union
                        { members
                            V{
                                {
                                    T{ user
                                        { name "Customer" }
                                        { type
                                            T{ struct
                                                { fields
                                                    V{
                                                        {
                                                            "name"
                                                            str
                                                        }
                                                        {
                                                            "email"
                                                            str
                                                        }
                                                        {
                                                            "address"
                                                            T{
                                                            user
                                                                {
                                                                name
                                                                    "Address"
                                                                }
                                                                {
                                                                type
                                                                    T{
                                                                    list
                                                                        {
                                                                        type
                                                                            str
                                                                        }
                                                                        {
                                                                        length
                                                                            4
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "orders"
                                                            T{
                                                            list
                                                                {
                                                                type
                                                                    T{
                                                                    struct
                                                                        {
                                                                        fields
                                                                            V{
                                                                                {
                                                                                    "orderId"
                                                                                    i64
                                                                                }
                                                                                {
                                                                                    "quantity"
                                                                                    i32
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "metadata"
                                                            T{
                                                            map
                                                                {
                                                                from
                                                                    str
                                                                }
                                                                {
                                                                to
                                                                    T{
                                                                    data
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    0
                                }
                                {
                                    T{ user
                                        { name "Employee" }
                                        { type
                                            T{ struct
                                                { fields
                                                    V{
                                                        {
                                                            "name"
                                                            str
                                                        }
                                                        {
                                                            "email"
                                                            str
                                                        }
                                                        {
                                                            "address"
                                                            T{
                                                            user
                                                                {
                                                                name
                                                                    "Address"
                                                                }
                                                                {
                                                                type
                                                                    T{
                                                                    list
                                                                        {
                                                                        type
                                                                            str
                                                                        }
                                                                        {
                                                                        length
                                                                            4
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "department"
                                                            T{
                                                            user
                                                                {
                                                                name
                                                                    "Department"
                                                                }
                                                                {
                                                                type
                                                                    T{
                                                                    enum
                                                                        {
                                                                        values
                                                                            V{
                                                                                {
                                                                                    "ACCOUNTING"
                                                                                    0
                                                                                }
                                                                                {
                                                                                    "ADMINISTRATION"
                                                                                    1
                                                                                }
                                                                                {
                                                                                    "CUSTOMER_SERVICE"
                                                                                    2
                                                                                }
                                                                                {
                                                                                    "DEVELOPMENT"
                                                                                    3
                                                                                }
                                                                                {
                                                                                    "JSMITH"
                                                                                    99
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "hireDate"
                                                            T{
                                                            user
                                                                {
                                                                name
                                                                    "Time"
                                                                }
                                                                {
                                                                type
                                                                    str
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "publicKey"
                                                            T{
                                                            optional
                                                                {
                                                                type
                                                                    T{
                                                                    user
                                                                        {
                                                                        name
                                                                            "PublicKey"
                                                                        }
                                                                        {
                                                                        type
                                                                            T{
                                                                            data
                                                                                {
                                                                                length
                                                                                    128
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        {
                                                            "metadata"
                                                            T{
                                                            map
                                                                {
                                                                from
                                                                    str
                                                                }
                                                                {
                                                                to
                                                                    T{
                                                                    data
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    1
                                }
                                {
                                    T{ user
                                        { name
                                            "TerminatedEmployee"
                                        }
                                        { type void }
                                    }
                                    2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}]=]
} [
    [=[ type PublicKey data[128]
type Time str # ISO 8601

type Department enum {
  ACCOUNTING
  ADMINISTRATION
  CUSTOMER_SERVICE
  DEVELOPMENT

  # Reserved for the CEO
  JSMITH = 99
}

type Address list<str>[4] # street, city, state, country

type Customer struct {
  name: str
  email: str
  address: Address
  orders: list<struct {
    orderId: i64
    quantity: i32
  }>
  metadata: map<str><data>
}

type Employee struct {
  name: str
  email: str
  address: Address
  department: Department
  hireDate: Time
  publicKey: optional<PublicKey>
  metadata: map<str><data>
}

type TerminatedEmployee void

type Person union {Customer | Employee | TerminatedEmployee}
]=] parse-schema [ unparse ] without-limits
] unit-test
