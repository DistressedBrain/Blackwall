# Changelog

Each release on GitHub uses the section for its version as its release notes; Blackwall shows them
under Settings → Updates. Newest first. Versions follow `MAJOR.MINOR.PATCH`.

## 0.2.0

- **Real protection engine.** Protected folders, your rules, approvals and the activity log now work on
  real data; the sample data only appears with `Blackwall.exe --demo`.
- **Blackwall service.** Runs the engine as a Windows service and sees which program made each change.
  Without it, the engine runs inside the app.
- **Deny undoes.** Until the kernel driver exists, a change you deny (or don't answer) is put back from
  a saved version. **Undo this change…** in Activity does the same later.
- **Launch rules.** A program matching a block rule is ended right after it starts.
- **Updates.** Blackwall checks GitHub for new versions and shows what changed; you choose when to install.
- Security: only the Blackwall app, not started by an AI agent, may change protection through the service.
  The app in turn only talks to the real Blackwall service, never a program pretending to be it.

## 0.1.0

- Desktop client preview: overview, security status, approvals, protected locations, activity, processes,
  quarantine vault, hidden files, rules, kernel page and settings, on sample data.
