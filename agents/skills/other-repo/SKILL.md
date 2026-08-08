---
name: other-repo
description: >
  Read other local repositories beside the current git repo as read-only
  context for cross-repo work. Use for shared types, APIs, schemas, SDKs,
  generated clients, env vars, feature flags, and contract alignment across
  repos. Trigger when another local repo may exist at ../repo-name. Do not use
  for remote-only or current-repo-only tasks.
---

# Other Repo

Treat other local repos as read-only extensions of the current workspace.

## Workspace

```zsh
repo_root=$(git rev-parse --show-toplevel)
parent_dir=$(dirname "$repo_root")
current_repo=$(basename "$repo_root")

find "$parent_dir" -mindepth 1 -maxdepth 1 -type d \
  ! -name "$current_repo" -print | sort
```

Stay inside `"$parent_dir"` only.

## Resolve a target repo

```zsh
target="$parent_dir/TARGET_REPO"

[ -d "$target" ] || {
  echo "Missing target repo: $target" >&2
  exit 1
}

git -C "$target" status --short --branch
```

Mention dirty state or non-main branches when relevant.

## Search fast

Prefer `rg`. Avoid `ls -R`.

```zsh
# files
rg --files "$target"

# symbol / endpoint / type search
rg -n "createSession|SessionRequest|FEATURE_X" \
  "$repo_root" "$target" \
  --glob '!**/{node_modules,dist,build,target,.next}/**'
```

Read focused slices only:

```zsh
nl -ba "$target/path/to/file.ts" | sed -n '40,120p'
```

## Best search order

For contracts and shared behavior:

1. schema / OpenAPI / proto / GraphQL
2. exported types
3. routes / handlers
4. SDK or generated client
5. call sites

Search definition shapes first:

```zsh
rg -n "export\s+(type|interface|class|function|const)\s+NAME\b" "$target"
```

## Rules

- Read-only by default.
- Do not edit, install, build, test, fetch, pull, switch branches, or commit in
  other repos unless explicitly requested.
- Avoid secrets and real `.env` files.
- Prefer `.env.example`, schemas, and docs.
- Report evidence with paths and line numbers.
- If no matching repo exists, say what was checked.
