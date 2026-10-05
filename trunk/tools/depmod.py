#!/usr/bin/env python3
# Minimal depmod replacement for hosts without /sbin/depmod (e.g. macOS).
# Generates modules.dep by resolving undefined symbols against __ksymtab
# exports of other modules, using the cross toolchain nm.
#
# usage: depmod.py <kernelrelease> [<basedir>]
#   kernelrelease and INSTALL_MOD_PATH come from env when invoked by depmod.sh

import os, re, subprocess, sys

args = [a for a in sys.argv[1:] if not a.startswith('-')]
basedir = None
argv = sys.argv[1:]
if '-b' in argv:
    basedir = argv[argv.index('-b') + 1]
krel = args[-1] if args else os.environ.get('KERNELRELEASE', '')
if basedir is None:
    basedir = os.environ.get('INSTALL_MOD_PATH', '')

moddir = os.path.join(basedir, 'lib', 'modules', krel)
if not os.path.isdir(moddir):
    sys.exit(f"depmod.py: module dir not found: {moddir}")

nm = os.environ.get('DEPMOD_NM') or (os.environ.get('CROSS_COMPILE', '') + 'nm')

ksymtab_re = re.compile(r'^[0-9a-fA-F]+\s+\S\s+__ksymtab_(.+)$')
undef_re = re.compile(r'^\s+U\s+(\S+)$')

mods = []
exports = {}
undefs = {}

for root, dirs, files in os.walk(moddir):
    for f in sorted(files):
        if not f.endswith('.ko'):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, moddir)
        mods.append(rel)
        try:
            out = subprocess.run([nm, p], capture_output=True, text=True, errors='replace').stdout
        except OSError as e:
            sys.exit(f"depmod.py: cannot run {nm}: {e}")
        u = set()
        for line in out.splitlines():
            m = ksymtab_re.match(line.strip())
            if m:
                exports.setdefault(m.group(1), set()).add(rel)
                continue
            m = undef_re.match(line)
            if m:
                u.add(m.group(1))
        if u:
            undefs[rel] = u

# resolve direct dependencies (kernel-provided symbols are simply unmatched)
lines = []
for rel in mods:
    deps = set()
    for sym in undefs.get(rel, ()):
        for d in exports.get(sym, ()):
            if d != rel:
                deps.add(d)
    lines.append(rel + ': ' + ' '.join(sorted(deps)))

with open(os.path.join(moddir, 'modules.dep'), 'w') as fp:
    fp.write('\n'.join(lines) + '\n')
print(f"depmod.py: wrote {len(lines)} entries to {moddir}/modules.dep")
