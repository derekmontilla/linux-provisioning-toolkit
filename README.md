# Linux Provisioning Toolkit

A Bash and Python toolkit that provisions a Linux development workstation from a single command, replacing manual setup with a repeatable, automated process.

## What it does

`DotSetup.sh` runs four tasks in order, with strict error handling (`errexit`, `pipefail`, `nounset`):

1. **Local bin + PATH:** symlinks `bin/` to `~/bin`, adds it to `PATH` in `.bashrc` only if it is not already there, and verifies the setup by running a test script.
2. **Isolated Python environment:** downloads and installs Miniconda silently, creates a Python 3.11 environment, installs the libraries in `requirements.txt` from conda-forge, and verifies the imports with `task2.py`.
3. **System packages:** reads `packages.txt`, installs each package with `apt` (skipping blanks and comments), then verifies every install with `dpkg` and reports its version.
4. **System report:** `task4.py` generates an OS, CPU, memory, and storage report using `platform`, `/proc`, and `shutil`, with error handling and proper exit codes.

## Usage

```bash
git clone https://github.com/derekmontilla/linux-provisioning-toolkit.git
cd linux-provisioning-toolkit
chmod +x DotSetup.sh
./DotSetup.sh
```

> ⚠️ The script replaces any existing `~/bin` and `~/miniconda` folders and uses `sudo` to install packages. Run it on a fresh or test machine.

## Files

| File | Purpose |
|---|---|
| `DotSetup.sh` | Main driver script |
| `bin/hello_local_bin` | Test script that confirms `~/bin` is on the PATH |
| `requirements.txt` | Python libraries: pandas, lxml, beautifulsoup4, requests |
| `task2.py` | Verifies the Python libraries load correctly |
| `packages.txt` | apt packages: doxygen, sqlite3, tree, htop |
| `task4.py` | System and hardware report |

## Built with

Bash · Python · Miniconda · apt / dpkg · Git · Ubuntu (WSL2)
