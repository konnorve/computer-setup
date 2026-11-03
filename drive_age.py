#!/usr/bin/env python3
"""Read-only file-age report; Python 3.9+, standard library only.

  py drive_age.py                     # all Windows drive letters
  py drive_age.py D:/ E:/             # selected drives (or folders)
  py drive_age.py --csv ages.csv      # also save a new CSV file

Ages use last modification and calendar months, not creation or last access.
Percentages overlap and use files with readable metadata. Root rows count
root files only. Errors count failed operations, not missing files. Links/junctions are
skipped; hard-linked file paths are counted separately. No file contents read.
"""
import argparse
import calendar
import csv
import ctypes
import os
import stat
import sys
from datetime import datetime


def months_ago(now: datetime, months: int) -> float:
    year, month = divmod(now.year * 12 + now.month - 1 - months, 12)
    day = min(now.day, calendar.monthrange(year, month + 1)[1])
    return now.replace(year=year, month=month + 1, day=day).timestamp()


def windows_drives() -> list[str]:
    get_drives = ctypes.WinDLL("kernel32", use_last_error=True).GetLogicalDrives
    get_drives.argtypes = ()
    get_drives.restype = ctypes.c_uint32
    mask = get_drives()
    if not mask:
        raise ctypes.WinError(ctypes.get_last_error())
    return [f"{chr(65 + i)}:\\" for i in range(26) if mask & (1 << i)]


def scan(root: str, cutoffs: list[float]) -> dict:
    # Each row: files, older than 1/6/12 months, errors, skipped links.
    rows = {None: [0] * 6}
    pending = [(root, None)]
    while pending:
        folder, group = pending.pop()
        counts = rows[group]
        if group is None or folder == os.path.join(root, group):
            print(f"Scanning {folder}", file=sys.stderr, flush=True)
        try:
            with os.scandir(folder) as entries:
                for entry in entries:
                    target = counts
                    try:
                        info = entry.stat(follow_symlinks=False)
                        is_dir = stat.S_ISDIR(info.st_mode)
                        child_group = entry.name if group is None and is_dir else group
                        target = rows.setdefault(child_group, [0] * 6)
                        # Windows junctions are directories, not symbolic links.
                        junction = getattr(info, "st_reparse_tag", 0) == 0xA0000003
                        if stat.S_ISLNK(info.st_mode) or junction:
                            target[5] += 1
                        elif is_dir:
                            pending.append((entry.path, child_group))
                        elif stat.S_ISREG(info.st_mode):
                            target[0] += 1
                            for i, cutoff in enumerate(cutoffs, 1):
                                target[i] += info.st_mtime < cutoff
                    except OSError as exc:
                        target[4] += 1
                        print(f"Skipped {entry.path}: {exc}", file=sys.stderr)
        except OSError as exc:
            counts[4] += 1
            print(f"Skipped {folder}: {exc}", file=sys.stderr)
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("roots", nargs="*", help="Drives/folders; default: all Windows drives")
    parser.add_argument("--csv", metavar="FILE", help="Also save CSV; refuses to overwrite")
    args = parser.parse_args()
    if not args.roots and os.name != "nt":
        parser.error("Automatic drive discovery is Windows-only; supply folder paths.")
    if args.csv and os.path.lexists(args.csv):
        parser.error(f"Output already exists: {args.csv}")
    now = datetime.now()
    cutoffs = [months_ago(now, months) for months in (1, 6, 12)]
    print(f"Last-modified age as of {now.isoformat(timespec='seconds')} (local time)")
    print(f"{'Files':>10} {'>1 month':>9} {'>6 months':>9} {'>1 year':>9} "
          f"{'Errors':>7} {'Links':>7}  Folder", flush=True)
    report = []
    for root in dict.fromkeys(os.path.abspath(p) for p in (args.roots or windows_drives())):
        rows = scan(root, cutoffs)
        for group in sorted(rows, key=lambda name: (name is not None, name or "")):
            total, *older, errors, links = rows[group]
            percentages = [f"{100 * n / total:.2f}" if total else "" for n in older]
            path = os.path.join(root, group) if group is not None else root
            report.append([path, total, *percentages, errors, links])
            display = " ".join(f"{p + '%' if p else 'N/A':>9}" for p in percentages)
            label = path + (" (root files only)" if group is None else "")
            print(f"{total:>10,} {display} {errors:>7} {links:>7}  {label}", flush=True)
    if args.csv:
        with open(args.csv, "x", newline="", encoding="utf-8-sig") as output:
            writer = csv.writer(output)
            writer.writerow(["folder", "files", "older_1m_pct", "older_6m_pct",
                             "older_1y_pct", "errors", "links_skipped"])
            writer.writerows(report)
        print(f"Saved {args.csv}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit("Interrupted; any output may be incomplete.")
    except OSError as exc:
        sys.exit(str(exc))
