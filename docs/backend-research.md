# Back-end research: open-source projects that fit Blackwall

Checked 2026-11-16. This file records which public GitHub projects match the goals in the root
`README.md`, and whether each one is safe and trustworthy to learn from.

> **Decision (2026-11-16):** Blackwall's code is written by us from scratch on documented Windows
> APIs. No code is copied from these projects; they are studied for ideas only. Where the table
> below says "Use", read it as "the approach we'll reimplement ourselves". Any third-party
> library we later decide to depend on gets its own explicit decision first.

## How the projects were vetted

Everything was done **read-only through GitHub's web APIs**. Nothing was cloned, built, installed or run.

1. **Fit** with the README modules: protected file control, process/agent tracking, command-line
   protection, approvals, audit log and recovery.
2. **Authenticity**: owned by the real organisation or author (not a fork, copy or look-alike name),
   age, and how many people watch and contribute.
3. **Maintenance**: last commit, archived or not, open issues.
4. **Committed binaries**: every `.exe/.dll/.sys/.bin/.zip/.cab/...` in the source tree was listed
   and explained. Opaque binaries can hide code that nobody reviews.
5. **Hidden downloads and obfuscation**: every build and install script (`.ps1 .cmd .bat .sh .py`,
   `build.rs`, `CMakeLists.txt`, `.vcxproj`, `.targets`, installer scripts) was downloaded as plain
   text and searched for Defender tampering, Base64/encoded PowerShell, `iex`/pipe-to-shell,
   LOLBins (`certutil`, `mshta`, `rundll32`...), autorun persistence, downloads and long encoded blobs.
   Every hit was read in context.
6. **Licence** compatibility with Blackwall's licence (GPL-3.0 when this was written; closed-source
   freeware from 0.2.0, see below).

**Limits:** a text scan cannot prove a project is clean. It catches hidden downloaders, droppers
and obfuscated scripts, but not malicious logic written in ordinary-looking source code. Compiled
libraries and test samples were not reverse engineered. See "Safe use" below.

Projects built to *evade* antivirus were excluded on purpose. They are attacker tooling and
don't fit a protection product.

## Results

| Project | Who | Activity | Committed binaries | Script findings | Licence | Verdict |
|---|---|---|---|---|---|---|
| [microsoft/krabsetw](https://github.com/microsoft/krabsetw) | Microsoft org, since 2016 | active | 2× `NuGet.exe` (old NuGet bootstrap) | NuGet bootstrap download; build step only generates a strong-name key | MIT | **Use** for Phase 1 ETW monitoring (NuGet `Microsoft.O365.Security.ETW` 5.x) |
| [microsoft/Windows-driver-samples](https://github.com/microsoft/Windows-driver-samples) — `filesys/miniFilter/scanner`, `avscan` | Microsoft org, since 2015 | active | none in the minifilter folders | none in the minifilter folders | MS-PL | **Reference** for Phase 3 driver |
| [VirusTotal/yara-x](https://github.com/VirusTotal/yara-x) | VirusTotal org | active | 156 zipped test files (real file-format samples) | `pkg-config` lookup in `build.rs` | BSD-3-Clause | **Use later** for file scanning |
| [rabbitstack/fibratus](https://github.com/rabbitstack/fibratus) | single author, since 2016, 2.5k★ | active | test fixtures: shellcode, process-hollowing EXE, vulnerable drivers | release build fetches embedded Python; installer checks SHA-256 **and** Authenticode | Apache-2.0 | **Reference** for rule engine and ETW design |
| [Karib0u/rustinel](https://github.com/Karib0u/rustinel) | single author, **created 2026-01** | active | one tiny test `.tar.gz` | installers download their own releases and verify checksums | Apache-2.0 | **Reference**, lower trust (young project) |
| [winsiderss/systeminformer](https://github.com/winsiderss/systeminformer) | Winsider org, since 2016, 16k★ | active | its own signed kernel driver and signing tools (by design) | none in build scripts | MIT | **Reference** for process identity and signature checks |
| [sandboxie-plus/Sandboxie](https://github.com/sandboxie-plus/Sandboxie) | Sandboxie-Plus org, 20k★ | active | `yasm.exe` build tool, update zip | build scripts fetch Qt, OpenSSL, 7-Zip from GitHub; some with `--ssl-no-revoke` and no hash check | GPL-3.0 | **Reference** for isolating agents |
| [RafWu/RansomWatch](https://github.com/RafWu/RansomWatch) | two students, 93★ | **stale since 2020** | none | none | MIT (stated in README, no LICENSE file) | **Ideas only**: process groups, entropy, trap files |
| [0xrawsec/whids](https://github.com/0xrawsec/whids) | org, 1.3k★ | **stale since 2023-02** | none | build fetches rules from the author's own repo with a SHA-256 file | AGPL-3.0 | **Reference** only |
| [SigmaHQ/sigma](https://github.com/SigmaHQ/sigma) | SigmaHQ org, 11k★ | active | none | test scripts download sample event logs | rules: DRL 1.1 (attribution required) | **Use** the rule format; credit if we ship rules |
| [Cisco-Talos/clamav](https://github.com/Cisco-Talos/clamav) | Cisco Talos org, since 2012 | active | malformed CAB/ISO/PE test files (CVE reproductions) | dev containers install Rust via `rustup \| sh` (standard) | GPL-2.0-only | **Optional** as a separate `clamd` process; never link it into Blackwall |
| [ComodoSecurity/openedr](https://github.com/ComodoSecurity/openedr) | Comodo org | slow | **208 prebuilt `.lib` + 208 `.pdb`** (opaque Boost/AWS builds), EXEs that are only LFS pointers | not scanned in full (53,700 files) | **Comodo "available source" licence (CASL)**, not open source | **Avoid** |

No project showed Defender tampering, encoded PowerShell, hidden autorun persistence or
obfuscated payloads in its scripts.

## Things to watch

- **Your antivirus will flag some of these repos, and that is expected.** Fibratus, YARA-X and
  ClamAV deliberately include malicious or malformed samples (shellcode, hollowing EXEs,
  vulnerable drivers, crafted CABs) to test their detection. Never run those files. If we clone
  one, do it in a VM, or check out only the folders we need.
- **Don't install anything with `irm ... | iex` or `curl ... | sh`**, even though Fibratus and
  Rustinel suggest it. Download the release, check the SHA-256 against the published checksum, and
  check the signature with `Get-AuthenticodeSignature`.
- **Licences** (Blackwall is closed-source freeware from 0.2.0):
  - MIT, BSD and Apache-2.0 code can go into Blackwall, as long as its notice ships in
    `THIRD-PARTY-NOTICES.txt` (Apache-2.0 also needs its NOTICE file, if any).
  - GPL, AGPL and LGPL-static code can't go in at all: it would require publishing Blackwall's source.
    Sandboxie (GPL-3.0) and WHIDS (AGPL-3.0) stay references for ideas only.
  - MS-PL (the driver samples) allows closed-source use, but MS-PL code must keep its licence text and
    can't be relicensed. Studying it and writing our own driver avoids the question.
  - GPL-2.0-only (ClamAV) could only run as a separate program Blackwall talks to, never linked in.
  - The Elastic detection rules (Elastic License 2.0) and OpenEDR (CASL) are not compatible.

## What this means for the back-end

Phase 1 in the README is a **user-mode** service. From the research:

1. **Process tracking** (launch chain, command lines): ETW, `Microsoft-Windows-Kernel-Process`
   provider, consumed through krabsetw's pure .NET package. That plugs straight into the existing
   `IBlackwallService` and process tree in the client.
2. **File activity on protected folders**: ETW `Microsoft-Windows-Kernel-File`. This can **observe
   and record** changes, but **cannot block or hold them for approval**. Only a minifilter
   (Phase 3, based on the `scanner`/`avscan` samples) can pause an operation until you answer.
   Until then, an "approval" in Phase 1 can only alert you, or roll the file back from a saved version.
3. **Identity**: SHA-256 of the image plus Authenticode signer via `WinVerifyTrust`, as System
   Informer does.
4. **Later**: YARA-X scanning, Sigma-style behaviour rules (Fibratus as the design reference), and
   ransomware heuristics from RansomWatch (process groups, write entropy, trap files).

## Safe use from here on

- Pin dependencies to an exact version or commit, never "latest".
- Prefer official packages from verified publishers (NuGet `Microsoft.O365.Security.ETW`,
  crates.io `yara-x`) over copying source.
- Build or try third-party tools only in a VM, with Microsoft Defender left on.
- Re-run this check before adding any new project.
