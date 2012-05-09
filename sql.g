start
= statements

statements
= comment? s:statement+ { return s.join('\n')}

statement
= ws? insert:insert ws? { return insert + '\n'}

insert
= io:insert_into name:table_name ws q:query { return io + name + '\n' + q }

insert_into
= 'INSERT INTO ' {return 'INSERT OVERWRITE TABLE ';}

query
= 'SELECT ' f1:fields ws 'FROM ' from_args:from_args joins:joins where:where? group_by:group_by? ';' { return 'SELECT ' + f1 + '\nFROM ' + from_args + joins + where + group_by + ';'; }

joins
= joins:join* { return joins.join('')}

from_args
= name:table_name alias:alias? { var rv = name; if(alias){ rv += alias; } return rv;}

alias
= (' ' table_name:table_name) {return ' ' + table_name;}

join
= ws jt:join_type? 'JOIN ' from_args:from_args ' ON (' join_args:join_args ')' { return '\n' + jt + 'JOIN ' + from_args + ' ON (' + join_args + ')';}

join_type
= 'LEFT OUTER '
/ 'RIGHT OUTER '

join_args
= cond1:join_cond cond2:join_cond2* { return cond1 + cond2.join('');}

join_cond
= e1:expr ' ' test:join_expr_test { return e1 + ' ' + test; }
/ '(' a:join_args ')' { return '(' + a + ')'; }

join_cond2
= ' ' op:bool_op ' ' join_cond:join_cond { return ' ' + op + ' ' + join_cond;}

join_expr_test
= '= ' e:expr { return '= ' + e; }
/ 'IS NOT NULL'
/ 'IS NULL'

where
= ws 'WHERE ' where_args:where_args { return '\nWHERE ' + where_args;}

where_args
= cond1:where_cond cond2:where_cond2* { return cond1 + cond2.join('');}

where_cond
= e1:expr ' ' test:expr_test { return e1 + ' ' + test; }
/ '(' a:where_args ')' { return '(' + a + ')'; }

where_cond2
= ' ' op:bool_op ' ' where_cond:where_cond { return ' ' + op + ' ' + where_cond;}

bool_op
= 'AND'
/ 'OR'

expr_test
= op:test_op ' ' e:expr { return op + ' ' + e; }
/ 'IS NOT NULL'
/ 'IS NULL'

test_op
= '='
/ '<='
/ '>='
/ '<'
/ '>'

group_by
= ws 'GROUP BY ' f2:fields { return '\nGROUP BY ' + f2 }

fields
= '*'
/ f1:expr f2:field_piece* { return f1 + f2.join('') }

field_piece
= ', ' f:expr { return ', ' + f; }

expr
= scalar
/ f:field ' ' op:op ' ' expr:expr { return f + ' ' + op + ' ' + expr;}
/ f:func ' ' op:op ' ' expr:expr { return f + ' ' + op + ' ' + expr;}
/ field
/ func

scalar
= string
/ number
/ 'NULL'

op
= '+'
/ '-'
/ '*'
/ '/'

func
= n:'FROM_UNIXTIME' '(' a:unixtime_args ')' {return n + '(' + a + ')';}
/ n:'COUNT' '(' a:count_args ')' {return n + '(' + a + ')';}
/ n:'IF' '(' a:where_args ', ' s1:scalar ', ' s2:scalar ')' {return n + '(' + a + ', ' + s1 + ', ' + s2 + ')';}
/ name:[A-Z_]+ '(' a:args ')' {return name.join('') + '(' + a + ')';}

unixtime_args
= f:field ', ' s:format_string { return f + ', ' + s }

count_args
= d:'DISTINCT '? f:field { return d + f }

format_string
= "'" chars:[%a-zA-Z-]+ "'" { 
  string = chars.join('');
  string = string.replace('%Y', 'yyyy');
  string = string.replace('%m', 'MM');
  string = string.replace('%d', 'dd'); 
  return "'" + string + "'";
}

args
= '*'
/ f1:expr f2:arg_piece* { return f1 + f2.join('') }

arg_piece
= ', ' f:expr { return ', ' + f; }

field
= prefix:table_prefix? '`'? identifier:identifier '`'? { return prefix + '`' + identifier + '`'; }

table_prefix
= table_name:table_name '.' { return table_name + '.'; }

table_name
= identifier

identifier
= chars:[a-z0-9_]+ { return chars.join(''); }

string
= "'" chars:[a-zA-Z-]+ "'" { return "'" + chars.join('') + "'"; }

number
= digits:[0-9]+ { return digits.join(''); }

ws
= [\n ]* comment [\n ]*
/ [\n ]+

comment
= '-- ' [^\n]+ '\n'