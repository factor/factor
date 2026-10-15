// Factor's collectors use C++ exceptions to restart collection.
extern "C" int m88k_cxx17_exceptions(int value) {
    try {
        if (value) throw value;
        return 0;
    } catch (int result) {
        return result;
    }
}
