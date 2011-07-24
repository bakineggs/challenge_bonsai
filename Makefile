all: okk/interpreter parser

okk/interpreter:
	git submodule init
	git submodule update
	cd okk; make interpreter

parser: parser.cpp lexer.cpp okk/print.c
	g++ -o $@ $^

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

lexer.cpp: lexer.l parser.hpp
	lex -o $@ $^

clean:
	cd okk; make clean
	rm -f *.cpp *.hpp parser
