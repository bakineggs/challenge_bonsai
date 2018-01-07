node_builder.o: bonsai/implementations/c/node_builder.c
	gcc -c -o $@ $^

print.o: bonsai/implementations/c/print.c
	gcc -c -o $@ $^

parser: parser.c lexer.o node_builder.o print.o
	gcc -o $@ $^

parser.o: parser.c
	gcc -c -o $@ $^

lexer.o: lexer.c
	gcc -c -o $@ $^

parser.c: parser.y
	bison -d -o $@ $^

parser.h: parser.c

lexer.c: lexer.l parser.h
	flex -o $@ $^

clean:
	rm -f lexer.c lexer.o parser parser.h parser.c parser.o node_builder.o print.o
