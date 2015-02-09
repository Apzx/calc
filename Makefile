CCXX = clang++
BISON = bison
BISONFLAGS =
FLEX = flex
FLEXFLAGS =

all: calc

calc: parsecalc.o scancalc.o
	$(CCXX) $^ -o $@

scancalc.o: parsecalc.hh

%.o: %.c
	$(CCXX) $(CFLAGS) -c $< -o $@

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o$@ $<

%.cc: %.yy
	$(BISON) $(BISONFLAGS) $< -o$@

.PHONY: check




check: calc
	test $$(echo "1+2" | ./calc) = 3
	test $$(echo "1+2*3" | ./calc) = 7
	test $$(echo "(1+2)*3" | ./calc) = 9
	test $$(echo "(1+2)*0" | ./calc) = 0
	test $$(echo "8/4/2" | ./calc) = 1
	test $$(echo "1-2-3" | ./calc) = -4
	test "$$(printf "1+1\n2+3\n" | ./calc)" = "$$(printf "2\n5\n")"
	! echo "1++2" | ./calc
	! echo "1+" | ./calc
	! echo "(1" | ./calc
	! echo "(1))" | ./calc

.PRECIOUS: %.c %.cc %.hh

CLEANFILES = \
  *~ *.o calc \
  parsecalc.cc parsecalc.hh parsecalc.output \
  scancalc.cc location.hh position.hh stack.hh

.PHONY: clean
clean:
	rm -f $(CLEANFILES)
