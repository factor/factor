namespace factor
{

/* Some functions for converting floating point numbers to binary
representations and vice versa */

typedef union {
    double x;
    u64 y;
} F_DOUBLE_BITS;

inline static u64 double_bits(double x)
{
	F_DOUBLE_BITS b;
	b.x = x;
	return b.y;
}

inline static double bits_double(u64 y)
{
	F_DOUBLE_BITS b;
	b.y = y;
	return b.x;
}

typedef union {
    float x;
    u32 y;
} F_FLOAT_BITS;

inline static u32 float_bits(float x)
{
	F_FLOAT_BITS b;
	b.x = x;
	return b.y;
}

inline static float bits_float(u32 y)
{
	F_FLOAT_BITS b;
	b.y = y;
	return b.x;
}

}
