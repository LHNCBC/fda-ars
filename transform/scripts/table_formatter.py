"""
Program for converting XML/HTML tables and lists to formatted
tables for BRAT.

Convert line input of form:

     @table{   @caption{Table 1: Adverse Reactions due to ZYTIGA in Study 1}   @col{}    @thead{  @tr{  @th{}      @th{....

into abstract syntax tree and then reformat into a ascii table.

"""
import re
import types
import sys
from generate_ast import process
from ast_print import print_ast

begin_pattern = re.compile('@[a-z0-9\[\:\]]+{')
end_pattern = re.compile('}')
def regularize_lines(linelist):
    """ Make sure any @element{ } pairs including nested ones, all occur on
        one line. """
    reglinelist = []
    newlinelist = []
    begin_count = 0
    end_count = 0
    i = 0
    while i < len(linelist):
        line = linelist[i]
        if begin_pattern.search(line):
            # 1. Get count of number of occurences of begin pattern in
            # line
            begin_count = begin_count + len(begin_pattern.findall(line))
            # 2. count number of close patterns
            end_count = len(end_pattern.findall(line))

            if end_count < begin_count:
                # adjust begin count 
                begin_count = begin_count - end_count
                reglinelist.append(line)
            elif begin_count == 0:
                # if begin count zero then add line to regularized line list and add concatenated lines to new linelist.
                reglinelist.append(line)
                newlinelist.append('\n'.join(reglinelist))
                reglinelist = []
                begin_count = 0
                end_count = 0
            elif begin_count == end_count:
                # if begin count equals end count then add line to regularized line list and add concatenated lines to new linelist.
                reglinelist.append(line)
                newlinelist.append('\n'.join(reglinelist))
                reglinelist = []
                begin_count = 0
                end_count = 0
            else:
                reglinelist.append(line)
        elif end_pattern.search(line):
            if begin_count == end_count:
                reglinelist.append(line)
                newlinelist.append('\n'.join(reglinelist))
                reglinelist = []
                begin_count = 0
                end_count = 0
            elif begin_count <= 0:
                reglinelist.append(line)
                newlinelist.append('\n'.join(reglinelist))
                reglinelist = []
                begin_count = 0
                end_count = 0
            else:
                begin_count = begin_count - end_count
                reglinelist.append(line)
        else:
            if begin_count > 0:
                reglinelist.append(line)
            else:
                newlinelist.append(line)
        i+=1
    # emit any remaining lines
    if len(reglinelist) > 0:
        reglinelist.append(line)
        newlinelist.append('\n'.join(reglinelist))
        # print('%d, begin count: %d, end count: %d: line: %s' % (i, begin_count, end_count, line))
    return newlinelist

def process_file(fn):
    fp = open(fn)
    i = 0
    linelist0 = fp.readlines();
    linelist = regularize_lines(linelist0)
    origlen = len('\n'.join(linelist0)) 
    reglen = len('\n'.join(linelist))
    if reglen < origlen :
        sys.stderr.write('warning: process_file:37: regularized linelist length:%d is shorter than original linelist length: %d\n' % (reglen, origlen))
    for line in linelist:
        ast = process(line, i)
        if type(ast) == types.StringType:
            sys.stdout.write('%s\n' % line)
        elif type(ast) == types.DictType:
            print_ast(ast)
        else:
            sys.stdout.write('Unexpected type from process: %s' % type(ast))
        i+=1

if __name__ == '__main__':
    if len(sys.argv) > 1:
        process_file(sys.argv[1])
    else:
        print('%s xsloutputfile' % sys.argv[0])
            
