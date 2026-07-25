import importlib
import json
import pathlib
import sys

module = importlib.import_module(sys.argv[1])
output = pathlib.Path(sys.argv[2])
config = module.load_runtime_config()
output.write_text(
    json.dumps(config, sort_keys=True, separators=(",", ":")),
    encoding="utf-8",
)
