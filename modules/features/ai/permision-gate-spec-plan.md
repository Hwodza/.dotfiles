# Pi Permission Gate Extension
## Technical Specification & Final Coding Prompt

---

# DOCUMENT 1: TECHNICAL SPECIFICATION

---

## 1. Overview

This document specifies a permission-gate extension for the `pi` coding agent. The extension intercepts all file and bash tool calls, evaluates them against a layered JSONC rule set, and presents a vim-motion TUI prompt when a decision requires user input. The goal is to give the operator fine-grained, auditable control over what `pi` can read, write, edit, and execute — without stopping the agent's session on a block.

---

## 2. Architecture: How the Extension Hooks Into `pi`

### 2.1 Extension Loading

`pi` auto-discovers extensions from two locations (see official docs at `pi.dev/docs/latest/extensions`):

| Location | Scope |
|---|---|
| `~/.pi/agent/extensions/*.ts` | Global — all projects |
| `~/.pi/agent/extensions/*/index.ts` | Global — multi-file subdirectory |
| `.pi/extensions/*.ts` | Project-local |

Because the permission gate is meant to be **global** (it protects all sessions), it lives in the global location. In the dendritic dotfiles pattern this will be a symlink:

```
~/.pi/agent/extensions/permission-gate/   ← symlink target managed by home-manager
    index.ts                               ← entry point
    config.ts                              ← JSONC loader + type definitions
    evaluator.ts                           ← rule evaluation logic
    path-extractor.ts                      ← bash argument path extraction
    ask-prompt.ts                          ← vim-motion TUI component
    session-state.ts                       ← in-memory session allow-list
    package.json                           ← npm deps (strip-json-comments, etc.)
```

The real source lives at `/home/henry/.dotfiles/modules/features/ai/pi/agent/extensions/permission-gate/` inside the dotfiles repo. `home-manager` symlinks the whole directory.

### 2.2 Primary Hook: `tool_call`

The extension registers a single `tool_call` handler. This event fires **before** any tool executes and can return `{ block: true, reason: string }` to prevent execution entirely.

```
LLM decides to call bash/read/write/edit
        │
        ▼
tool_execution_start (informational)
        │
        ▼
tool_call  ◄──── OUR HOOK runs here
  │
  ├── evaluate() → ALLOW  → return undefined  (execution proceeds)
  ├── evaluate() → DENY   → return { block: true, reason }  (silent block)
  └── evaluate() → ASK    → await askPrompt() → one of:
        ├── Allow Once       → return undefined
        ├── Allow Session    → record in SessionAllowList, return undefined
        ├── Deny             → return { block: true, reason: "Denied by user" }
        ├── Deny with Reason → return { block: true, reason: userReason }
        └── Custom Replace   → mutate event.input in-place, return undefined
```

The relevant built-in tool names this extension must intercept are:

| Tool Name | Covered Operations |
|---|---|
| `bash` | Bash command execution |
| `read` | File read |
| `write` | File write (create/overwrite) |
| `edit` | File edit (patch) |

The `tool_call` event's `event.input` object is **mutable** — the extension can rewrite arguments in-place (used by the "Custom Replace" option) before returning `undefined` to allow execution with the modified input.

### 2.3 Session-Start Bootstrap

A `session_start` handler reads the JSONC config from disk and caches it in memory. It also seeds any persisted session-allow entries from the `pi.appendEntry` journal (for the "Allow Session" case, so it survives hot-reload via `/reload`).

```typescript
pi.on("session_start", async (_event, ctx) => {
  config = loadConfig(CONFIG_PATH);
  sessionAllowList.rehydrate(ctx.sessionManager.getBranch());
  ctx.ui.notify(`Permission gate loaded (${config.customDirs.length} custom dirs)`, "info");
});
```

### 2.4 Slash Command: `/permissions`

A `registerCommand` registration provides a live-reload shortcut and a summary status display, useful for toggling or inspecting the current rule set without restarting pi.

---

## 3. Rule Evaluation Engine

### 3.1 The Three-Tier Hierarchy

Rules are evaluated in strict priority order. The first tier that **matches** the operation wins; no lower tiers are consulted.

```
Tier 1: CWD + Subdirectories
Tier 2: Custom Directory entries (checked in config order)
Tier 3: Global Fallback (always "ask")
```

### 3.2 Tier 1: CWD Rules

The CWD is obtained from `ctx.cwd` at `session_start` time and again inside each `tool_call` handler (it can change if `pi` is invoked from a different directory after fork/resume).

**File operations in Tier 1:**

| Operation | Default Decision |
|---|---|
| `read` | `allow` |
| `write` | `allow` |
| `edit` | `allow` |

**Bash operations in Tier 1:**

Bash is allowed only if **both** conditions pass:

1. The command name matches an entry in `cwd.allowedBashCommands[].commandPattern` regex.
2. All file-path arguments parsed from the command string resolve **within** the CWD tree (see §4).
3. All non-path arguments/flags match `cwd.allowedBashCommands[].flagPattern` regex (if defined).

If either condition fails, the decision is `ask` (not `deny`). This is intentional — the user may want to approve a legitimate cross-directory operation once.

### 3.3 Tier 2: Custom Directory Rules

Each entry in `customDirs` defines a `path`, optional `recurse` flag, and per-operation decisions:

```
{ read, write, edit, bash } → "allow" | "ask" | "deny"
```

`bash` in a custom dir entry also supports the same `allowedBashCommands` array as CWD. If `bash` is `"allow"`, only the configured allowed commands pass; anything outside triggers `"ask"`. If `bash` is `"deny"`, all bash involving that path is blocked. If `bash` is `"ask"`, all bash involving that path goes to the user prompt.

A path **matches** a custom dir entry if the resolved absolute path of the target starts with the entry's `path` value (after normalization). When `recurse: false`, the match is limited to files directly inside the directory (not nested subdirectories).

### 3.4 Tier 3: Global Fallback

Anything not covered by Tiers 1 or 2 defaults to `ask` for all operations (`read`, `write`, `edit`, `bash`). This default cannot be configured away — it is the safety net.

### 3.5 The `SessionAllowList`

An in-memory `Map<string, Set<string>>` keyed by `operationKey → Set<toolName>` handles the "Allow for current session" state. The key is a stable string combining the tool name, operation, and the resolved path (or command fingerprint for bash). Entries are also written to the pi session journal via `pi.appendEntry("permission-gate:allow", { key, tool })` so they survive a `/reload` within the same session.

On `session_start`, the handler scans `ctx.sessionManager.getBranch()` for entries with `customType === "permission-gate:allow"` to rehydrate the in-memory map.

---

## 4. Path Resolution Logic for Bash Arguments

### 4.1 The Problem

The bash tool receives an opaque `command` string. To verify that file paths passed as arguments resolve inside an allowed directory, the extension must:

1. Identify which tokens in the command string are file paths (not flags or other arguments).
2. Resolve them to absolute paths.
3. Test each resolved path against the active directory tier.

### 4.2 The Algorithm

```
function extractPathsFromBashCommand(command: string, cwd: string): string[]
```

**Step 1 — Tokenize.**
Split the command string into tokens using a POSIX-aware shell tokenizer. The library `shell-quote` (MIT license, available on npm) handles quoting, escaping, and variable expansion markers correctly. Single-command pipelines are handled; for pipelines (`|`, `;`, `&&`, `||`), each segment is analyzed independently.

**Step 2 — Identify the command name.**
The first non-flag token in each segment is the command name. Strip it — it is not a path.

**Step 3 — Heuristic path identification.**
A token is treated as a potential path if **any** of these are true:
- It starts with `/` (absolute path).
- It starts with `./` or `../` (relative path).
- It starts with `~/` (home-relative; expand `~` to `process.env.HOME`).
- It does not start with `-` (flag) AND is not a pure number AND is not a recognized shell keyword AND matches the pattern `/^[a-zA-Z0-9._\-\/]+$/` (looks like a filename or path component).

**Step 4 — Resolve.**
Each identified token is resolved with `path.resolve(cwd, token)` after tilde expansion. Symlinks are NOT resolved at check time (we use the logical path, not the canonical path). This avoids Nix store symlink confusion.

**Step 5 — Return unique resolved paths.**
Return the de-duplicated array of resolved absolute paths for downstream boundary checking.

**Step 6 — Boundary check.**
For each resolved path, call:
```typescript
function isWithin(resolvedPath: string, boundary: string): boolean {
  const norm = boundary.endsWith("/") ? boundary : boundary + "/";
  return resolvedPath === boundary || resolvedPath.startsWith(norm);
}
```

If any resolved path falls **outside** the claimed boundary, the check fails and the decision escalates (typically to `ask`).

### 4.3 Edge Cases

| Case | Handling |
|---|---|
| No path arguments | All-clear — only the command name regex needs to match |
| Glob patterns (`*.ts`) | Passed as-is; globbed paths are resolved relative to CWD |
| Command substitution (`$(...)`) | Treated as opaque; any such token triggers `ask` |
| Heredoc / stdin redirect | Redirection targets (`>`, `>>`, `<`) are extracted as path arguments |
| `--flag=value` with path value | Stripped of flag prefix; value is analyzed as potential path |

---

## 5. JSONC Configuration Schema

The config file lives at `~/.pi/agent/extensions/pi-permissions/config.jsonc`. In the dendritic dotfiles pattern, the source is at `/home/henry/.dotfiles/modules/features/ai/pi/agent/extensions/permission-gate/`; home-manager symlinks (or copies) it into place.

The extension reads it using `strip-json-comments` at startup. Hot-reload is supported via the `/permissions reload` slash command.

### 5.1 Full Annotated Schema

```jsonc
// ~/.config/pi-permissions/rules.jsonc
// Permission gate configuration for the pi coding agent.
// This file uses JSONC (JSON with Comments). Reload with /permissions reload.
{
  // ── TIER 1: CWD Rules ──────────────────────────────────────────────────────
  // These apply to the directory pi was launched from, and all subdirectories.
  "cwd": {
    // File operations in CWD are always allowed. These fields are informational
    // (you cannot set them to deny for CWD — that would break most workflows).
    "read": "allow",
    "write": "allow",
    "edit": "allow",

    // Bash commands allowed inside CWD without asking.
    // Each entry is tested against the FULL command string (command + all args).
    // The commandPattern is tested against the command NAME only (first token).
    // The pathConstraint setting controls whether path args are verified.
    "allowedBashCommands": [
      {
        // Allow "ls" with any flags, but only paths inside CWD.
        "commandPattern": "^ls$",
        // flagPattern matches the non-path portion of the argument string.
        // Use ".*" to allow any flags. Omit to require no extra flags.
        "flagPattern": "^(-[alh]+)?$",
        // enforce that all file paths in args resolve within CWD (or the
        // target custom dir). Set false to skip path verification.
        "enforceCwdPaths": true,
        // Human-readable label shown in the TUI when this rule fires.
        "label": "Directory listing (read-only)"
      },
      {
        "commandPattern": "^(cat|bat)$",
        "flagPattern": ".*",
        "enforceCwdPaths": true,
        "label": "File read (cat/bat)"
      },
      {
        // Allow grep and ripgrep (rg), any flags, paths in CWD.
        "commandPattern": "^(grep|rg|ag|ack)$",
        "flagPattern": ".*",
        "enforceCwdPaths": true,
        "label": "Search (grep/rg)"
      },
      {
        "commandPattern": "^git$",
        // Only allow read-only git subcommands.
        // The full command string (including subcommand) is what flagPattern sees.
        "flagPattern": "^(status|log|diff|show|branch|tag|remote|describe|shortlog|rev-parse|rev-list)( .*)?$",
        "enforceCwdPaths": false,
        "label": "Git read-only operations"
      },
      {
        "commandPattern": "^(find|fd)$",
        "flagPattern": ".*",
        "enforceCwdPaths": true,
        "label": "File find"
      },
      {
        "commandPattern": "^(wc|head|tail|diff|sort|uniq|cut|tr|sed|awk|jq|yq)$",
        "flagPattern": ".*",
        "enforceCwdPaths": true,
        "label": "Text processing (read-only)"
      },
      {
        // Allow nix evaluation commands that don't write to the store.
        "commandPattern": "^nix$",
        "flagPattern": "^(eval|show-config|show-derivation|flake show|flake check|flake metadata)( .*)?$",
        "enforceCwdPaths": false,
        "label": "Nix read-only evaluation"
      }
    ],

    // For bash ops not matching allowedBashCommands: "ask" (cannot be changed).
    "bashFallback": "ask"
  },

  // ── TIER 2: Custom Directories ─────────────────────────────────────────────
  // Checked in order. First match wins.
  "customDirs": [
    {
      // The Nix store — readable but immutable (writes would fail at OS level
      // anyway, but we block them at the pi level for clarity).
      "path": "/nix/store",
      "recurse": true,
      "label": "Nix Store",
      "read": "allow",
      "write": "deny",
      "edit": "deny",
      // bash: "allow" means only the allowedBashCommands below are permitted.
      // Anything else in /nix/store goes to "ask".
      "bash": "allow",
      "allowedBashCommands": [
        {
          "commandPattern": "^(ls|find|cat|bat|grep|rg)$",
          "flagPattern": ".*",
          "enforceCwdPaths": false,
          "label": "Store inspection (read-only)"
        }
      ]
    },
    {
      // Home directory config — read is fine, writes are sensitive.
      "path": "/home/henry/.config",
      "recurse": true,
      "label": "User Config (~/.config)",
      "read": "allow",
      "write": "ask",
      "edit": "ask",
      "bash": "ask"
    },
    {
      // Dotfiles repo — fully trusted (same as CWD effectively).
      "path": "/home/henry/.dotfiles",
      "recurse": true,
      "label": "Dotfiles Repo",
      "read": "allow",
      "write": "allow",
      "edit": "allow",
      "bash": "allow",
      "allowedBashCommands": [
        {
          "commandPattern": "^(ls|cat|bat|grep|rg|git|find|fd|home-manager|nixos-rebuild)$",
          "flagPattern": ".*",
          "enforceCwdPaths": false,
          "label": "Dotfiles management"
        }
      ]
    },
    {
      // Block anything in /etc from writes.
      "path": "/etc",
      "recurse": true,
      "label": "System Config (/etc)",
      "read": "ask",
      "write": "deny",
      "edit": "deny",
      "bash": "deny"
    },
    {
      // Documents — ask before writing.
      "path": "/home/henry/Documents",
      "recurse": true,
      "label": "Documents",
      "read": "allow",
      "write": "ask",
      "edit": "ask",
      "bash": "ask"
    }
  ],

  // ── TIER 3: Global Fallback ────────────────────────────────────────────────
  // This cannot be changed — anything not matched above goes to "ask".
  // It is shown here for documentation purposes only.
  "globalFallback": {
    "read": "ask",
    "write": "ask",
    "edit": "ask",
    "bash": "ask"
  },

  // ── Extension Behavior ─────────────────────────────────────────────────────
  "settings": {
    // Show a footer status indicator while the permission gate is active.
    "showStatusFooter": true,
    // Log all decisions (allow/deny/ask) to this file. null = disabled.
    "auditLogPath": "/home/henry/.local/share/pi-permissions/audit.log",
    // Time in ms to wait for user response before auto-denying (0 = wait forever).
    "askTimeoutMs": 0,
    // If true, denied operations are reported back to the LLM as a tool error
    // with the reason. If false, they are silently blocked and the LLM sees
    // a generic "Operation not permitted" message.
    "reportDenyReasonToLLM": true
  }
}
```

---

## 6. TUI Prompt: The "Ask" Component

### 6.1 Interaction Model

When an operation resolves to `ask`, the `tool_call` handler must **pause** the tool pipeline and present an interactive TUI prompt to the user. The `ctx.ui.custom()` API mounts a raw `pi-tui` `Component` as a modal overlay, and the returned `Promise` resolves when the user makes a choice.

### 6.2 Prompt Layout

```
╭─ Permission Request ──────────────────────────────────────────────────────╮
│ Tool   : bash                                                              │
│ Command: nixos-rebuild switch --flake .#henry                             │
│                                                                            │
│ Rule   : Global Fallback — no matching rule (outside CWD and customDirs)  │
│ Path(s): /home/henry/.dotfiles (resolved)                                 │
│                                                                            │
│ ❯ [1] Allow once                                                           │
│   [2] Allow for current session                                            │
│   [3] Deny                                                                 │
│   [4] Deny with reason...                                                  │
│   [5] Custom replacement...                                                │
│                                                                            │
│  j/k ↑↓  Enter/l select  q/Esc deny  1-5 direct                          │
╰───────────────────────────────────────────────────────────────────────────╯
```

### 6.3 Vim-Motion Keybindings

| Key | Action |
|---|---|
| `j` / `↓` | Move selection down |
| `k` / `↑` | Move selection up |
| `g` | Jump to first option |
| `G` | Jump to last option |
| `1`–`5` | Direct selection of option by number |
| `Enter` / `l` | Confirm selection |
| `q` / `Esc` | Implicit "Deny" (same as option 3) |
| `h` | Toggle rule detail panel |

### 6.4 Sub-Prompts

**Option 4 — Deny with reason:**
After selecting option 4, the component transitions to a single-line text input field. The typed text is used as the block `reason` string returned to the LLM.

**Option 5 — Custom replacement:**
The component transitions to a multi-line text area pre-filled with the original command (for bash) or path (for file ops). The user edits the command/path. An optional reason field follows. On confirmation, `event.input.command` (or `event.input.path`) is mutated in-place with the user's value and the handler returns `undefined`.

### 6.5 Implementation Approach

The component is built using `@earendil-works/pi-tui`'s `Component` base class and leverages `ctx.ui.onTerminalInput()` for raw keypress handling. The implementation uses a state machine:

```
States: SELECTING → DENY_REASON_INPUT | CUSTOM_REPLACE_INPUT → SUBMITTED
```

The `ctx.ui.custom(component)` call returns a Promise that is resolved by the component calling a callback when the user makes a final choice.

---

## 7. State Management

### 7.1 Module-Level State (in-memory, session-scoped)

```typescript
// session-state.ts
export class SessionAllowList {
  private allowed: Map<string, Set<string>> = new Map();

  add(key: string): void {
    this.allowed.set(key, new Set());
  }

  has(key: string): boolean {
    return this.allowed.has(key);
  }

  clear(): void {
    this.allowed.clear();
  }

  rehydrate(entries: SessionEntry[]): void {
    this.clear();
    for (const entry of entries) {
      if (entry.type === "custom" && entry.customType === "permission-gate:allow") {
        const data = entry.data as { key: string };
        this.add(data.key);
      }
    }
  }
}

// A stable key for a given operation:
// "bash::nixos-rebuild" or "read::/nix/store/xyz/bin/nix"
export function makeAllowKey(toolName: string, resolvedTarget: string): string {
  return `${toolName}::${resolvedTarget}`;
}
```

### 7.2 Persistence via `pi.appendEntry`

When the user selects "Allow for current session", the extension appends a custom entry to the session journal:

```typescript
pi.appendEntry("permission-gate:allow", { key: allowKey });
```

On the next `session_start` (e.g., after `/reload`), the `rehydrate()` method scans `getBranch()` and restores the in-memory map.

### 7.3 Audit Logging

All decisions are written to the audit log file (if configured) using Node's `fs.appendFileSync` via `withFileMutationQueue` to avoid concurrent write collisions:

```
2026-07-25T10:42:00Z | ALLOW_SESSION | bash       | nixos-rebuild switch --flake .#henry
2026-07-25T10:42:31Z | DENY_USER     | write      | /etc/hosts | reason: "System files are immutable"
2026-07-25T10:43:05Z | ALLOW_ONCE    | read       | /home/henry/Documents/budget.csv
```

---

## 8. Tech Stack Recommendations

### 8.1 Language

TypeScript — mandatory. `pi`'s extension system is TypeScript-native. Extensions are loaded via `jiti` and run without a separate compilation step.

### 8.2 TUI Library

**Use `@earendil-works/pi-tui` directly.** This is the TUI library that `pi` itself is built on. It is bundled into `pi`'s runtime and re-exported as an importable package for extension authors. This means:

- Zero additional dependencies for TUI rendering.
- Components are guaranteed to be compatible with `pi`'s rendering engine.
- The `ctx.ui.custom()` API expects a `Component` from this package.

Do NOT bring in `blessed`, `ink`, `terminal-kit`, or any other TUI library. They cannot be integrated with `pi`'s rendering loop.

### 8.3 JSONC Parsing

**`strip-json-comments`** (MIT license, ~7 KB). Add a `package.json` alongside `index.ts` listing it as a dependency, then run `npm install`. `pi` resolves imports from the adjacent `node_modules/` automatically.

### 8.4 Shell Tokenization

**`shell-quote`** (MIT license). Used in `path-extractor.ts` to tokenize bash command strings. Alternative: write a simple hand-rolled tokenizer — the pattern matching is not deeply complex and a hand-rolled approach avoids an npm dependency.

### 8.5 Path Utilities

**Node.js built-ins only** — `node:path`, `node:fs`, `node:os`. No extra dependencies needed.

---

## 9. NixOS / home-manager Integration

### 9.1 Dendritic Dotfiles Pattern

Read the repo to see the directory structure.

### 9.2 `home-manager` Module (`pi.nix`)


### 9.3 Managing `node_modules` via Nix 

The framework for this is already in place, add any dependencies to /home/henry/.dotfiles/modules/features/ai/pi/agent/extensions-managed/package.json by running npm <package> in that dir. 



### 9.4 Config File Path

The extension reads the config from a constant path:

```typescript
// config.ts
import { homedir } from "node:os";
import { join } from "node:path";

export const CONFIG_PATH = join(
  homedir(),
  ".config",
  "pi-permissions",
  "rules.jsonc"
);
```

This path is the same location that `home-manager` symlinks the JSONC file to. No environment variable indirection is needed.

---

## 10. Full Evaluation Decision Table

| Tier | Tool | Condition | Decision |
|---|---|---|---|
| 1 (CWD) | `read` | path within CWD | `allow` |
| 1 (CWD) | `write` | path within CWD | `allow` |
| 1 (CWD) | `edit` | path within CWD | `allow` |
| 1 (CWD) | `bash` | cmd matches regex AND paths within CWD | `allow` |
| 1 (CWD) | `bash` | cmd matches regex BUT paths outside CWD | `ask` |
| 1 (CWD) | `bash` | cmd does NOT match any regex | `ask` |
| 2 (Custom) | any | path within dir AND decision is `allow` | `allow` |
| 2 (Custom) | any | path within dir AND decision is `deny` | `deny` |
| 2 (Custom) | any | path within dir AND decision is `ask` | `ask` |
| 3 (Global) | any | no tier matched | `ask` |
| Session Allow | any | key in SessionAllowList | `allow` (overrides all tiers) |

The `SessionAllowList` check happens **before** tier evaluation — it is the first check in the `tool_call` handler.

---

---

# DOCUMENT 2: FINAL CODING PROMPT

---

> This prompt is self-contained. Paste it into Cursor, Aider, Copilot Chat, or any code-generation agent to produce the complete extension code.

---

## Prompt

You are an expert TypeScript developer and a `pi` coding agent extension author. Your task is to write a complete, production-quality **permission gate extension** for the `pi` coding agent. Read every section of this prompt carefully before writing any code.

---

### Background: The `pi` Extension System

`pi` is a terminal coding agent. Extensions are TypeScript modules auto-discovered from `~/.pi/agent/extensions/`. They export a default factory function receiving an `ExtensionAPI` object.

The primary import is:
```typescript
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
```

TUI components come from:
```typescript
import { Component, Text, Box, Container } from "@earendil-works/pi-tui";
```

The critical hook is `tool_call`. Fired before any tool executes. Return `{ block: true, reason: string }` to block; return `undefined` to allow; mutate `event.input` in-place to modify arguments before allowing:

```typescript
pi.on("tool_call", async (event, ctx) => {
  // event.toolName: "bash" | "read" | "write" | "edit" | ...
  // event.input: mutable tool arguments
  // return { block: true, reason: "..." } to block
  // return undefined to allow
});
```

`ctx.ui.custom(component)` mounts a pi-tui Component as a modal overlay and returns a Promise.
`ctx.ui.onTerminalInput(handler)` registers a raw keypress handler, returns a cleanup function.
`ctx.cwd` is the current working directory.
`pi.appendEntry(customType, data)` persists data to the session journal.
`ctx.sessionManager.getBranch()` retrieves all entries in the current session branch.

---

### Your Deliverables

Write the following files. Every file must be complete, no placeholders.

---

#### File 1: `package.json`

Placed next to `index.ts`. Declares these runtime dependencies:
- `strip-json-comments` — for JSONC parsing
- `shell-quote` — for bash argument tokenization

Include `@types/shell-quote` as a devDependency. Do not include a build step — `pi` runs TypeScript directly.

```json
{
  "name": "pi-permission-gate",
  "version": "1.0.0",
  "description": "Permission gate extension for pi coding agent",
  "dependencies": {
    "strip-json-comments": "^5.0.0",
    "shell-quote": "^1.8.1"
  },
  "devDependencies": {
    "@types/shell-quote": "^1.7.4"
  }
}
```

---

#### File 2: `config.ts`

Responsibilities:
- Define all TypeScript types/interfaces that mirror the JSONC schema.
- Define the constant `CONFIG_PATH` = `~/.config/pi-permissions/rules.jsonc`.
- Export `loadConfig(path: string): PermissionConfig` which reads the file synchronously, strips comments using `strip-json-comments`, parses JSON, validates required fields, and returns a typed config object. If the file doesn't exist or is invalid, throw a descriptive error.

**Types to define:**

```typescript
type Decision = "allow" | "ask" | "deny";

interface AllowedBashCommand {
  commandPattern: string;   // regex matched against the command name (first token)
  flagPattern?: string;     // regex matched against the full arg string (minus paths)
  enforceCwdPaths: boolean; // whether path args must resolve within the boundary
  label: string;            // human-readable label for TUI display
}

interface CwdConfig {
  read: "allow";            // always allow in CWD
  write: "allow";           // always allow in CWD
  edit: "allow";            // always allow in CWD
  allowedBashCommands: AllowedBashCommand[];
  bashFallback: "ask";      // always ask in CWD for unmatched bash
}

interface CustomDirConfig {
  path: string;             // absolute path
  recurse: boolean;         // default true
  label: string;
  read: Decision;
  write: Decision;
  edit: Decision;
  bash: Decision;           // "allow" = use allowedBashCommands; others direct
  allowedBashCommands?: AllowedBashCommand[];
}

interface PermissionSettings {
  showStatusFooter: boolean;
  auditLogPath: string | null;
  askTimeoutMs: number;
  reportDenyReasonToLLM: boolean;
}

interface PermissionConfig {
  cwd: CwdConfig;
  customDirs: CustomDirConfig[];
  settings: PermissionSettings;
}
```

---

#### File 3: `path-extractor.ts`

Export one function:

```typescript
export function extractPaths(command: string, cwd: string): string[]
```

Implementation requirements:
1. Use `shell-quote`'s `parse()` to tokenize the full command string into tokens.
2. Handle pipelines: split on `|`, `&&`, `||`, `;` characters **before** tokenizing so each segment is analyzed independently.
3. For each pipeline segment, the first non-flag token is the command name — skip it.
4. A token is a potential path if:
   - starts with `/`, `./`, `../`, or `~/`
   - OR does not start with `-` AND matches `/^[a-zA-Z0-9._\-\/]+$/` AND is not a pure number AND is not a bash keyword (`if`, `then`, `fi`, `for`, `do`, `done`, `while`, `case`, `esac`, `in`)
5. Redirect targets (`>`, `>>`, `<`, `2>`) are followed by a path token — extract those too.
6. For `--flag=value` style arguments, check whether the value looks like a path.
7. Expand `~` to `process.env.HOME ?? "/root"`.
8. Resolve each path with `path.resolve(cwd, expandedPath)`.
9. Return unique resolved paths.
10. If the command string contains `$(` or `` ` ``, include a special sentinel string `"__SUBSHELL__"` in the returned array (so the caller can detect it and escalate to `ask`).

Export a second helper:

```typescript
export function isWithinBoundary(resolvedPath: string, boundary: string): boolean
```

Returns `true` if `resolvedPath` equals `boundary` or starts with `boundary + "/"`.

---

#### File 4: `evaluator.ts`

Export:

```typescript
export type EvaluationResult =
  | { decision: "allow" }
  | { decision: "deny"; reason: string; matchedRule: string }
  | { decision: "ask"; reason: string; matchedRule: string; resolvedPaths?: string[] };

export function evaluate(
  toolName: "bash" | "read" | "write" | "edit",
  input: Record<string, unknown>,
  config: PermissionConfig,
  cwd: string,
  sessionAllowList: SessionAllowList
): EvaluationResult
```

Implementation:

**Step 0 — Session allow-list check (highest priority):**
Compute the allow key for this operation. If it's in `sessionAllowList`, return `{ decision: "allow" }` immediately.

The allow key for file ops is `"${toolName}::${resolvedPath}"`.
The allow key for bash is `"bash::${commandFingerprint}"` where the fingerprint is the first 200 chars of the command string (normalized: trimmed, collapsed whitespace).

**Step 1 — Extract target path(s) / command:**
- For `read`, `write`, `edit`: the path is `input.path as string`. Resolve it to absolute with `path.resolve(cwd, inputPath)`.
- For `bash`: the command is `input.command as string`. Call `extractPaths(command, cwd)` to get path candidates.

**Step 2 — Tier 1: CWD check:**
- For file ops: if resolved path starts with `cwd + "/"` or equals `cwd`, return `{ decision: "allow" }`.
- For bash:
  1. Find the first matching `AllowedBashCommand` entry where `new RegExp(entry.commandPattern).test(commandName)` is true.
  2. If no match → return `{ decision: "ask", matchedRule: "CWD bash fallback — no matching allowedBashCommands entry", ... }`.
  3. If matched and `entry.enforceCwdPaths` is true: check all extracted paths are within `cwd`. If any path is outside (or `__SUBSHELL__` is present) → return `ask`.
  4. If `entry.flagPattern` is defined: test the argument string (command minus the command name) against `new RegExp(entry.flagPattern)`. If no match → return `ask`.
  5. Otherwise → return `{ decision: "allow" }`.

**Step 3 — Tier 2: Custom directory check:**
Iterate `config.customDirs` in order. For each:
- Check if any resolved path (for bash: any extracted path; for file ops: the single resolved path) starts with the dir's `path` (using `isWithinBoundary`).
- If `recurse: false`, the path must be a direct child (only one additional path segment).
- On a match, look up the decision for this tool type (`read`/`write`/`edit`/`bash`).
- For `bash` + `"allow"`: apply the same `allowedBashCommands` sub-check as Tier 1, using the dir path as boundary.
- Return the appropriate `EvaluationResult` with a `matchedRule` string like `"Custom dir: ${dir.label} (${dir.path}) — ${dir.read}"`.

**Step 4 — Tier 3: Global fallback:**
Return `{ decision: "ask", matchedRule: "Global fallback — no matching rule", resolvedPaths: ... }`.

---

#### File 5: `session-state.ts`

```typescript
export class SessionAllowList {
  private allowed: Set<string> = new Set();

  add(key: string): void { this.allowed.add(key); }
  has(key: string): boolean { return this.allowed.has(key); }
  clear(): void { this.allowed.clear(); }

  rehydrate(entries: Array<{ type: string; customType?: string; data?: unknown }>): void {
    this.clear();
    for (const entry of entries) {
      if (entry.type === "custom" && entry.customType === "permission-gate:allow") {
        const data = entry.data as { key: string } | undefined;
        if (data?.key) this.add(data.key);
      }
    }
  }
}

export function makeAllowKey(toolName: string, target: string): string {
  return `${toolName}::${target.slice(0, 200).trim().replace(/\s+/g, " ")}`;
}
```

---

#### File 6: `ask-prompt.ts`

This is the most complex file. It implements the vim-motion TUI prompt as a pi-tui `Component`.

Export one async function:

```typescript
export async function showAskPrompt(
  ctx: ExtensionContext,
  toolName: string,
  input: Record<string, unknown>,
  evaluationResult: { matchedRule: string; resolvedPaths?: string[] }
): Promise<AskPromptResult>

export type AskPromptResult =
  | { action: "allowOnce" }
  | { action: "allowSession"; allowKey: string }
  | { action: "deny"; reason: string }
  | { action: "customReplace"; modifiedInput: Record<string, unknown>; reason?: string }
```

**Component requirements:**

The component renders inside `ctx.ui.custom()`. It has these distinct states:

1. **`SELECTING`** — shows the 5-option menu with vim-motion navigation.
2. **`DENY_REASON`** — shows a single-line text input field.
3. **`CUSTOM_REPLACE`** — shows a multi-line text area pre-filled with the original value. For `bash` this is `input.command`. For file tools this is `input.path`.
4. **`SUBMITTED`** — resolves the promise immediately and unmounts.

**Rendering in SELECTING state:**

Build the display string programmatically using `theme.fg()` and `theme.bold()` for color/emphasis. The layout:

```
╭─ Permission Request ──────────────────────────────────────────╮
│ Tool   : bash                                                  │
│ Command: <truncated to 80 chars>                              │
│                                                                │
│ Rule   : <evaluationResult.matchedRule>                       │
│ Path(s): <resolvedPaths joined by ", " or "none">            │
│                                                                │
│ ❯ [1] Allow once                                              │
│   [2] Allow for current session                               │
│   [3] Deny                                                     │
│   [4] Deny with reason...                                      │
│   [5] Custom replacement...                                    │
│                                                                │
│  j/↓ k/↑ move  Enter/l select  1-5 jump  q/Esc deny          │
╰───────────────────────────────────────────────────────────────╯
```

Use a `Box` or `Container` as the root component. Use `Text` for content. The currently selected option is highlighted using `theme.bold()` and prefixed with `❯`. Non-selected options are prefixed with spaces.

**Keybinding handling:**

Use `ctx.ui.onTerminalInput((key) => { ... })` to intercept raw keypresses. Return the cleanup function to remove the handler when done.

Key mappings for `SELECTING` state:
- `j` or `ArrowDown` → selectedIndex = Math.min(selectedIndex + 1, 4)
- `k` or `ArrowUp` → selectedIndex = Math.max(selectedIndex - 1, 0)
- `g` → selectedIndex = 0
- `G` → selectedIndex = 4
- `1` → selectedIndex = 0, then confirm
- `2` → selectedIndex = 1, then confirm
- `3` → selectedIndex = 2, then confirm
- `4` → selectedIndex = 3, then confirm
- `5` → selectedIndex = 4, then confirm
- `Enter` or `l` → confirm current selection
- `q` or `Escape` → implicit deny (option 3 behavior)
- `h` → toggle an expanded detail panel showing the full command and all resolved paths

After any state change, call `context.invalidate()` (from the `renderCall`/`renderResult` context, or store a reference to the invalidation function) to trigger a re-render.

**Text input (DENY_REASON and CUSTOM_REPLACE states):**

Implement a minimal line editor as part of the component state:
- Track `currentInput: string` and `cursorPos: number`.
- Printable characters are appended at cursor position.
- `Backspace` deletes the character before the cursor.
- `ArrowLeft` / `h` moves cursor left; `ArrowRight` / `l` moves cursor right.
- `Enter` confirms input (transitions to SUBMITTED).
- `Escape` cancels (returns to SELECTING state).

Display the input field with a visible cursor using a pipe character `|` at the cursor position.

**Promise resolution:**

Before mounting the component, create a Promise with externally accessible resolve/reject:
```typescript
let resolvePrompt!: (result: AskPromptResult) => void;
const resultPromise = new Promise<AskPromptResult>((res) => { resolvePrompt = res; });
```

When the component reaches SUBMITTED state, call `resolvePrompt(result)`. The `showAskPrompt` function returns `resultPromise`.

---

#### File 7: `index.ts`

The extension entry point. Wires everything together.

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { loadConfig, CONFIG_PATH, type PermissionConfig } from "./config.js";
import { evaluate } from "./evaluator.js";
import { SessionAllowList, makeAllowKey } from "./session-state.js";
import { showAskPrompt } from "./ask-prompt.js";
import { appendFileSync } from "node:fs";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let config: PermissionConfig;
  const sessionAllowList = new SessionAllowList();

  // ── Session Start ──────────────────────────────────────────────────────────
  pi.on("session_start", async (_event, ctx) => {
    try {
      config = loadConfig(CONFIG_PATH);
    } catch (err) {
      ctx.ui.notify(
        `Permission gate: failed to load config — ${(err as Error).message}`,
        "error"
      );
      return;
    }

    sessionAllowList.rehydrate(ctx.sessionManager.getBranch() as any[]);

    if (config.settings.showStatusFooter) {
      ctx.ui.setStatus(
        "permission-gate",
        `🔒 ${config.customDirs.length} rules`
      );
    }

    ctx.ui.notify("Permission gate active", "info");
  });

  // ── Session Shutdown ───────────────────────────────────────────────────────
  pi.on("session_shutdown", async () => {
    sessionAllowList.clear();
    ctx.ui?.setStatus("permission-gate", "");
  });

  // ── Tool Call Hook ─────────────────────────────────────────────────────────
  pi.on("tool_call", async (event, ctx) => {
    const toolName = event.toolName as "bash" | "read" | "write" | "edit";

    // Only intercept file and bash tools.
    if (!["bash", "read", "write", "edit"].includes(toolName)) return;

    // Config may not be loaded if session_start failed.
    if (!config) return;

    const result = evaluate(toolName, event.input as Record<string, unknown>, config, ctx.cwd, sessionAllowList);

    // Write to audit log if configured.
    if (config.settings.auditLogPath) {
      const target = toolName === "bash"
        ? (event.input as any).command as string
        : (event.input as any).path as string;
      await writeAuditLog(
        config.settings.auditLogPath,
        result.decision.toUpperCase(),
        toolName,
        target,
        result.decision !== "allow" ? (result as any).matchedRule : undefined
      );
    }

    if (result.decision === "allow") {
      return; // Let it through.
    }

    if (result.decision === "deny") {
      const reason = config.settings.reportDenyReasonToLLM
        ? `Denied by permission gate: ${(result as any).reason}`
        : "Operation not permitted by permission gate.";
      return { block: true, reason };
    }

    // decision === "ask" — show the TUI prompt.
    const promptResult = await showAskPrompt(
      ctx,
      toolName,
      event.input as Record<string, unknown>,
      { matchedRule: (result as any).matchedRule, resolvedPaths: (result as any).resolvedPaths }
    );

    if (config.settings.auditLogPath) {
      const target = toolName === "bash"
        ? (event.input as any).command as string
        : (event.input as any).path as string;
      await writeAuditLog(
        config.settings.auditLogPath,
        `USER_${promptResult.action.toUpperCase()}`,
        toolName,
        target,
        promptResult.action === "deny" ? promptResult.reason : undefined
      );
    }

    switch (promptResult.action) {
      case "allowOnce":
        return; // Proceed with original input.

      case "allowSession": {
        sessionAllowList.add(promptResult.allowKey);
        pi.appendEntry("permission-gate:allow", { key: promptResult.allowKey });
        return; // Proceed with original input.
      }

      case "deny": {
        const reason = config.settings.reportDenyReasonToLLM
          ? `Denied by user: ${promptResult.reason}`
          : "Operation not permitted.";
        return { block: true, reason };
      }

      case "customReplace": {
        // Mutate event.input in-place with the user's replacement.
        Object.assign(event.input, promptResult.modifiedInput);
        return; // Proceed with modified input.
      }
    }
  });

  // ── /permissions Command ───────────────────────────────────────────────────
  pi.registerCommand("permissions", {
    description: "Manage permission gate: status | reload | log",
    handler: async (args, ctx) => {
      const subcommand = (args ?? "").trim().toLowerCase();

      switch (subcommand) {
        case "reload": {
          try {
            config = loadConfig(CONFIG_PATH);
            ctx.ui.notify(
              `Permission gate: config reloaded (${config.customDirs.length} custom dirs)`,
              "info"
            );
          } catch (err) {
            ctx.ui.notify(
              `Permission gate: reload failed — ${(err as Error).message}`,
              "error"
            );
          }
          break;
        }

        case "log": {
          if (!config?.settings.auditLogPath) {
            ctx.ui.notify("Audit logging is disabled (auditLogPath is null in config).", "info");
            break;
          }
          ctx.ui.notify(`Audit log: ${config.settings.auditLogPath}`, "info");
          break;
        }

        case "status":
        default: {
          if (!config) {
            ctx.ui.notify("Permission gate: config not loaded.", "warning");
            break;
          }
          const lines = [
            `Config: ${CONFIG_PATH}`,
            `Custom dirs: ${config.customDirs.length}`,
            `CWD allowed commands: ${config.cwd.allowedBashCommands.length}`,
            `Audit log: ${config.settings.auditLogPath ?? "disabled"}`,
            `Session allow-list loaded.`,
          ];
          ctx.ui.notify(lines.join("\n"), "info");
          break;
        }
      }
    },
  });
}

// ── Audit log helper ─────────────────────────────────────────────────────────
async function writeAuditLog(
  logPath: string,
  decision: string,
  tool: string,
  target: string,
  reason?: string
): Promise<void> {
  const line = [
    new Date().toISOString(),
    decision.padEnd(20),
    tool.padEnd(10),
    target.slice(0, 100),
    reason ? `| ${reason}` : "",
  ].join(" | ").trimEnd() + "\n";

  await withFileMutationQueue(logPath, async () => {
    try {
      appendFileSync(logPath, line, "utf8");
    } catch {
      // Silently ignore log write failures — don't block the agent.
    }
  });
}
```

---

### NixOS / home-manager Integration Instructions

Your deliverable also includes guidance for integrating into a dendritic dotfiles repo:

**1. Source structure in dotfiles:**

```
$DOTFILES/home/modules/features/ai/
├── pi.nix
├── pi/agent/extensions/
│   └── permission-gate/
│       ├── index.ts        (generated)
│       ├── config.ts       (generated)
│       ├── evaluator.ts    (generated)
│       ├── path-extractor.ts (generated)
│       ├── ask-prompt.ts   (generated)
│       ├── session-state.ts (generated)
│       └── package.json    (generated)
|       |- config.jsonc (the JSONC schema)
```

**4. After applying:**

```bash
sudo nixos-rebuild switch --flake .#pc
# Then verify:
ls -la ~/.pi/agent/extensions/permission-gate/
cat ~/.config/pi-permissions/rules.jsonc
# Start pi and check:
pi
# Inside pi, run:
/permissions status
```

---

### Implementation Notes and Edge Cases

1. **Pipe safety:** `tool_call` handlers are `async` and the `ctx.ui.custom()` call suspends the handler until the user responds. `pi`'s extension runner correctly awaits async `tool_call` handlers before allowing the tool to execute.

2. **`event.input` mutation for bash:** When the user selects "Custom replacement" for a bash command, set `(event.input as any).command = userProvidedCommand`. This mutates the argument object that `pi` will pass to the bash tool.

3. **Re-entrant calls:** If the user triggers a second tool call while an `ask` prompt is open (theoretically impossible in single-agent mode, but possible with subagents), the second prompt will stack. The implementation should handle this by serializing prompts via a `Promise` queue if needed.

4. **Nix store symlinks:** The `isWithinBoundary` function MUST NOT use `fs.realpathSync` because paths in the Nix store are often accessed via `/run/current-system/sw/...` symlinks that point into the store. Use logical path comparison only.

5. **Home-manager symlinks:** The extension directory itself is a symlink from `~/.pi/agent/extensions/permission-gate` → `$DOTFILES/home/modules/pi/extensions/permission-gate`. The `node_modules/` directory will live inside the **symlink target** (the dotfiles repo), which is intentional — it makes `node_modules` part of the reproducible source.

6. **JSONC reload without process restart:** The `/permissions reload` command calls `loadConfig()` and replaces the module-level `config` variable. Because `pi` runs everything in the same process, the new config takes effect immediately on the next `tool_call` event.

7. **Error reporting to the LLM:** When a tool is blocked, the `reason` string is returned to the LLM as a tool error. Set `reportDenyReasonToLLM: true` in the config to include the matched rule; set to `false` for minimal information leakage.

8. **The `ctx.ui.onTerminalInput` cleanup:** Always call the returned cleanup function from `onTerminalInput` when the prompt is dismissed, to prevent memory leaks and key event conflicts.

---

### Quality Requirements

- All TypeScript types must be strict (`noImplicitAny`, proper interface usage).
- No `any` casts except where the `pi` API types require them (session entry `data` field).
- All regex patterns from the JSONC config must be compiled once (cache `RegExp` objects) and handle invalid patterns gracefully (log a warning, treat as no-match).
- The JSONC parser must handle `//` line comments and `/* */` block comments.
- `extractPaths` must handle empty commands, single-token commands, and commands with no path arguments without crashing.
- The TUI component must handle terminal resize gracefully (re-render on size change).
- The audit log write must never throw or block the `tool_call` handler — wrap in try/catch.

---

*End of prompt.*

---

*End of Document 2.*
