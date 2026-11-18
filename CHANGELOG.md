# Changelog

Each release on GitHub uses the section for its version as its release notes; Blackwall shows them
under Settings → Updates. Newest first. Versions follow `MAJOR.MINOR.PATCH`.

## Unreleased

- **Malware scanning with Microsoft Defender.** Programs started from Downloads or Temp, the scripts and commands AI
  agents run, and new programs in protected folders are checked; malware is stopped or undone.
- **Scans page.** Quick scan (Defender's quick scan plus Downloads and your protected folders), scan any folder, and a
  daily or weekly scheduled scan, with Quarantine for anything found.
- **Ransomware detection.** A program that scrambles many protected files within a minute is ended and everything it
  changed is put back.
- **Network page.** Which programs are online and where, AI agents first; a note when an agent or unsigned program
  goes online for the first time; block a program from the network (Windows Firewall, needs the service).
- **USB drives.** Scanned when plugged in; optionally, programs started from a USB drive are ended unless a rule allows them.
- **Try a program safely** in Windows Sandbox (Windows Pro and up): no network, its folder read-only.
- **Check reputation** of a process's file against CIRCL's public database of known files (only the SHA-256 is sent, after asking).
- **Web protection** (off by default): known malware sites from URLhaus are blocked through the hosts file.

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
- **Licence.** Blackwall is now freeware: free to use at home and at work, all rights reserved.

## 0.1.0

- Desktop client preview: overview, security status, approvals, protected locations, activity, processes,
  quarantine vault, hidden files, rules, kernel page and settings, on sample data.
