Please address all of the feedback on this PR, particularly from @coderabbitai, Cursor, and anyone else

## CRITICAL REQUIREMENTS
- You MUST tag `@coderabbitai` in ALL PR comments replying to CodeRabbit
- Every CodeRabbit comment response MUST include the tag - do not forget this
- Cursor comments do NOT use `@` tagging — reply normally but address them with equal thoroughness
- For invalid feedback from ANY reviewer, you MUST reply INLINE to the specific comment, not just in a summary

## Reviewer Identification
When fetching review comments, identify the author of each comment:
- **CodeRabbit**: author login is `coderabbitai` — replies MUST include `@coderabbitai`
- **Cursor**: author login contains `cursor` — replies do NOT need `@` tagging but MUST be equally thorough and well-reasoned
- **Other reviewers**: address normally, tag with `@username` as a courtesy

Treat all reviewers' feedback with equal weight and consideration. Do not dismiss or shortcut Cursor feedback just because it lacks a tagging mechanism.

## Branch Rules
- **ALWAYS commit directly on the current branch** — the one the PR is based on
- **NEVER create a new branch** for code review fixes
- Run `git branch --show-current` first and confirm you are on the PR's head branch before making changes

## Steps

1. Run `git branch --show-current` to confirm you are on the PR branch
2. Use `gh api` to pull in **only unresolved** review comments. Use the `pull_request_read` MCP tool with `method: "get_review_comments"` to get review threads, and filter to threads where `isResolved` is false. Alternatively, use `gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments` and cross-reference with resolved status. **Skip any comment that has already been resolved or already has a reply from you.**
3. For each comment, identify the reviewer (CodeRabbit, Cursor, or other) to determine the reply protocol
4. Understand what the commenters are asking for
5. Do not blindly do as they suggest, but analyze given your context and consider whether each point is valid and good feedback
6. If it is good feedback, address each comment as a separate git commit
7. If it is not good feedback, reply INLINE to that specific comment explaining why:
   - **For CodeRabbit comments:**
     ```bash
     gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies -f body="@coderabbitai - [your explanation]"
     ```
   - **For Cursor comments:**
     ```bash
     gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies -f body="[your explanation]"
     ```
   - **For other reviewers:**
     ```bash
     gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies -f body="@username - [your explanation]"
     ```
8. When you are done addressing the feedback, make sure that all tests, lint, type checks pass cleanly. This should be handled by the git precommit hooks but in case this is not, please run them yourself independently
9. Push the commits
10. Post a final summary comment on the PR listing what you fixed and what you chose not to address. You MUST tag `@coderabbitai` in the comment. Mention Cursor feedback addressed as well.

## Pre-Completion Checklist
Before marking this task complete, verify:
- [ ] All CodeRabbit PR comments include `@coderabbitai` tag
- [ ] All Cursor comments were addressed with equal thoroughness (no `@` tag needed)
- [ ] Each valid feedback item has its own commit
- [ ] Invalid feedback has INLINE replies to the specific comments (not just in summary)
- [ ] Tests, lint, and type checks pass
- [ ] Changes have been pushed
- [ ] Final summary comment posted with `@coderabbitai` tag and Cursor feedback summary
