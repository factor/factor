namespace Namespace {
    int namespaced(int x, int y) { return x + y; }
}

double toplevel(double x, double y) { return x + y; }
double toplevel(double x, double y, double z) { return x + y + z; }

class Class
{
    unsigned x;

    Class();
    Class(unsigned _x);

    unsigned member(unsigned y);
    unsigned member(unsigned y) const;

    unsigned static_member(unsigned x, unsigned y);
};

Class::Class() : x(42) { }
Class::Class(unsigned _x) : x(_x) { }
unsigned Class::member(unsigned y) { return x += y; }
unsigned Class::member(unsigned y) const { return x + y; }
unsigned Class::static_member(unsigned x, unsigned y) { return Class(x).member(y); }

template<typename T>
T templated(T x, T y) { return x + y; }

template int templated<int>(int x, int y);
template double templated<double>(double x, double y);
