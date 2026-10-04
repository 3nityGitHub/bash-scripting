# Bash Scripting — Linux Administration & Application Deployment

A progressive set of nine bash scripting projects, moving from core Linux
command-line skills through process management to a **production-shaped
deployment script** that installs a runtime, pulls a build artifact, configures
it via environment variables, and runs it as a dedicated, least-privilege
service user.

Built and tested on **Ubuntu 26.04 LTS (ARM64)** in a UTM virtual machine,
managed over SSH, with every script version-controlled here.

---

## What this repo demonstrates

- **Linux fundamentals:** navigation, file management, permissions, ownership, users & groups
- **Bash scripting:** variables, conditionals (`if`/`elif`/`else`, nested), loops, `set -e`/`set -u`, `&&`/`||`
- **Text processing:** `grep`, `awk` (field extraction & version parsing), `sort`, `head`
- **Process management:** `ps`, `kill`/`pkill`, `ss`, backgrounding with `&`
- **Real deployment:** runtime install, artifact download, `tar`, environment-variable config, background execution, status verification
- **Security / least privilege:** dedicated service user, `sudo -u`, ownership (`chown`), safe file locations (`/opt`)
- **Operational robustness:** idempotent scripts, readiness waits, input validation, troubleshooting

---

## The projects

### 1 — Linux VM investigation
Provision a Linux VM and investigate it: distribution and family, package
manager, available editors, and configured shell.
**Skills:** `cat /etc/os-release`, `which`, `echo $SHELL`, distro families (Debian vs Red Hat).

### 2 — Install Java with version checks (`install-java.sh`)
Install Java, then verify it three ways: whether it's installed at all, whether
it's below version 11, or whether it's 11+ (success). Parses the version string
out of `java -version` output.
**Skills:** `apt` install, `command -v`, `awk` field extraction (`-F '"'` then `-F '.'`),
numeric comparison (`-ge`), nested conditionals, capturing stderr (`2>&1`).

### 3 — List the current user's processes (`user-process.sh`)
Show all processes for the current user via the `USER` environment variable.
**Skills:** `ps aux`, `grep`, `$USER`, filtering out grep itself (`grep -v grep`).

### 4 — Sort processes by CPU or memory (`sort-process.sh`)
Prompt the user to sort by CPU or memory, then print the sorted list.
**Skills:** `read` for interactive input, `sort -k<col> -rn`, `if`/`elif`/`else`,
knowing the `ps aux` columns (3 = %CPU, 4 = %MEM).

### 5 — Limit number of processes shown (`top-process.sh`)
Additionally ask how many processes to display and limit the output.
**Skills:** `head -n`, using an input value (rather than testing it),
distinguishing data from conditions.

### 6 — Install Node.js and run the app (`start-app.sh`)
Install Node.js and npm, download a pre-built application artifact from object
storage (S3), unzip it, set the required environment variables, install
dependencies, and run the app in the background.
**Skills:** `curl` download, `tar -xzf`, exporting env vars for app config,
backgrounding with `&`, `.gitignore` for generated/downloaded files.

### 7 — Verify the app started and report its port (`start-app.sh`)
After starting the app, confirm the process is running and report the port it's
listening on.
**Skills:** `sleep` (readiness wait), `ps aux | grep`, `ss -tulpn` for
listening ports — a hand-rolled health check.

### 8 — Accept a log directory parameter (`start-app.sh`)
Accept a log directory as a command-line argument, create it if it doesn't
exist, resolve its absolute path, and set `LOG_DIR` so the app writes its logs
there.
**Skills:** script arguments (`$1`), file-test operators (`-d`, `-z`),
`mkdir -p`, dynamic absolute-path resolution, injecting config via env vars.

### 9 — Run the app as a dedicated service user (`start-app.sh`)
Create a `myapp` service user and run the application as that user instead of a
personal account — the least-privilege production pattern.
**Skills:** `useradd` (guarded with `id` for idempotency), `sudo -u`, `chown`,
path **traversal** permissions, hosting the app in a neutral location (`/opt`),
passing env vars across `sudo -u`, process isolation between users.

---

## Key engineering lessons (learned by debugging real failures)

- **Silent failures are the most dangerous.** A typo (`comand` vs `command`)
  combined with `&> /dev/null` produced wrong results with no error. Caught by
  noticing the output contradicted known facts.
- **Clock drift breaks package installs.** A VM clock hours behind caused `apt`
  to reject signed metadata as "not valid yet." Fixed with NTP (`timedatectl set-ntp true`).
- **Idempotency matters.** Re-running the deploy failed on leftover files from a
  previous run; cleaning the target directory first made it safely repeatable.
- **Service users need path *traversal*, not just file ownership.** `MODULE_NOT_FOUND`
  occurred because the app lived inside a home directory the service user couldn't
  enter — the reason production apps live in `/opt` or `/srv`.
- **`sudo -u` resets the environment.** Environment variables had to be passed
  explicitly to reach the service user's process.
- **Process isolation is real.** A regular user cannot kill a service user's
  processes — containment working as intended.

---

## Running the final deployment script

```bash
./start-app.sh /opt/myapp-logs
```

Installs Node.js, fetches and unpacks the artifact into `/opt/myapp`, sets the
required environment variables, creates and owns the log directory, and runs the
app as the `myapp` service user in the background. Verify with:

```bash
ps aux | grep "node server.js" | grep -v grep   # runs as 'myapp'
ss -tulpn | grep node                            # listening on :3000
sudo cat /opt/myapp-logs/app.log                 # application logs
```

---

*Environment: Ubuntu 26.04 LTS (ARM64) · UTM · managed over SSH.
Downloaded artifacts and `node_modules` are intentionally git-ignored.*
