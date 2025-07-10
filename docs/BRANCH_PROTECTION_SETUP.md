# GitHub Branch Protection Setup Guide

## Overview

This guide explains how to set up branch protection rules to ensure CI tests pass before merging PRs.

## Current Status ✅

Branch protection has been automatically configured for the `master` branch using `gh` CLI with the following settings:

### ✅ Configured Protection Rules

- **Required Status Checks**: All CI workflows must pass
- **Require PR Reviews**: At least 1 approving review required
- **Dismiss Stale Reviews**: Enabled
- **Enforce for Administrators**: Enabled
- **No Force Pushes**: Direct pushes to master blocked
- **No Branch Deletions**: Branch cannot be deleted

### ✅ Required CI Checks

The following status checks must pass before merging:

1. **`test (ubuntu-latest)`** - Main CI test suite on Ubuntu
2. **`test (macos-latest)`** - Main CI test suite on macOS
3. **`quick-test`** - Quick functionality verification
4. **`lint`** - ShellCheck linting validation
5. **`security`** - Security scanning checks

## Manual Adjustment via GitHub UI

If you need to modify these settings manually:

### Step 1: Navigate to Repository Settings

1. Go to your GitHub repository: `https://github.com/Pregum/git-worktree-sync`
2. Click **Settings** tab
3. Click **Branches** in the left sidebar

### Step 2: Configure Branch Protection

1. Find the `master` branch rule (should already exist)
2. Click **Edit** next to the rule
3. Configure the following settings:

#### Required Settings for CI Protection

**✅ Protect matching branches**
- [x] Require a pull request before merging
  - [x] Require approvals: `1`
  - [x] Dismiss stale PR approvals when new commits are pushed
  - [ ] Require review from code owners (optional)

**✅ Require status checks to pass before merging**
- [x] Require branches to be up to date before merging
- Required status checks:
  - [x] `test (ubuntu-latest)`
  - [x] `test (macos-latest)`` 
  - [x] `quick-test`
  - [x] `lint`
  - [x] `security`

**✅ Other Protection Rules**
- [x] Require conversation resolution before merging (recommended)
- [x] Require signed commits (optional)
- [x] Require linear history (optional)
- [x] Include administrators

### Step 3: Save Changes

Click **Save changes** to apply the protection rules.

## Troubleshooting Status Checks

### Problem: Status Checks Not Appearing

If the required status checks don't appear in the dropdown:

1. **Trigger Workflows First**: Create a test PR to trigger all workflows
2. **Wait for Completion**: Let all workflows complete at least once
3. **Return to Settings**: The check names will now appear in the dropdown
4. **Select Required Checks**: Check the boxes for all required workflows

### Problem: Incorrect Check Names

If the status check names don't match:

1. **Check Workflow Run History**:
   ```bash
   gh run list --limit 5
   ```

2. **View Specific Run Details**:
   ```bash
   gh run view <run-id>
   ```

3. **Update Protection Rules**:
   ```bash
   gh api --method PUT repos/:owner/:repo/branches/master/protection \
     --input branch_protection.json
   ```

### Common Status Check Name Patterns

- **Matrix Jobs**: `job-name (matrix-value)` 
  - Example: `test (ubuntu-latest)`, `test (macos-latest)`
- **Simple Jobs**: `job-name`
  - Example: `lint`, `security`, `quick-test`

## Verification Commands

### Check Current Protection Status

```bash
# View current branch protection
gh api repos/:owner/:repo/branches/master/protection

# View in readable format
gh api repos/:owner/:repo/branches/master/protection --jq '.required_status_checks.contexts'
```

### Expected Output

```json
[
  "test (ubuntu-latest)",
  "test (macos-latest)", 
  "quick-test",
  "lint",
  "security"
]
```

## Testing the Protection

### Create Test PR

1. **Create Feature Branch**:
   ```bash
   git checkout -b test/branch-protection
   echo "test" >> README.md
   git add README.md
   git commit -m "test: verify branch protection"
   git push origin test/branch-protection
   ```

2. **Create PR**:
   ```bash
   gh pr create --title "Test: Verify Branch Protection" \
     --body "This PR tests that branch protection rules work correctly."
   ```

3. **Verify Protection**:
   - PR should show "Required status checks"
   - Merge button should be disabled until all checks pass
   - All 5 CI workflows should be listed as required

### Expected Behavior

- ❌ **Before CI Completion**: Merge button disabled
- ⏳ **During CI**: Status checks show as "pending"
- ✅ **After CI Success**: Merge button enabled
- ❌ **After CI Failure**: Merge button remains disabled

## Advanced Configuration

### Update Check Names Programmatically

If you need to update the required checks:

```bash
# Create updated configuration
cat > /tmp/updated_protection.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "test (ubuntu-latest)",
      "test (macos-latest)",
      "quick-test", 
      "lint",
      "security"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
EOF

# Apply the configuration
gh api --method PUT repos/:owner/:repo/branches/master/protection \
  --input /tmp/updated_protection.json
```

### Remove Branch Protection

⚠️ **Caution**: Only use if you need to disable protection

```bash
gh api --method DELETE repos/:owner/:repo/branches/master/protection
```

## Benefits of This Setup

1. **Quality Assurance**: All code changes are tested before merging
2. **Cross-Platform Compatibility**: Tests run on both Ubuntu and macOS
3. **Security Validation**: Automated security checks prevent vulnerabilities
4. **Code Review Process**: Human review required for all changes
5. **Consistent Quality**: Prevents broken code from entering main branch

## Maintenance

### Regular Tasks

1. **Monitor CI Performance**: Check that tests complete within reasonable time
2. **Update Check Names**: When adding new workflows, update protection rules
3. **Review Failed Checks**: Investigate and fix any consistently failing tests

### When Adding New Workflows

1. Add the workflow file to `.github/workflows/`
2. Commit and push to trigger the workflow
3. Add the new check name to branch protection rules
4. Test with a test PR to verify it works

## Support

If you encounter issues with branch protection:

1. Check the [GitHub documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
2. Review this guide's troubleshooting section
3. Create an issue in the repository with specific error details