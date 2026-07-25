import json
import pathlib
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
with path.open("rb") as stream:
    data = tomllib.load(stream)

project = data.get("project", {})
scripts = project.get("scripts", {})
print(json.dumps(scripts, sort_keys=True))
