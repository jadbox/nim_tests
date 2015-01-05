import os
from strutils import parseFloat
import sequtils
import tables
import strutils

type FormulaKind = enum
    fkLit,
    fkMul

type Formula = ref object
    case kind: FormulaKind
#    of fkVar, fkNone: name : string
    of fkLit: value : float
    of fkMul: terms : array[0..1, Formula]

proc pat2kind(pattern: string): FormulaKind = 
    case pattern[0]
    of '*': fkMul
    of '0'..'9': fkLit
    else:   fkLit

proc buildTokens(line: string) : seq[Formula] =
    result = @[]
    for c in line.split(" "):
        case pat2kind c
        of fkLit: result.add Formula(kind:fkLit, value: parseFloat(c))
        of fkMul: result.add Formula(kind:fkMul)

proc buildFormula( s: var seq[Formula] ): Formula =
    if len(s) > 0:
        var c:Formula = s[0]
        s.delete(0, 0)
        case c.kind
        of fkLit: result = c
        of fkMul: 
            result = c
            result.terms[0] = buildFormula s
            result.terms[1] = buildFormula s

proc print(token:Formula):string =
    case token.kind
    of fkLit: $token.value
    of fkMul: "Mult of (" & print(token.terms[0]) & " " & print(token.terms[1]) & ")"

proc compute(token:Formula):float =
    case token.kind
    of fkLit: token.value
    of fkMul: compute(token.terms[0]) * compute(token.terms[1])


var i = open("calcadd.txt");
var line : char;
var table = initTable[string, float]()
for line in i.lines:
    var tokens:seq[Formula] = buildTokens(line)
    var f:Formula = buildFormula(tokens)
    echo compute(f)

