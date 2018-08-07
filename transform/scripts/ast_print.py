"""convert abstractsyntax tree representing HTML(?) table into
reformatted a ascii table """

import types
import sys

def ignore_element(text, data={}):
    pass

def print_break(text="", data={}):
    sys.stdout.write("\n");

def print_text(text, data={}):
    """ Print text; if align and width present in data dictionary then use
        it to align and pad text.  """
    textformat = ' {} '
    if data.has_key('width'):
        if data['width'].find('.') > 0:
            # truncate integers to right of decimal point
            width = int(data['width'].split('.')[0])
        elif data['width'].find('%') > 0:
            width = int(data['width'].strip('%'))
        elif data['width'].find('px') > 0:
            width = int(data['width'].strip('px'))
        else:
            width = 15
        if data.has_key('align'):
            if data['align'] == 'right':
                textformat = ' {:>%d} ' % width
            elif data['align'] == 'center':
                textformat = ' {:^%d} ' % width
            else:
                textformat = ' {:<%d} ' % width
        else:
            textformat = ' {:<%d} ' % width
    sys.stdout.write(textformat.format(text))

def dispatch(elist, dispatch_table, data={}, addnewline=False):
    ret_data = {}
    for elem in elist:
        if type(elem) == types.DictType:
            for k,v in elem.items():                 
                if dispatch_table.has_key(k):
                    if addnewline:
                        sys.stdout.write('\n')
                    #print('dispatch: executing function: %s' % (dispatch_table[k].__name__))
                    ret = dispatch_table[k](elem[k], data)
                    if ret:
                        ret_data = dict(ret_data.items() + ret.items())
                else:
                    print('ast_print:dispatch: unexpected key: "%s" in dispatch table: %s' % (k,dispatch_table))
    return ret_data


def get_text(text, data={}):
    return { 'text' : text }

footnote_func = {
    '*footnote_func*' : ignore_element,
    'text' : get_text,
    'list' : ignore_element,
    'br'   : ignore_element,
}

def get_footnote(text, data={}):
    return { 'footnote' : text }
    
def print_text_footnote(text, data={}):
    sys.stdout.write('(%s)' % text)

print_row_header_func = {
    '*print_row_header_func*' : ignore_element,
    'footnote'         : ignore_element,
    'text'             : print_text,
    'list'             : ignore_element,
    'br'               : ignore_element, 
}
print_row_data_func = {
    '*print_row_data_func*' : ignore_element,
    'footnote'         : ignore_element,
    'text'             : print_text,
    'list'             : ignore_element,
    'br'               : ignore_element, 
}
def print_row_header(elist, data={}):
    if not data.has_key('width'):
        data['width'] = '20%'
    dispatch(elist, print_row_header_func, data)

def print_row_data(elist, data={}):
    if not data.has_key('width'):
        data['width'] = '15%'
    dispatch(elist, print_row_data_func, data)    

table_row_func = {
    '*table_row_func*' : ignore_element,
    'table_row_header' : print_row_header,
    'table_row_data'   : print_row_data,
    'text'             : print_text,
    'col'              : ignore_element,
    'footnote'         : ignore_element,
    'br'               : ignore_element, 
}
    
def print_table_row(elist, data={}):
    if data.has_key('column_list'):
        column_list = data['column_list']
        if len(column_list) == 0:
            column_list = [{'width': '25%', 'align': 'left'} for x in range(len(elist))]
    else:
        column_list = [{'width': '25%', 'align': 'left'} for x in range(len(elist))]
    i = 0
    ret_data = {}
    for elem in elist:
        if type(elem) == types.DictType:
            for k,v in elem.items():
                if table_row_func.has_key(k) & (k == 'table_row_data'):
                    if i < len(column_list):
                        # print('print_table_row: executing function: %s' % table_row_func[k].__name__)
                        ret_data0 = table_row_func[k](elem[k], column_list[i])
                        if ret_data0:
                            dict(ret_data.items() + ret_data0.items())
                    i+=1
                elif table_row_func.has_key(k) & (k == 'table_row_header'):
                    if i < len(column_list):
                        # print('print_table_row: executing function: %s' % table_row_func[k].__name__)
                        ret_data0 = table_row_func[k](elem[k], column_list[i])
                        if ret_data0:
                            dict(ret_data.items() + ret_data0.items())
                    i+=1
                else:
                    # print('print_table_row: executing function: %s' % table_row_func[k].__name__)
                    ret_data0 = table_row_func[k](elem[k])
                    if ret_data0:
                        dict(ret_data.items() + ret_data0.items())
    return ret_data

caption_func = {
    '*caption_func*' : ignore_element,
    'footnote'       : ignore_element,
    'text'           : print_text,
    'br'             : ignore_element,
}

def print_caption(elist, data={}):
#    sys.stdout.write('%s\n' % text)
    ret_data = dispatch(elist, caption_func, data, addnewline=False)
    return ret_data


print_head_body_func = {
    '*print_head_body_func*' : ignore_element,
    'footnote'               : get_footnote,
    'table_row'              : print_table_row,
    'text'                   : print_text,
    'br'                     : ignore_element,
}

def print_table_head(elist, data={}):
    ret_data = dispatch(elist, print_head_body_func, data, addnewline=True)
    return ret_data

def print_table_body(elist, data={}):
    ret_data = dispatch(elist, print_head_body_func, data, addnewline=True)    
    return ret_data
    
def print_table_foot(elist, data={}):
    ret_data = dispatch(elist, print_head_body_func, data, addnewline=True)    
    return ret_data
    
def print_colgroup(elist, data={}):
    column_list = []
    for elem in elist:
        if type(elem) == types.DictType:
            for k,v in elem.items():
                if k == 'col':
                    col_dict={}
                    for pair in v.strip().split(' '):
                        fields = pair.split('=')
                        col_dict[fields[0]]=fields[1]
                    column_list.append(col_dict)
    return {'column_list' : column_list}


print_table_func = {
    '*print_table_func*' : ignore_element,
    'caption'    : print_caption,
    'table_head' : print_table_head,
    'table_body' : print_table_body,
    'table_foot' : print_table_foot,    
    'table_row'  : print_table_row,
    'text'       : print_text,
    'colgroup'   : print_colgroup,
    'col'        : ignore_element,
    'br'         : ignore_element,
}

def print_table(elist, data={}):
    column_list = []
    for elem in elist:
        if type(elem) == types.DictType:
            for k,v in elem.items():
                if k == 'col':
                    col_dict={}
                    for pair in v.strip().split(' '):
                        fields = pair.split('=')
                        col_dict[fields[0]]=fields[1]
                    column_list.append(col_dict)
                elif k == 'colgroup':
                    ret_data = print_colgroup(v, {})
                    if ret_data.has_key('column_list'):
                        column_list = ret_data['column_list']
            for k,v in elem.items():
                if print_table_func.has_key(k):
                    # print('print_table: executing function: %s' % print_table_func[k].__name__)
                    print_table_func[k](elem[k], {'column_list' : column_list})
                else:
                    print('print_table: unexpected key: %s' % k)

item_func = {
    '*item_func*' : ignore_element,
    'caption'     : print_caption,
    'text'        : print_text,
    'br'          : ignore_element,
    'footnote'    : ignore_element,
}

def print_item(elist, data={}):
    sys.stdout.write(' * ')
    ret_data = dispatch(elist, item_func, data)
    sys.stdout.write('\n')
    return ret_data

def print_bare_item(elist, data={}):
    ret_data = dispatch(elist, item_func, data)
    sys.stdout.write('\n')
    return ret_data

list_func = {
    '*list_func*' : ignore_element,
    'caption'     : print_caption,
    'item'        : print_item,
    'text'        : print_text,
    'footnote'    : ignore_element,
    'list'        : ignore_element,
    'br'          : ignore_element,
}

def print_list(elist, data={}):
    return dispatch(elist, list_func, data)

bare_list_func = {
    '*list_func*' : ignore_element,
    'item'     : print_bare_item,
    'text'     : print_text,
    'footnote' : ignore_element,
    'list'     : ignore_element
}

def print_bare_list(elist, data={}):
    return dispatch(elist, bare_list_func, data)

# a set of hacks
item_func['list'] = print_list
print_row_header_func['list'] = print_bare_list
print_row_data_func['list'] = print_bare_list
footnote_func['list']  = print_list

print_ast_func = {
    '*print_ast_func*' : ignore_element,
    'table'        : print_table,
    'text'         : print_text,
    'caption'      : print_caption,
    'list'         : print_list,
    'footnote'     : print_text_footnote,
    'br'           : ignore_element
}
            
def print_ast(ast):
    """ For each element of Abstract syntax tree, pass to appropriate
        handling function. """
    for tk,tv in ast.items():
        if tk == 'ast':
            if type(tv) == types.DictType:
                for k,v in tv.items():
                    if print_ast_func.has_key(k):
                        print_ast_func[k](tv[k])
                    else:
                        print('print_ast: unexpected key: %s' % k)
            if type(tv) == types.ListType:
                for elem in tv:
                    if type(elem) == types.DictType:
                        for k,v in elem.items():
                            if print_ast_func.has_key(k):
                                print_ast_func[k](elem[k])
                            else:
                                sys.stderr.write('print_ast: unexpected key: "%s"\n' % k)
                    else:
                        sys.stderr.write(' print_ast: Unexpected type: %s, value: %s\n' % (type(elem), elem))
            else:
                sys.stderr.write(' print_ast: Unexpected type: %s, value: %s\n' % (type(tv), tv))
        else:
            sys.stderr.write('print_ast: unexpected key: %s\n' % tk)
