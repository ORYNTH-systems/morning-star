from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parent

def load_csv(name):
    with open(ROOT / name, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))

objects = {row["ObjectID"]: row for row in load_csv("OBJECT_REGISTRY.csv")}
trials = load_csv("TRIAL_REGISTER.csv")
mutations = {row["TrialID"]: row for row in load_csv("MUTATION_REGISTER.csv")}

children = {}

for oid, obj in objects.items():
    parent = obj["DependsOn"].strip()
    if parent:
        children.setdefault(parent, []).append(oid)

def descendants(node):
    result = []
    stack = list(children.get(node, []))

    while stack:
        current = stack.pop(0)
        result.append(current)
        stack.extend(children.get(current, []))

    return result

print()
print("MS-T2 Propagation Paths")
print("=" * 50)

for trial in trials:
    trial_id = trial["TrialID"]
    source = trial["SourceObject"]
    expected = trial["DependentObject"]
    reachable = descendants(source)
    detected = expected in reachable

    print(f"{trial_id}")
    print(f"  Source              : {source}")
    print(f"  Expected dependent  : {expected}")
    print(f"  Reachable objects   : {', '.join(reachable) if reachable else '<NONE>'}")
    print(f"  Dependency confirmed: {'YES' if detected else 'NO'}")
    print(f"  Mutation class      : {mutations[trial_id]['MutationClass']}")
    print()
