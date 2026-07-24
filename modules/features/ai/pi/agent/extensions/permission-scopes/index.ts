/**
 * Permission Scopes Extension
 *
 * A regex-based, two-axis permission system for Pi tool calls.
 *
 * Two independent matching axes:
 *   1. Scope axis — path-based classification (cwd, nix_store, outside, or user-defined)
 *      Each scope defines read/write/edit/bash rules for paths within it.
 *   2. Bash patterns axis — a global flat list of { regex, action } pairs evaluated
 *      against the full command string, independent of path scope.
 *
 * When multiple axes produce different outcomes, the most restrictive wins:
 *   deny > ask > allow
 *
 * Bash commands with paths spanning multiple scopes require ALL scopes' bash rules
 * to allow the command. If any scope denies, the command is denied.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// ============================================================================
// Types
// ============================================================================

type Action = "allow" | "deny" | "ask";

interface BashRule {
  regex: string;
  action: Action;
}

interface ScopeRules {
  read?: Action;
  write?: Action;
  edit?: Action;
  bash?: (string | BashRule)[];
}

interface Config {
  debugLog: boolean;
  bash_patterns?: BashRule[];
  scope_definitions: Record<string, string>;
  templates: Record<string, BashRule[]>;
  scopes: Record<string, ScopeRules>;
}

interface ResolvedScopeRules {
  read: Action;
  write: Action;
  edit: Action;
  bash: BashRule[];
}

// ============================================================================
// State
// ============================================================================

interface SessionOverride {
  action: "allow" | "replace";
  replacement?: string;
}

// Key: "command" for bash, "tool:path" for read/write/edit
const sessionOverrides = new Map<string, SessionOverride>();

// Compiled regex cache: regex string -> RegExp
const regexCache = new Map<string, RegExp>();

// Config cache with mtime tracking
let config: Config | null = null;
let resolvedRules: Record<string, ResolvedScopeRules> | null = null;
let configPath = "";
let lastMtime = 0;

// Resolve extension directory: __dirname works with jiti
const EXTENSION_DIR = __dirname;

// ============================================================================
// Config Loading & Resolution
// ============================================================================

function loadConfig(cwd: string): Config {
  // Priority: project-local config > extension directory config
  const configCandidates = [
    // Project-local: <cwd>/.pi/extensions/permission-scopes/config.json
    path.join(cwd, ".pi", "extensions", "permission-scopes", "config.json"),
    // Extension directory: same dir as this extension's index.ts
    path.join(EXTENSION_DIR, "config.json"),
  ];

  for (const candidate of configCandidates) {
    if (fs.existsSync(candidate)) {
      return JSON.parse(fs.readFileSync(candidate, "utf-8"));
    }
  }

  throw new Error(
    "permission-scopes: config.json not found. Place it in either: " +
      `<cwd>/.pi/extensions/permission-scopes/config.json` +
      ` or the extension directory ${EXTENSION_DIR}/config.json`
  );
}

function resolveTemplates(cfg: Config): Record<string, ResolvedScopeRules> {
  const resolved: Record<string, ResolvedScopeRules> = {};

  for (const [scopeName, scopeRules] of Object.entries(cfg.scopes)) {
    const read = scopeRules.read ?? "deny";
    const write = scopeRules.write ?? "deny";
    const edit = scopeRules.edit ?? "deny";

    let bashRules: BashRule[] = [];
    if (scopeRules.bash) {
      for (const item of scopeRules.bash) {
        if (typeof item === "string") {
          if (!item.startsWith("$")) {
            throw new Error(
              `permission-scopes: Invalid template reference "${item}" in scope "${scopeName}" (must start with $)`
            );
          }
          const templateName = item.slice(1);
          const template = cfg.templates[templateName];
          if (!template) {
            throw new Error(
              `permission-scopes: Template "${templateName}" not found (referenced by scope "${scopeName}")`
            );
          }
          bashRules.push(...template);
        } else {
          bashRules.push(item);
        }
      }
    }

    resolved[scopeName] = { read, write, edit, bash: bashRules };
  }

  // Ensure built-in scopes exist
  if (!resolved["cwd"]) {
    resolved["cwd"] = { read: "deny", write: "deny", edit: "deny", bash: [] };
  }
  if (!resolved["outside"]) {
    resolved["outside"] = { read: "deny", write: "deny", edit: "deny", bash: [] };
  }

  return resolved;
}

// ============================================================================
// Path Classification
// ============================================================================

function resolvePath(filePath: string, cwd: string): string {
  if (filePath.startsWith("~")) {
    const home = process.env.HOME || "";
    return path.join(home, filePath.slice(1));
  }
  if (path.isAbsolute(filePath)) {
    return filePath;
  }
  return path.resolve(cwd, filePath);
}

function classifyPath(filePath: string, cfg: Config, cwd: string): string {
  const absPath = resolvePath(filePath, cwd);

  // Check if under cwd
  const cwdNorm = path.normalize(cwd);
  if (absPath === cwdNorm || absPath.startsWith(cwdNorm + path.sep)) {
    return "cwd";
  }

  // Check user-defined scope definitions (longest prefix match)
  let bestMatch: { scope: string; prefix: string } | null = null;
  for (const [scope, prefix] of Object.entries(cfg.scope_definitions)) {
    const normPrefix = path.normalize(prefix);
    if (absPath === normPrefix || absPath.startsWith(normPrefix + path.sep)) {
      if (!bestMatch || normPrefix.length > bestMatch.prefix.length) {
        bestMatch = { scope, prefix: normPrefix };
      }
    }
  }
  if (bestMatch) {
    return bestMatch.scope;
  }

  return "outside";
}

// ============================================================================
// Bash Path Extraction
// ============================================================================

function extractPathsFromCommand(cmd: string, cwd: string): string[] {
  const tokens: string[] = [];
  let current = "";
  let inSingleQuote = false;
  let inDoubleQuote = false;
  let escape = false;

  for (let i = 0; i < cmd.length; i++) {
    const ch = cmd[i];
    if (escape) {
      current += ch;
      escape = false;
      continue;
    }
    if (ch === "\\") {
      escape = true;
      continue;
    }
    if (inSingleQuote) {
      if (ch === "'") {
        inSingleQuote = false;
      } else {
        current += ch;
      }
      continue;
    }
    if (inDoubleQuote) {
      if (ch === '"') {
        inDoubleQuote = false;
      } else {
        current += ch;
      }
      continue;
    }
    if (ch === "'") {
      inSingleQuote = true;
      continue;
    }
    if (ch === '"') {
      inDoubleQuote = true;
      continue;
    }
    if (ch === " " || ch === "\t" || ch === "\n") {
      if (current) {
        tokens.push(current);
        current = "";
      }
      continue;
    }
    if ("|&;<>()$`".includes(ch)) {
      if (current) {
        tokens.push(current);
        current = "";
      }
      continue;
    }
    current += ch;
  }
  if (current) {
    tokens.push(current);
  }

  const paths: string[] = [];
  for (const token of tokens) {
    if (/^[~/.]/.test(token) || token.startsWith("./") || token.startsWith("../")) {
      const cleaned = token.replace(/[,;]$/, "");
      paths.push(cleaned);
    }
  }
  return paths;
}

// ============================================================================
// Bash Rule Evaluation
// ============================================================================

function getCompiledRegex(rule: BashRule): RegExp | null {
  if (regexCache.has(rule.regex)) {
    return regexCache.get(rule.regex)!;
  }
  try {
    const re = new RegExp(rule.regex);
    regexCache.set(rule.regex, re);
    return re;
  } catch {
    return null;
  }
}

function evaluateBashRules(rules: BashRule[], command: string): Action {
  let result: Action = "deny";
  for (const rule of rules) {
    const re = getCompiledRegex(rule);
    if (re && re.test(command)) {
      result = rule.action;
    }
  }
  return result;
}

// ============================================================================
// Scope Axis Evaluation
// ============================================================================

function combineActions(a: Action, b: Action): Action {
  const order: Record<Action, number> = { allow: 0, ask: 1, deny: 2 };
  return order[a] >= order[b] ? a : b;
}

function evaluateScopeAxis(
  toolName: string,
  command: string,
  paths: string[],
  cfg: Config,
  resolved: Record<string, ResolvedScopeRules>,
  cwd: string
): Action {
  if (paths.length === 0) {
    return "allow";
  }

  let overall: Action = "allow";
  for (const p of paths) {
    const scope = classifyPath(p, cfg, cwd);
    const rules = resolved[scope];
    if (!rules) {
      return "deny";
    }

    let action: Action;
    if (toolName === "bash") {
      // For bash, evaluate the scope's bash rules against the full command string
      action = evaluateBashRules(rules.bash, command);
    } else {
      // read/write/edit — use the scope's action for that tool
      action = rules[toolName as "read" | "write" | "edit"] ?? "deny";
    }
    overall = combineActions(overall, action);
  }
  return overall;
}

// ============================================================================
// Bash Patterns Axis (global, path-independent)
// ============================================================================

function evaluateBashPatternsAxis(command: string, cfg: Config): Action {
  const globalPatterns = cfg.bash_patterns;
  if (!globalPatterns || globalPatterns.length === 0) {
    return "ask"; // default if no global rules
  }
  return evaluateBashRules(globalPatterns, command);
}

// ============================================================================
// Session Override Key
// ============================================================================

function getOverrideKey(toolName: string, input: any): string {
  if (toolName === "bash") {
    return "bash:" + input.command;
  }
  return toolName + ":" + input.path;
}

// ============================================================================
// Main Decision Logic
// ============================================================================

function decidePermission(
  toolName: string,
  input: any,
  cfg: Config,
  resolved: Record<string, ResolvedScopeRules>,
  cwd: string
): { action: Action; reason: string; paths: string[] } {
  const command = toolName === "bash" ? input.command : "";

  let paths: string[] = [];
  if (toolName === "bash") {
    paths = extractPathsFromCommand(command, cwd);
  } else {
    if (input.path) {
      paths = [input.path];
    }
  }

  // Scope axis
  const scopeAction = evaluateScopeAxis(toolName, command, paths, cfg, resolved, cwd);

  // Bash patterns axis (only for bash)
  let bashPatternsAction: Action;
  if (toolName === "bash") {
    bashPatternsAction = evaluateBashPatternsAxis(command, cfg);
  } else {
    bashPatternsAction = "allow"; // non-bash tools don't use bash patterns
  }

  // Combine: most restrictive
  const finalAction = combineActions(scopeAction, bashPatternsAction);

  return { action: finalAction, reason: `Scope: ${scopeAction}, BashPatterns: ${bashPatternsAction}`, paths };
}

// ============================================================================
// User Prompting
// ============================================================================

async function promptUser(
  ctx: any,
  toolName: string,
  input: any,
  action: Action,
  reason: string
): Promise<{
  decision: "allow" | "deny" | "replace";
  replacement?: string;
  reason?: string;
  session?: boolean; // true if user chose "override for session"
}> {
  const isDeny = action === "deny";
  const title = isDeny ? "⛔ DENY" : "⏸ ASK";
  const desc =
    toolName === "bash"
      ? `bash: ${input.command}`
      : `${toolName}: ${input.path}`;

  if (!ctx.hasUI) {
    // In non-interactive mode, deny by default for deny/ask
    return { decision: "deny", reason: "Permission blocked (no UI for confirmation)" };
  }

  const message = `${title} Permission required for ${desc}
Reason: ${reason}

Choose action:`;

  const choices: string[] = ["Override once", "Override for session", "Deny (with reason)", "Custom replacement (with reason)"];
  const choice = await ctx.ui.select(message, choices);

  if (!choice) {
    return { decision: "deny", reason: "User cancelled" };
  }

  if (choice === "Override once") {
    return { decision: "allow" };
  }

  if (choice === "Override for session") {
    // Return a flag so the caller can store in sessionOverrides
    return { decision: "allow", session: true };
  }

  if (choice === "Deny (with reason)") {
    const reason = await ctx.ui.input("Enter reason for denial:");
    return { decision: "deny", reason: reason || "No reason given" };
  }

  if (choice === "Custom replacement (with reason)") {
    const replacement = await ctx.ui.input("Enter replacement command:");
    const reason = await ctx.ui.input("Enter reason for replacement:");
    if (!replacement) {
      return { decision: "deny", reason: "No replacement provided" };
    }
    return { decision: "replace", replacement, reason: reason || "No reason given" };
  }

  return { decision: "deny", reason: "Invalid choice" };
}

// ============================================================================
// Config Reload
// ============================================================================

function reloadConfigIfChanged(ctx: any): void {
  try {
    if (!configPath || !fs.existsSync(configPath)) return;
    const stat = fs.statSync(configPath);
    if (stat.mtimeMs > lastMtime) {
      lastMtime = stat.mtimeMs;
      config = loadConfig(ctx.cwd);
      resolvedRules = resolveTemplates(config);
      if (config.debugLog) {
        ctx.ui.notify("Permission-scopes config reloaded", "info");
      }
    }
  } catch (e) {
    // Config load error — keep old config or fail gracefully
    if (e instanceof Error && !config) {
      ctx.ui.notify(`permission-scopes: Failed to load config: ${e.message}`, "error");
    }
  }
}

// ============================================================================
// Extension Entry Point
// ============================================================================

export default function (pi: ExtensionAPI) {
  // Load config on startup
  function initialLoad() {
    try {
      config = loadConfig(pi.cwd);
      resolvedRules = resolveTemplates(config);
    } catch (e) {
      if (e instanceof Error) {
        console.error(`permission-scopes: ${e.message}`);
      }
    }
  }

  pi.on("session_start", (event, ctx) => {
    if (configPath && fs.existsSync(configPath)) {
      // Check if config changed during shutdown/startup
      try {
        const stat = fs.statSync(configPath);
        if (stat.mtimeMs > lastMtime) {
          config = loadConfig(ctx.cwd);
          resolvedRules = resolveTemplates(config);
          lastMtime = stat.mtimeMs;
        }
      } catch {
        // Config file changed, ignore — will re-resolve in tool_call
      }
    }
  });

  pi.on("session_shutdown", (event, _ctx) => {
    // Clear session overrides when session ends
    sessionOverrides.clear();
    regexCache.clear();
  });

  pi.on("tool_call", async (event, ctx) => {
    // Only handle tools we care about
    const toolName = event.toolName;
    if (!["read", "write", "edit", "bash"].includes(toolName)) {
      return;
    }

    const input = event.input;

    // Ensure config is loaded
    if (!config || !resolvedRules) {
      try {
        config = loadConfig(ctx.cwd);
        resolvedRules = resolveTemplates(config);
        // Remember which config file we loaded
        const candidates = [
          path.join(ctx.cwd, ".pi", "extensions", "permission-scopes", "config.json"),
          path.join(EXTENSION_DIR, "config.json"),
        ];
        configPath = candidates.find(fs.existsSync) ?? "";
      } catch (e) {
        if (e instanceof Error) {
          ctx.ui.notify(`permission-scopes: ${e.message}`, "warning");
        }
        return; // No config — allow by default
      }
    } else {
      // Check for config changes
      reloadConfigIfChanged(ctx);
      if (!config || !resolvedRules) return;
    }

    // Check session overrides
    const overrideKey = getOverrideKey(toolName, input);
    const override = sessionOverrides.get(overrideKey);
    if (override) {
      if (override.action === "allow") {
        return; // Allow without further checking
      }
      if (override.action === "replace" && override.replacement) {
        if (toolName === "bash") {
          event.input.command = override.replacement;
        }
        return;
      }
    }

    // Evaluate permissions
    const { action, reason } = decidePermission(
      toolName,
      input,
      config,
      resolvedRules,
      ctx.cwd
    );

    if (action === "allow") {
      return; // Allow
    }

    // Prompt user for deny/ask actions
    const result = await promptUser(ctx, toolName, input, action, reason);

    if (result.decision === "allow") {
      if (result.session) {
        // Store session override
        sessionOverrides.set(overrideKey, { action: "allow" });
      }
      return;
    }

    if (result.decision === "replace") {
      if (result.replacement) {
        if (toolName === "bash") {
          event.input.command = result.replacement;
          // Store session override for replacement too
          sessionOverrides.set(overrideKey, { action: "replace", replacement: result.replacement });
        } else {
          return { block: true, reason: result.reason ?? "Replacement only supported for bash commands" };
        }
      } else {
        return { block: true, reason: result.reason ?? "No replacement provided" };
      }
      return;
    }

    // Denied
    return { block: true, reason: result.reason ?? "Permission denied" };
  });
}
