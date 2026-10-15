/* Copyright (C) 2026 Doug Coleman. BSD license. */
double leading(double a,double b,int c,int d,int e){return a+b+c+d+e;}
double call_leading(double (*cb)(double,double,int,int,int)){return cb(2.5,4.5,3,4,5);}
