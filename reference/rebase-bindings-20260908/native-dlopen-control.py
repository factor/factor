import ctypes
import os
from pathlib import Path

marker = Path("fixture/constructor-ran")
assert not marker.exists()
os.environ["FACTOR_FINDER_MARKER"] = str(marker.resolve())
library = ctypes.CDLL(str(Path("fixture/libfactor-rebase-probe.so.10").resolve()))
assert library.factor_finder_control() == 97
assert marker.read_text() == "loaded"
print("Native C DSO control: value 97; constructor ran only after explicit dlopen")
marker.unlink()
