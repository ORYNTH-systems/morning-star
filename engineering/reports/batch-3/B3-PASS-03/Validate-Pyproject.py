import pathlib
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8-sig")
data = tomllib.loads(text)

scripts = data.get("project", {}).get("scripts", {})
expected = sys.argv[2]

if expected not in scripts.values():
    raise SystemExit(4)
