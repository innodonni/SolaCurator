run: game.z5
	frotz $<

game.z5: *.inf *.h
	inform -pseDX game.inf game.z5

all: clean test run

.PHONY: all clean test run ci release parchment quixe

game.blb: *.inf *.h
	inform -G +include_path=/usr/share/inform6/library/,./ game.inf game.blb

clean:
	$(RM) game.z5 release.inf release.z5 game.blb test.input test.actual web/interpreter/story.zblorb.js

test.input: test.script
	echo "script on" > test.input
	echo "test.actual" >> test.input
	cat test.script >> test.input
	echo "quit" >> test.input
	echo "y" >> test.input
	echo >> test.input

test: game.z5 test.input test.expected
	inform game.inf game.z5
	$(RM) test.actual
	/usr/local/share/inform7/Interpreters/dumb-frotz game.z5 <test.input
	diff test.actual test.expected && rm test.actual test.input

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
