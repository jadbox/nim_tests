import os
from strutils import parseFloat
import sequtils
import tables
import strutils

type FormulaKind = enum
    fkLit,
    fkVar,
    fkRef,
    fkMul

type Formula = ref object
    case kind: FormulaKind
    of fkLit: 
        value: float
    of fkVar: 
        name: string, 
        value: Formula
    of fkRef: 
        name: string
    of fkMul: 
        terms: array[0..1, Formula]

proc pat2kind(pattern: string): FormulaKind = 
    case pattern[0]
    of '*': fkMul
    of '0'..'9': fkLit
    of 'a'..'z' : fkRef
    of '=': fkVar
    else:   fkLit

proc buildTokens(line: string) : seq[Formula] =
    result = @[]
    for c in line.split(" "):
        var kind = pat2kind c;
        case kind
        of fkLit: result.add Formula(kind:kind, value: parseFloat(c))
        of fkMul: result.add Formula(kind:kind)
        of fkRef: result.add Formula(kind:kind, name:c)
        of fkVar: result.add Formula(kind:kind, name:c) #refactor

proc buildFormula( s: var seq[Formula] ): Formula =
    if len(s) > 0:
        var c:Formula = s[0]
        s.delete(0, 0)
        case c.kind
        of fkLit: 
            result = c
        of fkVar:
            result = c
            result.name = buildFormula(s).name # get ref token name
            result.value = buildFormula s # get value
        of fkRef:
            result = c
        of fkMul: 
            result = c
            result.terms[0] = buildFormula s
            result.terms[1] = buildFormula s

# Print out the Formula for debugging, best use after buildFormula
proc print(token:Formula):string =
    case token.kind
    of fkLit: $token.value
    of fkMul: "Mult of (" & print(token.terms[0]) & " " & print(token.terms[1]) & ")"
    of fkVar: "Var " & token.name & " = " & print(token.value)
    of fkRef: "Ref " & token.name

# Crunch the calcuations
proc compute(token:Formula, table:TTable[string, Formula]):float =
    case token.kind
    of fkLit: token.value
    of fkMul: compute(token.terms[0]) * compute(token.terms[1])
    of fkRef: table[token.name]
    of fkVar: 
        table[token.name] = token.value
        compute(token.value)

# Main Program
var i = open("calcadd.txt");
var line : char;
var table = initTable[string, Formula]()
for line in i.lines:
    var tokens:seq[Formula] = buildTokens(line)
    var f:Formula = buildFormula(tokens)
    echo compute(f, table)

