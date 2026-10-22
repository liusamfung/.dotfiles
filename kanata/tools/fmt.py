#!/usr/bin/env python3
"""Format the kanata modules and lint alias names. Standard library only.

    python3 kanata/tools/fmt.py           rewrite files in place
    python3 kanata/tools/fmt.py --check   change nothing; exit 1 if a file needs formatting or a name breaks the rules

What it does (see "Formato y nombres" in kanata/README.md):
  - defsrc and every deflayer: one row per line, every key in a cell CELL characters wide, the space bar spanning
    SPACE_SPAN cells. The row lengths come from core/defsrc.kbd, which is the legend for every layer.
  - defalias / defvar: one entry per line, names padded so the values line up within each group.
  - alias names: lowercase kebab-case, at most MAX_NAME characters. Names of 1-2 characters are exempt: those
    are the character the alias types (`A`, `!`, `''`).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAX_NAME = 8
CELL = MAX_NAME + 2          # '@' + longest name + one separating space
SPACE_SPAN = 4
FILES = ['core/*.kbd', 'shared/*.kbd', 'layers/*.kbd', 'layers/*.kbd.example']
NAME_RE = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')
EXEMPT = {'_require-local-kbd'}


def forms(text):
    """Top-level (...) forms as (start, end, head); comments and strings are skipped."""
    out, depth, i, start = [], 0, 0, 0
    while i < len(text):
        if text.startswith(';;', i):
            i = text.find('\n', i) if text.find('\n', i) >= 0 else len(text)
            continue
        c = text[i]
        if c == '"':
            i = text.index('"', i + 1)
        elif c == '(':
            if depth == 0:
                start = i
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                out.append((start, i + 1, re.match(r'\(\s*(\S+)', text[start:]).group(1)))
        i += 1
    return out


def items(body):
    """Split a form body into atoms and balanced (...) groups."""
    out, depth, cur = [], 0, ''
    for c in body:
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        if c.isspace() and depth == 0:
            if cur:
                out.append(cur)
                cur = ''
        else:
            cur += c
    return out + ([cur] if cur else [])


def code(form_text):
    """The form without its ;; comments."""
    return re.sub(r';;.*', '', form_text)


def inner(form_text):
    """Items after the head, e.g. ['base', 'esc', '@x', ...] for a deflayer."""
    return items(code(form_text)[1:-1])[1:]


def row_lengths():
    text = (ROOT / 'core/defsrc.kbd').read_text()
    s, e, _ = next(f for f in forms(text) if f[2] == 'defsrc')
    lines = [l.split() for l in text[s:e].split('\n')[1:-1] if l.strip() and not l.strip().startswith(';;')]
    return [len(l) for l in lines], next(i for i, t in enumerate(lines[-1]) if t == 'spc')


def grid(head, tokens, rows, space_col, path, problems):
    if len(tokens) != sum(rows):
        problems.append(f'{path}: {head} has {len(tokens)} keys, defsrc has {sum(rows)}')
        return None
    wide = [t for t in tokens if len(t) > CELL - 1]
    if wide:
        problems.append(f'{path}: {head}: token longer than {CELL - 1} characters: {", ".join(wide)}')
        return None
    lines, k = [], 0
    for r, n in enumerate(rows):
        cells = []
        for c in range(n):
            span = SPACE_SPAN if (r == len(rows) - 1 and c == space_col) else 1
            cells.append(tokens[k + c].ljust(CELL * span))
        k += n
        lines.append('  ' + ''.join(cells).rstrip())
    return '(' + head + '\n' + '\n'.join(lines) + '\n)'


def entries(form_text, path, problems):
    """Format a defalias/defvar: one `name value` per line, values aligned per group."""
    lines = form_text.split('\n')
    head = lines[0].strip()
    if head not in ('(defalias', '(defvar') or lines[-1].strip() != ')':
        problems.append(f'{path}: {head}: put the opening and closing parenthesis on their own lines')
        return None
    body = [l.strip() for l in lines[1:-1]]
    count = len(inner(form_text)) // 2
    defs = [l for l in body if l and not l.startswith(';;')]
    if len(defs) != count:
        problems.append(f'{path}: {head}: one entry per line, please ({len(defs)} lines for {count} entries)')
        return None
    out, group = [], []

    def flush():
        if not group:
            return
        w = max([len(l.split(None, 1)[0]) for l in group if not l.startswith(';;')] or [0])
        for l in group:
            if l.startswith(';;'):
                out.append('  ' + l)
            else:
                name, _, rest = l.partition(' ')
                out.append(('  ' + name.ljust(w) + ' ' + rest.strip()).rstrip())
        group.clear()

    for l in body:
        if not l:
            flush()
            if out and out[-1] != '':
                out.append('')
        else:
            group.append(l)
    flush()
    while out and out[-1] == '':
        out.pop()
    return head + '\n' + '\n'.join(out) + '\n)'


def lint(form_text, head, path, problems):
    its = inner(form_text)
    if head == 'defalias':
        for name in its[0::2]:
            if len(name) <= 2 or name in EXEMPT:
                continue
            if len(name) > MAX_NAME or not NAME_RE.match(name):
                problems.append(f'{path}: alias "{name}": use lowercase-kebab-case, at most {MAX_NAME} characters')
    elif head == 'deflayer' and not NAME_RE.match(its[0]):
        problems.append(f'{path}: layer "{its[0]}": use lowercase-kebab-case')


def format_file(path, rows, space_col, problems):
    text = path.read_text()
    rel = path.relative_to(ROOT)
    for s, e, head in reversed(forms(text)):
        body = text[s:e]
        lint(body, head, rel, problems)
        new = None
        if head in ('defsrc', 'deflayer'):
            if code(body) != body:
                problems.append(f'{rel}: {head}: comments inside a grid would be lost; move them above it')
                continue
            toks = inner(body)
            name = toks.pop(0) if head == 'deflayer' else None
            new = grid(head + (' ' + name if name else ''), toks, rows, space_col, rel, problems)
        elif head in ('defalias', 'defvar'):
            new = entries(body, rel, problems)
        if new:
            text = text[:s] + new + text[e:]
    text = re.sub(r'[ \t]+\n', '\n', text)
    text = re.sub(r'^[ \t]+(\((?:defsrc|deflayer|defalias|defvar))', r'\1', text, flags=re.M)
    text = re.sub(r'\n{3,}', '\n\n', text).strip('\n') + '\n'
    return text


def main():
    check = '--check' in sys.argv
    rows, space_col = row_lengths()
    problems, dirty = [], []
    for pattern in FILES:
        for path in sorted(ROOT.glob(pattern)):
            new = format_file(path, rows, space_col, problems)
            if new != path.read_text():
                dirty.append(str(path.relative_to(ROOT)))
                if not check:
                    path.write_text(new)
    for p in problems:
        print('problem:', p)
    if check:
        for d in dirty:
            print('needs formatting:', d)
        sys.exit(1 if dirty or problems else 0)
    print(f'formatted {len(dirty)} file(s)' if dirty else 'already formatted')
    sys.exit(1 if problems else 0)


if __name__ == '__main__':
    main()
