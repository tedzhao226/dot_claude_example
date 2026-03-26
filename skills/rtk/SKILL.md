---
name: rtk
description: Use rtk (Rust Token Killer) CLI proxy to reduce LLM token consumption by 60-90% on common dev commands. Always prefer `rtk <command>` over raw commands for git, test, read, grep, find, docker, kubectl, and more.
---

# RTK — Token-Optimized CLI Proxy

**Always use `rtk` prefix for these commands.** It filters and compresses output before it reaches your context, saving 60-90% tokens.

## Command Reference

### File Operations
```bash
rtk ls .                    # Token-optimized directory listing
rtk tree .                  # Compact directory tree
rtk read file.rs            # Smart file reading with filtering
rtk read file.rs -l aggressive  # Signatures only (strips function bodies)
rtk smart file.rs           # 2-line heuristic code summary
rtk find "*.rs" .           # Compact find results
rtk grep "pattern" .        # Grouped search results
rtk diff file1 file2        # Ultra-condensed diff
```

### Git
```bash
rtk git status              # Compact status
rtk git log -n 10           # One-line commits
rtk git diff                # Condensed diff
rtk git add .               # → "ok"
rtk git commit -m "msg"     # → "ok abc1234"
rtk git push                # → "ok main"
rtk git pull                # → "ok 3 files +10 -2"
```

### GitHub CLI
```bash
rtk gh pr list              # Compact PR listing
rtk gh pr view 42           # PR details + checks
rtk gh issue list            # Compact issues
```

### Testing
```bash
rtk test <command>          # Run tests, show only failures
rtk pytest                  # Pytest with compact output
rtk cargo test              # Cargo test compact
rtk go test ./...           # Go test compact
```

### Other
```bash
rtk docker ps               # Compact container list
rtk kubectl get pods        # Compact pod listing
rtk curl <url>              # Auto-JSON detection + schema output
rtk err <command>           # Run command, show only errors/warnings
rtk ruff check .            # Compact linter output
rtk pip install <pkg>       # Compact pip output
```

### Meta Commands
```bash
rtk gain                    # Show token savings analytics
rtk gain --history          # Command usage history with savings
rtk discover                # Analyze history for missed opportunities
rtk proxy <cmd>             # Run raw command without filtering (debugging)
```

## When NOT to Use rtk

- When you need the **full unfiltered output** (debugging edge cases)
- When piping output to another command that needs exact formatting
- For commands rtk doesn't support — just run them normally

## Ultra-Compact Mode

Add `-u` for maximum compression:
```bash
rtk -u git status           # ASCII icons, inline format
```

## Token Savings (typical)

| Command | Raw tokens | rtk tokens | Savings |
|---------|-----------|------------|---------|
| ls/tree | 2,000 | 400 | 80% |
| cat/read | 40,000 | 12,000 | 70% |
| git status | 3,000 | 600 | 80% |
| git diff | 10,000 | 2,500 | 75% |
| pytest | 8,000 | 800 | 90% |
