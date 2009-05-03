#include "master.hpp"


template <typename T> struct blah {
	const T *x_;
	blah(T *x) : x_(x) {}

	blah& operator=(const T *x) { x_ = x; }
};

CELL test()
{
	int x = 100;
	blah<int> u(&x);
	u = &x;
}
