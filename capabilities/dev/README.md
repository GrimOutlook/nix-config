# Development Capabilities

Handles installation of general programming applications and dependencies.

Pi (`host.dev.ai.pi.enable`) enables the permission-reviewer extension by default.
It uses the selected Pi model, low reasoning, auditing, and manual approval for
questionable calls. Use `/permission-reviewer manual|deny|status|reset` to change
or inspect the session's escalation policy. To disable the extension entirely,
set `host.dev.ai.pi.permissionReviewer.enable = false`; to choose a persistent
fail-closed escalation policy, set `host.dev.ai.pi.permissionReviewer.escalationMode = "deny"`.
The OpenCode plugin and Pi extension share a single locked source build.
