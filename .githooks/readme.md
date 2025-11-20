# Pre-Push Lint Hook

This repository includes a **Git pre-push hook** that automatically validates your code formatting and `.editorconfig` rules using [Super-Linter](https://github.com/github/super-linter) and a custom EditorConfig checker.

It only runs on **changed or staged files** and blocks the push if any issues are found.

---

## Prerequisites

- Linux/macOS (tested)
- [Git](https://git-scm.com/) installed
- [Docker](https://www.docker.com/) installed and running

install tool to install pre-commit rule
```bash
pip install pre-commit
```

the precommit rule is define using a yaml in the root repo folder name : .pre-commit-config.yaml 

install pre-commit rule

```bash
pre-commit install --hook-type pre-push
```

now when you push to a remote branche, the docker container super-linter should execute to determine if the new file change match the editorconfig

