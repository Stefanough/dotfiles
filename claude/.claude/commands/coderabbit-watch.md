Watch for CodeRabbit reviews on the current branch's PR and address them automatically in a background agent.

## Foreground Setup

Before launching the background agent, detect the context:

1. Run `git branch --show-current` to get BRANCH
2. Run `git remote get-url origin` and parse OWNER and REPO from the GitHub URL. Handle both formats:
   - `git@github.com:OWNER/REPO.git` → extract OWNER and REPO
   - `https://github.com/OWNER/REPO.git` → extract OWNER and REPO
   - Strip trailing `.git` if present
3. Run `gh pr list --head BRANCH --json number,url --jq '.[0]'` to get PR_NUMBER and PR_URL
4. If no PR is found, tell the user "No PR found for branch BRANCH. Create a PR first, then run this command." and **stop**.
5. Launch the background agent using the `Task` tool with:
   - `run_in_background: true`
   - `isolation: "worktree"`
   - `subagent_type: "general-purpose"`
   - The prompt should be the **entire Background Agent Prompt section below**, with BRANCH, PR_NUMBER, PR_URL, OWNER, and REPO substituted in.
6. Tell the user:
   > CodeRabbit watcher launched for PR #PR_NUMBER (PR_URL).
   > Summary will be written to `/tmp/coderabbit-watch-PR_NUMBER.md` when complete.
   > You'll get a notification when it finishes.

**Do NOT wait for the background agent to finish.** Return control to the user immediately.

---

## Background Agent Prompt

**Pass everything below this line as the `prompt` to the Task tool, with variables substituted.**

---

You are a background agent watching PR #PR_NUMBER on OWNER/REPO for CodeRabbit reviews. Your job is to poll for reviews, address feedback, and exit when CodeRabbit approves or safety caps are hit.

### Setup

1. Run `git checkout BRANCH` to get on the PR branch in this worktree
2. Run `git pull origin BRANCH` to make sure you have the latest commits
3. Initialize tracking state:
   - `processed_comment_ids`: empty list, tracks comment IDs you've already handled
   - `review_cycles`: 0
   - Record the current time as `start_time`
4. Constants: `max_review_cycles = 5`, `max_wall_time_minutes = 30`

### Poll Loop

Repeat the following until an exit condition is met:

#### Step 1: Check safety caps

- If `review_cycles >= 5`: exit with status MAX_CYCLES
- If more than 30 minutes have elapsed since `start_time`: exit with status TIMEOUT

#### Step 2: Fetch PR state

Run these three commands to gather state:

```bash
# Get reviews — check for approval
gh api repos/OWNER/REPO/pulls/PR_NUMBER/reviews --jq '[.[] | select(.user.login == "coderabbitai[bot]")]'

# Get review comments — check for unresolved feedback
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments --jq '[.[] | select(.user.login == "coderabbitai[bot]")]'

# Get issue comments — check for rate limit messages and general coderabbit comments
gh api repos/OWNER/REPO/issues/PR_NUMBER/comments --jq '[.[] | select(.user.login == "coderabbitai[bot]")]'
```

#### Step 3: Classify state and act

Evaluate the results **in this priority order** (first match wins):

**APPROVED** — Any review from `coderabbitai[bot]` has `"state": "APPROVED"`
→ Exit with status SUCCESS.

**RATE_LIMITED** — Any issue comment from `coderabbitai[bot]` contains "rate limit" or "usage limit" (case-insensitive)
→ Read the message carefully and parse how long to wait (e.g., "try again in 5 minutes" → 5 minutes).
→ Sleep for the parsed duration + 60 seconds as buffer.
→ Then post a comment to trigger review:
```bash
gh api repos/OWNER/REPO/issues/PR_NUMBER/comments -f body="@coderabbit review"
```
→ Continue loop. This does NOT count toward `review_cycles`.

**HAS_UNRESOLVED_COMMENTS** — There are review comments from `coderabbitai[bot]` whose IDs are NOT in `processed_comment_ids`
→ Address comments (see Addressing Comments section below).
→ Increment `review_cycles`.
→ Sleep 90 seconds, then continue loop.

**PENDING_REVIEW** — There are coderabbit issue comments posted within the last 3 minutes (suggesting a review is in progress), but no new review comments to address
→ Sleep 60 seconds, then continue loop.

**NO_REVIEW_YET** — No comments from `coderabbitai[bot]` at all
→ Sleep 90 seconds, then continue loop.

### Addressing Comments

When you have unresolved review comments to address:

1. Collect all review comments from `coderabbitai[bot]` whose IDs are NOT in `processed_comment_ids`.

2. For each comment:
   a. Read the comment carefully and understand what is being asked.
   b. Read the relevant code files to understand the full context.
   c. **Critically evaluate** whether the feedback is valid and good. Do NOT blindly apply suggestions. Consider:
      - Is the suggestion actually correct?
      - Does it improve the code?
      - Does it align with the codebase patterns and conventions?
      - Is it a meaningful issue or just stylistic nitpicking?

   d. **If the feedback is valid**: make the fix and create a commit with a descriptive message. One commit per fix.

   e. **If the feedback is NOT valid**: reply inline explaining why. You MUST tag `@coderabbitai` in every reply:
      ```bash
      gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies -f body="@coderabbitai - [your explanation of why this feedback was not applied]"
      ```

3. Add ALL processed comment IDs to `processed_comment_ids` (both fixed and rejected).

4. Run any available test, lint, or typecheck commands to verify nothing is broken. Check for a `Makefile`, `package.json` scripts, or other common runners. If pre-commit hooks exist, they will run on commit. If tests fail after your fix, fix the test failure before continuing.

5. Push all commits:
   ```bash
   git push origin BRANCH
   ```

6. Record what you did for the summary (commit hashes, descriptions, rejections with reasons).

### Exit and Summary

On EVERY exit path (SUCCESS, MAX_CYCLES, TIMEOUT), write a summary file to `/tmp/coderabbit-watch-PR_NUMBER.md`.

The summary must contain:

```
# CodeRabbit Watch Summary

**PR:** PR_URL
**Branch:** BRANCH
**Status:** [SUCCESS — CodeRabbit approved | MAX_CYCLES — reached 5 review cycles | TIMEOUT — exceeded 30 minutes]
**Review cycles completed:** [number]
**Total time:** [elapsed time]

## Cycle 1

### Fixed
- [commit hash] description of what was fixed

### Rejected
- Comment [ID]: reason the feedback was not applied

## Cycle 2
...

## Notes
[Any additional context — e.g., tests that were tricky, rate limit delays encountered]
```

If there were zero review cycles (e.g., CodeRabbit approved on the first pass or timed out waiting), note that in the summary.

### Important Rules

- **Tag `@coderabbitai` in ALL comments** you post on the PR. Every single one.
- **One commit per fix**. Do not batch multiple fixes into one commit.
- **Do not create new branches**. Work directly on BRANCH.
- **Push after each addressing cycle**, not after each individual commit.
- **Do not modify files unrelated to the review feedback**.
- **Final response under 2000 characters.** List outcomes, not process.
