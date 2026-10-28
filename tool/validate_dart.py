#!/usr/bin/env python3
"""Small dependency-free Dart lexical/balance and import checker (not a full analyzer)."""
from pathlib import Path
import re, sys
ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
FILES = sorted(LIB.rglob('*.dart'))
PAIRS = {')':'(', ']':'[', '}':'{'}

def scan(path):
    s = path.read_text(encoding='utf-8'); stack=[]; i=0; line=1; tokens=[]
    while i < len(s):
        c=s[i]
        if c=='\n': line+=1; i+=1; continue
        if c.isspace(): i+=1; continue
        if s.startswith('//',i):
            j=s.find('\n',i)
            if j<0: break
            i=j; continue
        if s.startswith('/*',i):
            start=line; depth=1; i+=2
            while i<len(s) and depth:
                if s.startswith('/*',i): depth+=1; i+=2
                elif s.startswith('*/',i): depth-=1; i+=2
                else:
                    if s[i]=='\n': line+=1
                    i+=1
            if depth: raise SyntaxError(f'{path}:{start}: unterminated block comment')
            continue
        # Dart raw or regular single/double/triple-quoted strings.
        qpos=i+1 if c in 'rR' and i+1<len(s) and s[i+1] in "'\"" else i
        if s[qpos] in "'\"":
            q=s[qpos]; triple=s.startswith(q*3,qpos); delim=q*3 if triple else q
            start=line; i=qpos+len(delim); closed=False
            while i<len(s):
                if s.startswith(delim,i): i+=len(delim); closed=True; break
                if s[i]=='\\' and qpos==i: pass
                if s[i]=='\\' and not (c in 'rR' and qpos==i+1):
                    i+=2; continue
                if s[i]=='\n':
                    if not triple: raise SyntaxError(f'{path}:{start}: newline in quoted string')
                    line+=1
                i+=1
            if not closed: raise SyntaxError(f'{path}:{start}: unterminated string')
            tokens.append(('STRING',start)); continue
        if c in '([{': stack.append((c,line))
        elif c in ')]}':
            if not stack or stack[-1][0]!=PAIRS[c]:
                raise SyntaxError(f'{path}:{line}: unexpected {c}; open={stack[-1] if stack else None}')
            stack.pop()
        # Collect identifiers/keywords and punctuation for import and token sanity.
        if c.isalpha() or c=='_' or ord(c)>127:
            j=i+1
            while j<len(s) and (s[j].isalnum() or s[j]=='_' or ord(s[j])>127): j+=1
            tokens.append((s[i:j],line)); i=j; continue
        tokens.append((c,line)); i+=1
    if stack: raise SyntaxError(f'{path}:{stack[-1][1]}: unclosed {stack[-1][0]}')
    return s,tokens

errors=[]; total=0
for f in FILES:
    try:
        src,toks=scan(f); total+=len(toks)
        for m in re.finditer(r"\bimport\s+(['\"])(.*?)\1",src):
            uri=m.group(2)
            if uri.startswith('.'):
                target=(f.parent/uri.split('#')[0]).resolve()
                if not target.is_file(): errors.append(f'{f.relative_to(ROOT)}: unresolved relative import {uri}')
            elif uri.startswith('package:'):
                package,_,rel=uri[8:].partition('/')
                pub=(ROOT/'pubspec.yaml').read_text(encoding='utf-8')
                if package!='flutter' and not re.search(r'^\s{2}'+re.escape(package)+r':',pub,re.M):
                    errors.append(f'{f.relative_to(ROOT)}: package import {package} not declared in pubspec.yaml')
                if package== 'smart_food' and not (LIB/rel).is_file(): errors.append(f'{f.relative_to(ROOT)}: unresolved package import {uri}')
    except Exception as e: errors.append(str(e))
print(f'Inspected {len(FILES)} Dart files; tokenized {total} tokens.')
if errors:
    print('\n'.join(errors)); sys.exit(1)
print('PASS: strings/comments and (), [], {} balanced; all relative/package imports resolve.')
