run: game.z5
	frotz $<

game.z5: *.inf *.h
	inform -D -X game.inf game.z5

all: clean test run

.PHONY: all clean test run ci

game.blb: *.inf *.h
	inform -G +include_path=/usr/share/inform6/library/,./ game.inf game.blb

clean:
	$(RM) game.z5 game.blb test.input test.actual web/interpreter/story.zblorb.js

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

release: game.z5
	echo -n "processBase64Zcode('" > web/interpreter/story.zblorb.js
	base64 -w0 game.z5 >> web/interpreter/story.zblorb.js
	echo -n "')" >> web/interpreter/story.zblorb.js

ci: test
	$(MAKE) clean
	git add .
	git commit
