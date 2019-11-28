run: game.z5
	[ -z "$(OPTS)" ] || rm -f game.z5
	$(MAKE) game.z5
	frotz $<

game.z5: *.inf *.h
	inform -pseDX $(OPTS) game.inf game.z5

all: clean test run

.PHONY: all clean test run ci release parchment quixe

game.blb: *.inf *.h
	inform -GH +include_path=/usr/share/inform6/library/,./ game.inf game.blb

clean:
	$(RM) game.z5 release.inf release.z5 game.blb test.input test.actual web/interpreter/story.zblorb.js

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

test: game.z5 test.input test.expected
	inform game.inf game.z5
	$(RM) test.actual
	/usr/local/share/inform7/Interpreters/dumb-frotz game.z5 <test.input
	$(RM) game.z5
	{ { { { diff test.actual test.expected 3>&- 4>&-; echo $$? >&3; } | less >&4; } 3>&1; } | { read xs; exit $$xs; }; } 4>&1 && $(RM) test.actual test.input
	#diff test.actual test.expected | less && $(RM) test.actual test.input

release: parchment

parchment: game.z5 abbrev.inf
	cat abbrev.inf game.inf > release.inf
	inform -pfse release.inf release.z5
	echo -n "processBase64Zcode('" > web/interpreter/story.zblorb.js
	base64 -w0 release.z5 >> web/interpreter/story.zblorb.js
	echo -n "')" >> web/interpreter/story.zblorb.js
	$(RM) release.inf release.z5

quixe: game.blb
	echo -n "\$$(document).ready(function() { GiLoad.load_run(null, '" > quixe/interpreter/story.blorb.js
	base64 -w0 game.blb >> quixe/interpreter/story.blorb.js
	echo -n "', 'base64'); });" >> quixe/interpreter/story.blorb.js
	$(RM) game.blb

ci: test
	$(MAKE) clean
	git add .
	git commit
