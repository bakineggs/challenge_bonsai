interpreter: interpreter.c parser.o lexer.o
	gcc -o $@ $^

interpreter.c: rules.bonsai .git/index
	git submodule init
	git submodule update
	cd bonsai; ruby compile.rb ../rules.bonsai > ../interpreter.c.tmp
	mv interpreter.c.tmp interpreter.c

parser.o: parser.c
	gcc -c -o $@ $^

lexer.o: lexer.c
	gcc -c -o $@ $^

parser.c: parser.y
	bison -d -o $@ $^

parser.h: parser.c

lexer.c: lexer.l parser.h
	flex -o $@ $^

test: interpreter
	spec spec

clean:
	rm -f lexer lexer.c lexer.o parser parser.h parser.c parser.o interpreter.c interpreter
