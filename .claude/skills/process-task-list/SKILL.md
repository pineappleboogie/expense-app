---
name: process-task-list
description: Manages task lists in markdown files to track PRD implementation progress. Use when working through a task list, implementing features from a PRD, or when the user mentions task lists, subtasks, or completing tasks step by step.
---

# Task List Management

Guidelines for managing task lists in markdown files to track progress on completing a PRD.

## Instructions

### Task Implementation

1. **One sub-task at a time:** Do NOT start the next sub-task until you ask the user for permission and they say "yes" or "y"

2. **Before starting work:** Check which sub-task is next in the task list file

3. **When you finish a sub-task:**
   - Immediately mark it as completed by changing `[ ]` to `[x]`
   - Update the task list file
   - Pause and wait for user approval before continuing

4. **When all subtasks under a parent task are complete:**
   - Run the full test suite (`pytest`, `npm test`, `swift test`, `xcodebuild test`, etc.)
   - Only if all tests pass: Stage changes (`git add .`)
   - Clean up any temporary files and temporary code before committing
   - Commit with a descriptive message using conventional commit format
   - Mark the parent task as `[x]`

### Commit Message Format

Use conventional commit format with multiple `-m` flags:

```
git commit -m "feat: add payment validation logic" -m "- Validates card type and expiry" -m "- Adds unit tests for edge cases" -m "Related to T123 in PRD"
```

Commit messages should:
- Use conventional commit prefix (`feat:`, `fix:`, `refactor:`, etc.)
- Summarize what was accomplished in the parent task
- List key changes and additions
- Reference the task number and PRD context

### Task List Maintenance

1. **Update the task list as you work:**
   - Mark tasks and subtasks as completed (`[x]`) per the protocol above
   - Add new tasks as they emerge

2. **Maintain the "Relevant Files" section:**
   - List every file created or modified
   - Give each file a one-line description of its purpose

## Teacher mode
- run `teach.md` after commiting

## Example Workflow

1. Read the task list file to find the next incomplete sub-task
2. Implement the sub-task
3. Mark the sub-task as `[x]` in the task list file
4. Ask user: "Sub-task complete. Ready to proceed to the next one?"
5. Wait for user confirmation before continuing
6. If parent task is fully complete, run tests and commit
7. Use 'teach.md` to explain what was done
