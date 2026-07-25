import importlib
import json
import pathlib
import sys

module_name = sys.argv[1]
output_path = pathlib.Path(sys.argv[2])
module = importlib.import_module(module_name)

config = module.load_runtime_config()
logger = module.configure_logging(config)

results = {
    "success": module.execute_with_boundary(lambda: None),
    "integer": module.execute_with_boundary(lambda: 4),
    "invalid_input": module.execute_with_boundary(
        lambda: (_ for _ in ()).throw(ValueError("invalid"))
    ),
    "operational_error": module.execute_with_boundary(
        lambda: (_ for _ in ()).throw(RuntimeError("failure"))
    ),
    "logger_name": logger.name,
    "schema_version": config["schema_version"],
}

output_path.write_text(
    json.dumps(results, sort_keys=True, indent=2),
    encoding="utf-8",
)
