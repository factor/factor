namespace factor
{

/* Some functions for converting floating point numbers to binary
representations and vice versa */

union double_bits_pun {
    double x;
    u64 y;
};

inline static u64 double_bits(double x)
{
	double_bits_pun b;
	b.x = x;
	return b.y;
}

inline static double bits_double(u64 y)
{
	double_bits_pun b;
	b.y = y;
	return b.x;
}

union float_bits_pun {
    float x;
    u32 y;
};

inline static u32 float_bits(float x)
{
	float_bits_pun b;
	b.x = x;
	return b.y;
}

inline static float bits_float(u32 y)
{
	float_bits_pun b;
	b.y = y;
	return b.x;
}

}
