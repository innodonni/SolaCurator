run: game.z5
	frotz $<

game.z5: *.inf *.h
	inform -D -X game.inf game.z5

all: run

.PHONY: all run

game.blb: *.inf *.h
	inform -G +include_path=/usr/share/inform6/library/,./ game.inf game.blb
