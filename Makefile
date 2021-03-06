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
	$(FROTZ) game.z5

grun:
	rm -f game.blb
	$(MAKE) game.blb
	$(GLULXE) game.blb

game.z5: *.inf *.h
	$(INFORM) -pseDd2 game.inf game.z5

all: clean all-tests run

.PHONY: all all-tests clean ztest gtest bless run grun ci release parchment quixe debug

game.blb: *.inf *.h
	$(INFORM_GLULX) -DGH game.inf game.blb

clean:
	$(RM) game.z5 release.inf release.z5 game.blb gameinfo.dbg test.input test.actual test.gactual web/interpreter/story.zblorb.js latest.tmp

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
	echo "Constant TESTING;" >> serial.inf
	$(INFORM) -d2 game.inf game.z5
	$(RM) test.actual
	$(DUMBFROTZ) game.z5 <test.input
	$(RM) game.z5
	{ { { { diff test.expected test.actual 3>&- 4>&-; echo $$? >&3; } | less >&4; } 3>&1; } | { read xs; exit $$xs; }; } 4>&1 && $(RM) test.actual test.input

gtest: game.blb test.input test.gexpected
	echo "Serial \"191125\";" > serial.inf
	echo "Constant TESTING;" >> serial.inf
	$(INFORM_GLULX) -GHd2 game.inf game.blb
	$(RM) test.gactual
	sed 's/test.actual/test.gactual/' test.input > test.ginput
	$(GLULXE) game.blb <test.ginput
	$(RM) test.ginput game.blb
	{ { { { diff test.gexpected test.gactual 3>&- 4>&-; echo $$? >&3; } | less >&4; } 3>&1; } | { read xs; exit $$xs; }; } 4>&1 && $(RM) test.gactual test.input

bless: test.actual test.gactual
	mv test.actual test.expected
	mv test.gactual test.gexpected
	git add test.expected test.gexpected test.script verbs.txt nouns.txt

latest.tmp: ../innodonni/README.md
	cat ../innodonni/README.md | sed -nE 's/.*latest.*\(demo-([0-9]{6}).z5\)\./\1/p' > latest.tmp

release: quixe game.z5 latest.tmp
	cp game.blb ../innodonni/demo-$(SERIAL).blb
	cp game.z5 ../innodonni/demo-$(SERIAL).z5
	mv ../innodonni/demo-$(shell cat latest.tmp).blb ../innodonni/versions/
	mv ../innodonni/demo-$(shell cat latest.tmp).z5 ../innodonni/versions/
	mv ../innodonni/interpreter/story.blorb.js ../innodonni/versions/demo-$(shell cat latest.tmp).blorb.js
	sed -i -E '/Old versions/a \\n* $(shell cat latest.tmp) [Online](play.html?story=versions/demo-$(shell cat latest.tmp).blorb.js) [Z-Machine](versions/demo-$(shell cat latest.tmp).z5) [Glulx](versions/demo-$(shell cat latest.tmp).blb)' ../innodonni/README.md
	sed -i -E 's/(.*latest.*)demo-[0-9]{6}\.(z5|blb)(.*)/\1demo-$(SERIAL).\2\3/g' ../innodonni/README.md
	cp quixe/interpreter/story.blorb.js ../innodonni/interpreter
	$(RM) game.blb game.z5 latest.tmp
	cd ../innodonni && \
	git add . && \
	git commit -m "Sync" && \
	git push

abbrev.inf: *.inf *.h
	$(INFORM) -ud2 game.inf | grep "^Abbreviate" > abbrev.inf
	$(RM) game.z5

parchment: game.z5 abbrev.inf serial.inf
	cat abbrev.inf game.inf > release.inf
	$(INFORM) -pfsed2 release.inf release.z5
	echo -n "processBase64Zcode('" > web/interpreter/story.zblorb.js
	base64 -w0 release.z5 >> web/interpreter/story.zblorb.js
	echo -n "')" >> web/interpreter/story.zblorb.js
	$(RM) abbrev.inf release.inf release.z5

quixe: *.inf *.h serial.inf
	$(INFORM_GLULX) -GHd2 game.inf game.blb
	echo -n "\$$(document).ready(function() { GiLoad.load_run(null, '" > quixe/interpreter/story.blorb.js
	base64 -w0 game.blb >> quixe/interpreter/story.blorb.js
	echo -n "', 'base64'); });" >> quixe/interpreter/story.blorb.js

ci: test
	$(MAKE) clean
	git add .
	git commit

debug: *.inf *.h serial.inf
	$(INFORM6) -kGd2 game.inf game.blb
	$(GLULXE) --crashtrap -D --gameinfo gameinfo.dbg game.blb 

serial.inf:
	echo "Serial \"$(SERIAL)\";" > serial.inf
