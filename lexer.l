%{
  #include <stdlib.h>
  #include <string>

  #include "types.h"
  #include "parser.hpp"

  extern "C" int yywrap() { }
%}

%%

true { set_integer("Value", 1); yylval.node = build_node("Bool: $Value"); return VALUE; }
false { set_integer("Value", 0); yylval.node = build_node("Bool: $Value"); return VALUE; }

-?[0-9]+ { set_integer("Value", atol(yytext)); yylval.node = build_node("Integer: $Value"); return VALUE; }

-?[0-9]+\.[0-9]+ { set_real("Value", atof(yytext)); yylval.node = build_node("Real: $Value"); return VALUE; }

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

[a-zA-Z][a-zA-Z0-9_-]* { set_string("VarId", yytext); yylval.node = build_node("VarId: $VarId"); return VAR_ID; }

\n
\t
\v
\f
\r
\x20

. { exit(1); }

%%
