%{
  #include <stdlib.h>
  #include <string>

  #include "types.h"
  #include "parser.hpp"

  extern "C" int yywrap() { }
%}

%%

true { yylval.node = bool_value(1); return BOOLEAN; }
false { yylval.node = bool_value(0); return BOOLEAN; }

-?[0-9]+ { yylval.node = integer_value(atol(yytext)); return INT; }

-?[0-9]+\.[0-9]+ { yylval.node = real_value(atof(yytext)); return REAL; }

\+ { return PLUS; }
\* { return STAR; } /* used for MUL and DEREF */
\/ { return DIV; }
\<= { return LEQ; }
not { return NOT; }
and { return AND; }
\+\+ { return INCREMENT; }
; { return SEMI; }
malloc { return MALLOC; }
& { return REF; }
lambda { return LAMBDA; }
, { return COMMA; }
\{ { return OPENBLOCK; }
\} { return CLOSEBLOCK; }
\( { return LPAREN; }
\) { return RPAREN; }
\. { return DOT; }
mu { return MU; }
callcc { return CALLCC; }
randomBool { return RANDOM_BOOL; }
new-agent { return NEW_AGENT; }
me { return ME; }
parent { return PARENT; }
receive { return RECEIVE; }
receive-from { return RECEIVE_FROM; }
quote { return QUOTE; }
unquote { return UNQUOTE; }
eval { return EVAL; }
vars { return VARS; }
if { return IF; }
then { return THEN; }
else { return ELSE; }
while { return WHILE; }
do { return DO; }
output { return OUTPUT; }
:= { return ASSIGN; }
aspect { return ASPECT; }
spawn { return SPAWN; }
acquire { return ACQUIRE; }
free { return FREE; }
release { return RELEASE; }
rv { return RENDEZVOUS; }
send-asynch { return SEND_ASYNCH; }
send-synch { return SEND_SYNCH; }
halt-thread { return HALT_THREAD; }
halt-agent { return HALT_AGENT; }
halt-system { return HALT_SYSTEM; }

[a-zA-Z][a-zA-Z0-9_-]* { yylval.node = var_id(yytext, yyleng); return VAR_ID; }

\n
\t
\v
\f
\r
\x20

. { exit(1); }

%%
