%{
  #include "parser.hpp"
%}

%%

true { yylval.bool = true; return BOOL; }
false { yylval.bool = false; return BOOL; }

[0-9]+ { yylval.int = parseInt(yytext); return INT; }

[0-9]+\.[0-9]+ { yylval.real = parseReal(yytext); return REAL; }

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

[a-zA-Z][a-zA-Z0-9_]* { yylval.var_id = parseVarId(yytext); return VAR_ID; }

\n
\t
\v
\f
\r
\x20

. { return ERROR; }

%%
