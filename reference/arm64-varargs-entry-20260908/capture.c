/* Independent native caller: its prototype defines the incoming registers. */
typedef long (*capture_callback)(long, long, long, long, long, long, long, long,
                                 double, double, double, double,
                                 double, double, double, double);
long call_capture(capture_callback callback) {
  return callback(11, 22, 33, 44, 55, 66, 77, 88,
                  1.25, 2.25, 3.25, 4.25, 5.25, 6.25, 7.25, 8.25);
}
