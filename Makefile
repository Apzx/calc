CXX = clang++
BISON = bison
BISONFLAGS =
FLEX = flex
FLEXFLAGS =

all: calc

calc: parsecalc.o scancalc.o
	$(CXX) $^ -o $@

scancalc.o: parsecalc.hh

%.o: %.c
	$(CXX) $(CFLAGS) -c $< -o $@

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o $@ $<

%.cc: %.yy
	$(BISON) $(BISONFLAGS) $< -o $@

.PRECIOUS: %.cc %.hh

CLEANFILES = \
  *~ *.o calc \
  parsecalc.cc parsecalc.hh parsecalc.output \
  scancalc.cc location.hh position.hh stack.hh

.PHONY: clean
clean:
	rm -f $(CLEANFILES)
