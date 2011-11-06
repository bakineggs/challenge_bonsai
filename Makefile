interpreter: interpreter.c parser.o lexer.o
	g++ -Wno-write-strings -o $@ $^

interpreter.c: rules.okk .git/index
	git submodule init
	git submodule update
	cd okk; ruby compile.rb ../rules.okk > ../interpreter.c.tmp
	mv interpreter.c.tmp interpreter.c

parser.o: parser.cpp
	g++ -Wno-write-strings -c -o $@ $^

lexer.o: lexer.cpp
	g++ -Wno-write-strings -c -o $@ $^

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

lexer.cpp: lexer.l parser.hpp
	lex -o $@ $^

test: interpreter
	spec spec

clean:
	rm -f *.cpp *.hpp *.o interpreter*
