import pathlib, subprocess, sys
root=pathlib.Path(__file__).resolve().parent
for stage in ['bootstrap','load-all','help-lint','test-all']:
 result=subprocess.run([sys.executable,str(root/'run-stage.py'),stage])
 if result.returncode: raise SystemExit(result.returncode)
