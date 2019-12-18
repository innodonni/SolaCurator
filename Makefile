MAX_LABELS=10000
SHAREDOPTS='$$MAX_LABELS=$(MAX_LABELS)'
INCLUDE=/usr/share/inform6/library/,./
INFORM=inform $(SHAREDOPTS)
INFORM_GLULX=$(INFORM) +include_path=$(INCLUDE)
INFORM6=/usr/local/share/inform7/Compilers/inform6 $(SHAREDOPTS) +include_path=$(INCLUDE)
GLULXE=../glulxe/glulxe
FROTZ=frotz
DUMBFROTZ=/usr/local/share/inform7/Interpreters/dumb-frotz
SERIAL:=$(shell date +%y%m%d)

run:
	rm -f game.z5
	$(MAKE) game.z5
	$(FROTZ) $<

grun:
	rm -f game.blb
	$(MAKE) game.blb
	$(GLULXE) game.blb

game.z5: *.inf *.h
	$(INFORM) -pseD game.inf game.z5

all: clean all-tests run

.PHONY: all all-tests clean ztest gtest bless run grun ci release parchment quixe debug

game.blb: *.inf *.h
	$(INFORM_GLULX) -DGH game.inf game.blb

clean:
	$(RM) game.z5 release.inf release.z5 game.blb gameinfo.dbg test.input test.actual test.gactual web/interpreter/story.zblorb.js

test.input: test.script nouns.txt verbs.txt
	echo "script on" > test.input
	echo "test.actual" >> test.input
	cat test.script >> test.input
	cat nouns.txt >> test.input
	grep \* verbs.txt | sed -e 's/^\*//g' >> test.input
	#grep -v \* verbs.txt | while read i; do echo $$i >> test.input; sed "s/^/$$i /" nouns.txt >> test.input; done
	echo "quit" >> test.input
	echo "y" >> test.input
	echo >> test.input

test: ztest

all-tests: ztest gtest

ztest: game.z5 test.input test.expected
	echo "Serial \"191125\";" > serial.inf
	$(INFORM) game.inf game.z5
	$(RM) test.actual
	$(DUMBFROTZ) game.z5 <test.input
	$(RM) game.z5
	{ { { { diff test.expected test.actual 3>&- 4>&-; echo $$? >&3; } | less >&4; } 3>&1; } | { read xs; exit $$xs; }; } 4>&1 && $(RM) test.actual test.input

gtest: game.blb test.input test.gexpected
	echo "Serial \"191125\";" > serial.inf
	$(INFORM_GLULX) -GH game.inf game.blb
	$(RM) test.gactual
	sed 's/test.actual/test.gactual/' test.input > test.ginput
	$(GLULXE) game.blb <test.ginput
	$(RM) test.ginput game.blb
	{ { { { diff test.gexpected test.gactual 3>&- 4>&-; echo $$? >&3; } | less >&4; } 3>&1; } | { read xs; exit $$xs; }; } 4>&1 && $(RM) test.gactual test.input

bless: test.actual test.gactual
	mv test.actual test.expected
	mv test.gactual test.gexpected
	git add test.expected test.gexpected test.script verbs.txt nouns.txt

release: quixe game.z5
	cp game.blb ../innodonni/demo-$(SERIAL).blb
	cp game.z5 ../innodonni/demo-$(SERIAL).z5
	sed -i -E 's/demo-[0-9]{6}\.(z5|blb)/demo-$(SERIAL).\1/g' ../innodonni/README.md
	cp quixe/interpreter/story.blorb.js ../innodonni/interpreter
	cd ../innodonni && \
	git add . && \
	git commit -m "Sync" && \
	git push
	$(RM) game.blb game.z5

abbrev.inf: *.inf *.h
	$(INFORM) -u game.inf | grep "^Abbreviate" > abbrev.inf
	$(RM) game.z5

parchment: game.z5 abbrev.inf serial.inf
	cat abbrev.inf game.inf > release.inf
	$(INFORM) -pfse release.inf release.z5
	echo -n "processBase64Zcode('" > web/interpreter/story.zblorb.js
	base64 -w0 release.z5 >> web/interpreter/story.zblorb.js
	echo -n "')" >> web/interpreter/story.zblorb.js
	$(RM) abbrev.inf release.inf release.z5

quixe: *.inf *.h serial.inf
	$(INFORM_GLULX) -GH game.inf game.blb
	echo -n "\$$(document).ready(function() { GiLoad.load_run(null, '" > quixe/interpreter/story.blorb.js
	base64 -w0 game.blb >> quixe/interpreter/story.blorb.js
	echo -n "', 'base64'); });" >> quixe/interpreter/story.blorb.js

ci: test
	$(MAKE) clean
	git add .
	git commit

debug: *.inf *.h serial.inf
	$(INFORM6) -kG game.inf game.blb
	$(GLULXE) --crashtrap -D --gameinfo gameinfo.dbg game.blb 

serial.inf:
	echo "Serial \"$(SERIAL)\";" > serial.inf
