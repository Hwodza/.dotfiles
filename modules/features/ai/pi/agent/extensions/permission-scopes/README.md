# Permission Scopes Extension

A regex-based, two-axis permission system for Pi tool calls.

## Two Matching Axes

### 1. Scope Axis (path-based)
Classifies file paths into scopes (cwd, nix_store, outside, or user-defined) using prefix matching. Each scope defines read/write/edit/bash rules.

### 2. Bash Patterns Axis (command-based)
A global flat list of `{ regex, action }` pairs evaluated against the full command string, independent of path scope.

### Combination
Most restrictive wins: **deny > ask > allow**

## Config Locations (checked in order)

1. `<project>/.pi/extensions/permission-scopes/config.json`
2. Extension directory: `~/.dotfiles/modules/ai/pi/agent/extensions/permission-scopes/config.json`

## Config Schema

```json
{
  "debugLog": false,
  "bash_patterns": [
    { "regex": ".*", "action": "ask" }
  ],
  "scope_definitions": {
    "nix_store": "/nix/store"
  },
  "templates": {
    "diagnostics": [
      { "regex": "^(ls|find|tree|cat|head|tail|stat|echo|grep|rg|wc|du)\\b", "action": "allow" },
      { "regex": "^(pwd|echo)\\b", "action": "allow" },
      { "regex": ".*", "action": "deny" }
    ]
  },
  "scopes": {
    "cwd": {
      "read": "allow",
      "write": "allow",
      "edit": "allow",
      "bash": [
        { "regex": "\\bcd\\b", "action": "deny" },
        { "regex": "^pwd\\b", "action": "allow" },
        "$diagnostics",
        { "regex": ".*", "action": "deny" }
      ]
    },
    "nix_store": {
      "read": "allow",
      "write": "deny",
      "edit": "deny",
      "bash": ["$diagnostics"]
    },
    "outside": {
      "read": "deny",
      "write": "deny",
      "edit": "deny",
      "bash": [
        { "regex": "\\bcd\\b", "action": "deny" },
        { "regex": ".*", "action": "deny" }
      ]
    }
  }
}
```

## Key Concepts

- **Templates** (`$name`) — reuse bash rule sets across scopes
- **Longest prefix match** — when multiple scope_definitions match a path, the longest prefix wins
- **Multi-path commands** — if a bash command's paths span multiple scopes, ALL must allow
- **Session overrides** — "Override for session" persists for the duration of the session
- **Custom replacement** — substitute a command before execution (bash only)

## Building a Custom Config

1. Start with the `bash_patterns` global axis to set your default (e.g., `"ask"` for everything)
2. Define `scope_definitions` for any paths beyond cwd
3. Create bash rule templates for common command groups
4. Wire templates into each scope's `bash` array with specific allow/deny patterns
5. Add fallback `".*": "deny"` rules at the end of each scope's bash list
