/* Copyright (C) 2026 Factor contributors.
 * See https://factorcode.org/license.txt for BSD license. */
extern int scalar;
extern char incomplete_array[];
int ordinary(int);
template<long long N> int specialized();
template<> int specialized<4294967297LL>();
struct Named { Named(); };
struct Fields { int first; double second; };
