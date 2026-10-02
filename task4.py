#!/usr/bin/env python3

import os
import platform
import shutil
import subprocess
import sys


def run(command):
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except OSError:
        return None


def banner(title):
    print()
    print(title)
    print("-" * 60)


def row(label, value):
    print(f"  {label:<22} {value}")


def os_information():
    banner("OPERATING SYSTEM")
    row("System", platform.system())
    row("Release", platform.release())
    row("Version", platform.version())
    row("Platform", platform.platform())
    row("Hostname", platform.node())
    row("Python Version", platform.python_version())

    distro = run("grep '^PRETTY_NAME=' /etc/os-release | cut -d'\"' -f2")
    if distro:
        row("Distribution", distro)


def cpu_information():
    banner("PROCESSOR")
    row("Machine", platform.machine())
    row("Architecture", platform.architecture()[0])
    row("Processor", platform.processor() or "unknown")
    row("Logical Cores", os.cpu_count())

    model = run("grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2")
    if model:
        row("Model Name", model)


def memory_information():
    banner("MEMORY")
    try:
        with open("/proc/meminfo", "r", encoding="utf-8") as meminfo:
            values = {}
            for line in meminfo:
                key, _, rest = line.partition(":")
                values[key] = int(rest.split()[0])  # value is in kB

        row("Total RAM", f"{values['MemTotal'] / 1024 ** 2:.2f} GB")
        row("Available RAM", f"{values['MemAvailable'] / 1024 ** 2:.2f} GB")
        row("Total Swap", f"{values['SwapTotal'] / 1024 ** 2:.2f} GB")
    except (OSError, KeyError, ValueError):
        row("Memory", "not available on this platform")


def disk_information():
    banner("STORAGE")
    total, used, free = shutil.disk_usage("/")
    row("Total Disk", f"{total / 1024 ** 3:.2f} GB")
    row("Used Disk", f"{used / 1024 ** 3:.2f} GB")
    row("Free Disk", f"{free / 1024 ** 3:.2f} GB")
    row("Percent Used", f"{used / total * 100:.1f}%")


def main():
    print("=" * 60)
    print("  SYSTEM AND HARDWARE REPORT")
    print("=" * 60)

    try:
        os_information()
        cpu_information()
        memory_information()
        disk_information()
    except Exception as error: 
        print(f"ERROR: could not complete the report: {error}", file=sys.stderr)
        return 1

    print()
    print("=" * 60)
    return 0


if __name__ == "__main__":
    sys.exit(main())