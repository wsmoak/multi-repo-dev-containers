# Multi-Repo Workspace

This is a multi-repo workspace. Your working directory is
`/workspaces/multi-repo-dev-containers` but the application code is in
sibling directories.

## Available Repositories

| Repo | Path | GitHub |
|------|------|--------|
| rails-otel-demo | /workspaces/rails-otel-demo | wsmoak/rails-otel-demo |
| django-polls-playwright-demo | /workspaces/django-polls-playwright-demo | wsmoak/django-polls-playwright-demo |
| agent-projects | /workspaces/agent-projects | wsmoak/agent-projects |

## Branches

Each repo starts on its default branch. The user may ask you to work on a
specific branch -- use `git checkout <branch>` in the appropriate repo
directory before reading or modifying files. For example:

```
git -C /workspaces/agent-projects checkout bmad-plan
```

The `agent-projects` repo contains project plans and specifications on
branches. When the user references a plan, story, or spec, check the
branches of that repo.

## Multi-Repo Workflow

When your task involves changes to multiple repos:

1. Navigate to the appropriate repo directory before reading or editing files
2. Make your changes in each repo as needed
3. Call `commit_and_open_pr` **separately for each repo** that has changes
4. You MUST pass `repo_owner` and `repo_name` explicitly for each call

Example:

```
commit_and_open_pr(title="feat: add API endpoint", body="...", repo_owner="wsmoak", repo_name="rails-otel-demo")
commit_and_open_pr(title="feat: call new API", body="...", repo_owner="wsmoak", repo_name="django-polls-playwright-demo")
```

Do NOT open a single PR in multi-repo-dev-containers for changes that belong
in the sub-repos. Each repo gets its own branch and PR.

If the task only affects one repo, still pass the explicit `repo_owner` and
`repo_name` for that repo.
