start
= statements

statements
= s:statement+ { return s.join('\n')}

statement
= insert:insert ws? { return insert + '\n'}

insert
= io:insert_overwrite name:table_name ws q:query { return io + name + '\n' + q }

insert_overwrite
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
= '\nJOIN ' from_args:from_args ' ON (' where_args:where_args ')' { return '\nJOIN ' + from_args + ' ON (' + where_args + ')';}

where
= '\nWHERE ' where_args:where_args { return '\nWHERE ' + where_args;}

where_args
= cond1:where_cond cond2:where_cond2? { return cond1 + cond2;}

where_cond
= field:field ' ' where_op:where_op ' ' expr:expr { return field + ' ' + where_op + ' ' + expr; }

where_cond2
= ' AND ' where_cond:where_cond { return ' AND ' + where_cond;}

where_op
= '='
/ 'IS NOT'
/ 'IS'

group_by
= '\nGROUP BY ' f2:fields { return '\nGROUP BY ' + f2 }

fields
= '*'
/ f1:expr f2:field_piece* { return f1 + f2.join('') }

field_piece
= ', ' f:expr { return ', ' + f; }

expr
= f:field ' ' op:op ' ' expr:expr { return f + ' ' + op + ' ' + expr;}
/ f:func ' ' op:op ' ' expr:expr { return f + ' ' + op + ' ' + expr;}
/ field
/ func
/ string
/ number
/ 'NULL'

op
= '*'
/ '/'
/ 'IS'
/ 'IS NOT'

func
= n:'FROM_UNIXTIME' '(' a:unixtime_args ')' {return n + '(' + a + ')';}
/ n:'COUNT' '(' a:count_args ')' {return n + '(' + a + ')';}
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
= chars:[a-z_]+ { return chars.join(''); }

string
= "'" chars:[a-zA-Z-]+ "'" { return "'" + chars.join('') + "'"; }

number
= digits:[0-9]+ { return digits.join(''); }

ws
= [\n ]+