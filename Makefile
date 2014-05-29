.SUFFIXES: .erl .beam .yrl 

MODS := $(wildcard *.erl)

%.beam: %.erl
	erlc -W $<

ERL = erl -boot start_clean

build: beams


test: beams 
	${ERL} -pa / -s test test


clean: 
	rm -rf *.beam *.html *.dump


beams: ${MODS:%.erl=%.beam}

