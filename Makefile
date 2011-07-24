all: okk parser

okk:
	git submodule init
	git submodule update
	cd okk
	make

parser: parser.cpp lexer.cpp
	g++ -o $@ $^

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

lexer.cpp: lexer.l parser.hpp
	lex -o $@ $^
