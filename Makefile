interpreter: interpreter.c parser.o lexer.o okk/node_builder.o
	g++ -o $@ $^

interpreter.c: rules.okk
	git submodule init
	git submodule update
	cd okk; ruby compile.rb ../rules.okk > ../interpreter.c

parser.o: parser.cpp
	g++ -Wno-write-strings -c -o $@ $^

lexer.o: lexer.cpp
	g++ -Wno-write-strings -c -o $@ $^

okk/node_builder.o: okk/node_builder.c
	git submodule init
	git submodule update
	cd okk; make node_builder.o

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

lexer.cpp: lexer.l parser.hpp
	lex -o $@ $^

test: interpreter
	sh test.sh

clean:
	if [ -d okk ]; then cd okk; make clean; fi
	rm -f *.cpp *.hpp *.o interpreter interpreter.c
