from pathlib import Path
import ctypes
lib = ctypes.CDLL(str(Path(__file__).resolve().parent / 'callers.dylib'))
f = lib.incoming_split_control
f.restype = ctypes.c_double
print('Windows-target C caller -> Windows-target C va_arg reader')
print('Expected weighted sum:', sum(i*i for i in range(1, 11)))
print('Observed:', f())
