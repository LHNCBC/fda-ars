""" Convert line input of form:

     @table{   @caption{Table 1: Adverse Reactions due to ZYTIGA in Study 1}   @col{}    @thead{  @tr{  @th{}      @th{....

into abstract syntax tree."""

import re
import sys

def dispatch(rest, pattern, lineno, encoding='ascii', label='unknown', dispatch_table={}):
    # print('dispatch():label = %s' % label)
    # print('dispatch():rest = %s' % rest)
    # print('dispatch():dispatch_table = %s' % dispatch_table)
    element_list = []
    inputbytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if dispatch_table.has_key(m.group(0)):
                rest, result = dispatch_table[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
                # print('dispatch(): return rest: %s\ndispatch(): return result: %s' % (rest,result))
            else:
                sys.stderr.write("generate_ast:dispatch:process_%s:unexpected match: %s, line: %d\n" % (label,m.group(0), lineno))
                sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : inputbytes.__str__() } )
            return rest,{label : element_list }
        else:
            inputbytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : inputbytes.__str__() } )
    return rest,{label : element_list }

def process_br(rest, pattern, lineno, encoding='ascii'):
    """ handle "@br{} """
    rdict = {'br': '\n'}
    rest = rest[1:]
    return rest,rdict

def process_footnote(rest, pattern, lineno, encoding='ascii'):
    """ handle "@footnote{ text } """
    footnotebytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            print("%s:unexpected match: %s, line: %d" % (__name__,m.group(0),lineno))
            rest = rest[len(m.group(0)):]
            sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            rdict={ 'footnote' : footnotebytes.__str__() }
            return rest,rdict
        else:
            footnotebytes.append(rest[0])
            rest = rest[1:]
    rdict={ 'footnote' : footnotebytes.__str__() }
    return rest,rdict

caption_func = {
    '@footnote{' : process_footnote,
}

def process_caption(rest, pattern, lineno, encoding='ascii'):
    """ handle "@caption{ text } """
    return dispatch(rest, pattern, lineno, encoding, 'caption', caption_func)

item_func = {
    '@caption{'  : process_caption,
    '@footnote{' : process_footnote,
    '@br{'       : process_br,
#    '@list{'  : process_list,  # filled-in later 
}

def process_item(rest, pattern, lineno, encoding='ascii'):
    return dispatch(rest, pattern, lineno, encoding, 'item', item_func)

list_func = {
    '@caption{' : process_caption,
    '@item{'    : process_item,
    '@br{'      : process_br,
}
def process_list(rest, pattern, lineno, encoding='ascii'):
    rest,rdict = dispatch(rest, pattern, lineno, encoding, 'list', list_func)
    if rdict.has_key('footnote'):
        sys.stderr.write(rdict.get('footnote'))
        del rdict['footnote']
    return rest,rdict

table_row_header_func = {
    '@footnote{' : process_footnote,
    '@br{'       : process_br,
}
def process_table_row_header(rest, pattern, lineno, encoding='ascii'):
    """ handle "@th{ text } """
    element_list = []
    table_header_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_row_header_func.has_key(m.group(0)):
                rest, result = table_row_header_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("%s:process_table_row_header:unexpected match: %s, line: %d\n" % (__name__,m.group(0),lineno))
                rest = rest[len(m.group(0)):]
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : table_header_bytes.__str__() } )
            return rest,{'table_row_header' : element_list }
        else:
            table_header_bytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : table_header_bytes.__str__() } )
    return rest,{'table_row_header' : element_list }

table_row_data_func = {
    '@caption{'  : process_caption,
    '@footnote{' : process_footnote,
    '@list{'     : process_list,
    '@br{'       : process_br
}

def process_table_row_data(rest, pattern, lineno, encoding='ascii'):
    """ handle "@td{ text } """
    element_list = []
    table_data_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_row_data_func.has_key(m.group(0)):
                rest, result = table_row_data_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("unexpected match: %s, line: %d\n" % (m.group(0),lineno))
                rest = rest[len(m.group(0)):]
                sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : table_data_bytes.__str__() } )
            return rest,{ 'table_row_data' : element_list }
        else:
            table_data_bytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : table_data_bytes.__str__() } )
    return rest,{ 'table_row_data' : element_list }


table_row_func = {
    '@caption{'  : process_caption,
    '@footnote{' : process_footnote,
    '@th{'       : process_table_row_header,
    '@td{'       : process_table_row_data,
    '@td[descendant::v3:content]{' : process_table_row_data,
    '@br{'       : process_br
}

def process_table_row(rest, pattern, lineno, encoding='ascii'):
    """ handle "@tr{ text } """
    element_list = []
    row_table_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_row_func.has_key(m.group(0)):
                rest, result = table_row_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("unexpected match: %s, line: %d\n" % (m.group(0),lineno))
                rest = rest[len(m.group(0)):]
                sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : row_table_bytes.__str__() } )
            return rest,{'table_row' : element_list}
        else:
            row_table_bytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : row_table_bytes.__str__() } )
    return rest,{ 'table_row' : element_list }

table_head_func = {
    '@tr{' : process_table_row,
    '@br{' : process_br
}

def process_table_head(rest, pattern, lineno, encoding='ascii'):
    """ handle "@thead{ text } """
    element_list = []
    row_table_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_head_func.has_key(m.group(0)):
                rest, result = table_head_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("unexpected match: %s, line: %d\n" % (m.group(0),lineno))
                rest = rest[len(m.group(0)):]
                sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : row_table_bytes.__str__() } )
            return rest,{ 'table_head' : element_list}
        else:
            row_table_bytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : row_table_bytes.__str__() } )
    return rest,{ 'table_head' : element_list }

table_foot_func = {
    '@tr{' : process_table_row,
    '@br{' : process_br,
}
def process_table_foot(rest, pattern, lineno, encoding='ascii'):
    """ handle "@tfoot{ text } """
    element_list = []
    row_table_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_foot_func.has_key(m.group(0)):
                rest, result = table_foot_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("unexpected match: %s, line: %d\n" % (m.group(0),lineno))
                rest = rest[len(m.group(0)):]
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : row_table_bytes.__str__() } )
            return rest,{ 'table_foot' : element_list}
        else:
            row_table_bytes.append(rest[0])
            rest = rest[1:]
    element_list.append({ 'text' : row_table_bytes.__str__() } )
    return rest,{ 'table_foot' : element_list }

table_body_func = {
    '@tr{' : process_table_row,
    '@br{' : process_br,
}

def process_table_body(rest, pattern, lineno, encoding='ascii'):
    """ handle "@tbody{ text } """
    element_list = []
    row_table_bytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            if table_body_func.has_key(m.group(0)):
                rest, result = table_body_func[m.group(0)](rest[len(m.group(0)):], pattern, lineno)
                element_list.append(result)
            else:
                sys.stderr.write("process_table_body: unexpected match: %s\n" % m.group(0))
                rest = rest[len(m.group(0)):]
                sys.exit(1)
        elif rest[0] == '}':
            rest = rest[len('}'):]
            element_list.append({ 'text' : row_table_bytes.__str__() } )
            return rest,{ 'table_body' : element_list }
        else:
            row_table_bytes.append(rest[0])
            rest = rest[1:]
    return rest,{ 'table_body' : row_table_bytes.__str__() }

def process_col(rest, pattern, lineno, encoding='ascii'):
    """ handle "@col{ text } """
    colbytes = bytearray('', encoding)
    while ( len(rest) > 0 ):
        m = pattern.match(rest)
        if m:
            sys.stderr.write("process_table_body: unexpected match: %s\n" % m.group(0))
        elif rest[0] == '}':
            rest = rest[len('}'):]
            return rest,{ 'col' : colbytes.__str__() }
        else:
            colbytes.append(rest[0])
            rest = rest[1:]
    return rest,{ 'col' : colbytes.__str__() }


colgroup_func = {
    '@col{'      : process_col,
    '@br{'       : process_br,
}

def process_colgroup(rest, pattern, lineno, encoding='ascii'):
    return dispatch(rest, pattern, lineno, encoding, 'colgroup', colgroup_func)

table_func = {
    '@caption{'  : process_caption,
    '@footnote{' : process_footnote,
    '@tr{'       : process_table_row,
    '@col{'      : process_col,
    '@colgroup{' : process_colgroup,
    '@thead{'    : process_table_head,
    '@tfoot{'    : process_table_foot,
    '@tbody{'    : process_table_body,
    '@br{'       : process_br,
}

def process_table(rest, pattern, lineno, encoding='ascii'):
    rest,rdict = dispatch(rest, pattern, lineno, encoding, 'table', table_func)
    if rdict.has_key('footnote'):
        sys.stderr.write(rdict.get('footnote'))
        del rdict['footnote']
    return rest,rdict    

ast_func = {
    '@caption{'  : process_caption,
    '@list{'     : process_list,
    '@table{'    : process_table,
    '@footnote{' : process_footnote,
    '@br{'       : process_br,
}

pattern = re.compile('@[a-z0-9\[\:\]]+{')
def process(line, lineno=0, encoding='ascii'):
    """ process table if present, otherwise return untouched. """
    # hack for item_func map
    item_func['@list{'] = process_list
    # was: if (line.find('@table{') >= 0) | (line.find('@caption{') >= 0):
    if pattern.search(line):
        linebytes = bytearray('', encoding)
        ast = {}
        rest = line
        while ( len(rest) > 0 ):
            m = pattern.match(rest)
            if m:
                if len(linebytes.__str__()) > 0:
                    if ast.has_key('ast'):
                        ast['ast'] = [{'text': linebytes.__str__()}].append(ast['ast'])
                    else:
                        ast['ast'] = [{'text': linebytes.__str__()}]
                    linebytes = bytearray('', encoding)                        
                rest,rdict = dispatch(rest, pattern, lineno, encoding, 'ast', ast_func)
                if rdict:
                    if ast.has_key('ast'):
                        elem_list = ast['ast'] + rdict['ast']
                        ast = dict(ast.items() + rdict.items())
                        ast['ast'] = elem_list
                    else:
                        ast = dict(ast.items() + rdict.items())
            elif rest[0] == '}':
                rest = rest[len('}'):]
            else:
                linebytes.append(rest[0])
            rest = rest[1:]
        if len(linebytes.__str__().strip()) > 0:
            if ast.has_key('ast'):
                ast['ast'].append({'text': linebytes.__str__()})
            else:
                ast['ast'] = [{'text': linebytes.__str__()}]
        return ast
    else:
        return line

