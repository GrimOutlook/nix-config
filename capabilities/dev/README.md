# Development Capabilities

Handles installation of general programming applications and dependencies.

Pi (`host.dev.ai.pi.enable`) enables the permission-reviewer extension by default.
It uses the selected Pi model, low reasoning, auditing, and manual approval for
questionable calls. Use `/permission-reviewer manual|deny|status|reset` to change
or inspect the session's escalation policy. To disable the extension entirely,
set `host.dev.ai.pi.permissionReviewer.enable = false`; to choose a persistent
fail-closed escalation policy, set `host.dev.ai.pi.permissionReviewer.escalationMode = "deny"`.
The OpenCode plugin and Pi extension share a single locked source build.

Pi also configures Playwright MCP to attach to a dedicated Chromium profile.
After activation, run `pi-browser https://www.youtube.com/playlist?list=WL`,
sign in yourself, and keep that window open while using Pi's browser tools.
The launcher persists the profile under `${XDG_CONFIG_HOME:-$HOME/.config}/pi-browser`
and exposes CDP only on loopback port 9222. Never expose that port to the network:
it grants control of the logged-in browser. Run `/reload` in existing Pi sessions
and check `/mcp` for the Playwright connection. Login data stays in your home
profile, not in the Nix store. Home Manager owns the MCP configuration; edit this
module rather than running `pi mcp add`. Playwright remains configured when the
reverse-engineering toolkit is disabled.

Pi also installs a reverse-engineering toolkit: Ghidra with the GhidraMCP
extension, radare2, binutils, file, GDB, strace, ltrace, patchelf, elfutils and
xxd. Both MCP servers are built from hash-pinned sources; no runtime `uvx`,
`r2pm`, or network installation is needed. Home Manager manages
`~/.pi/agent/mcp.json` with local stdio entries for both servers. Back up/merge
any pre-existing MCP configuration before activation (Home Manager will not
silently overwrite an unmanaged file).

For Ghidra, launch `ghidra`, open a binary in CodeBrowser, and enable
`GhidraMCPPlugin` under File → Configure → Developer. The bridge targets
`http://127.0.0.1:8080/`; keep the plugin bound to loopback. The bridge can
connect to Pi before Ghidra is running, but analysis calls require the open
CodeBrowser and enabled plugin. Radare2 runs directly over stdio with no
listening service. After activation, run `pi mcp list` and `/reload` in existing
Pi sessions. These tools can modify binaries/projects; analyze untrusted files
in an isolated environment and retain the permission reviewer.

To omit the toolkit and both MCP entries while keeping Pi, set
`host.dev.ai.pi.reverseEngineering.enable = false`.
The Ghidra Python bridge's MCP lower bound is relaxed to the site's pinned
MCP v1 package; its non-headless upstream tests run during the Nix build.
Headless PyGhidra operation is not configured.
