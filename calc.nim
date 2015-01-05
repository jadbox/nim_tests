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
        vname: string 
        vvalue: Formula
    of fkRef: 
        rname: string
    of fkMul: 
        terms: array[0..1, Formula]

proc pat2kind(pattern: string): FormulaKind = 
    case pattern[0]
    of '*': fkMul
    of '0'..'9': fkLit
    of '-': fkLit
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
        of fkRef: result.add Formula(kind:kind, rname:c)
        of fkVar: result.add Formula(kind:kind, vname:c) #refactor

proc buildFormula( s: var seq[Formula] ): Formula =
    if len(s) > 0:
        var c:Formula = s[0]
        s.delete(0, 0)
        case c.kind
        of fkLit: 
            result = c
        of fkVar:
            result = c
            result.vname = buildFormula(s).rname # get ref token name
            result.vvalue = buildFormula s # get value
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
    of fkVar: "Var " & token.vname & " = " & print(token.vvalue)
    of fkRef: "Ref " & token.rname

# Crunch the calcuations
proc compute(token:Formula, table:var Table[string, Formula]):float =
    case token.kind
    of fkLit: token.value
    of fkMul: compute(token.terms[0],table) * compute(token.terms[1],table)
    of fkRef: compute( table[token.rname],table )
    of fkVar: 
        table[token.vname] = token.vvalue
        compute(token.vvalue,table)

# Main Program
var file = open("calcadd.txt");
var line : char;
var table = initTable[string, Formula]()
var i:int = 0;
for line in file.lines:
    var tokens:seq[Formula] = buildTokens(line)
    var f:Formula = buildFormula(tokens)
    echo "Line " & ($i) & ": " & ($compute(f, table))
    inc(i)

