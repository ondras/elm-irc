SOURCES := $(wildcard src/*.elm) $(wildcard src/Irc/*.elm)
TEMP := $(shell mktemp -u).js

all: elmer client
elmer: elmer.html
client: client.html

elmer.html: example/Elmer.elm $(SOURCES)
	elm make $^ --output $@

client.html: example/Client.elm $(SOURCES)
	elm make $^ --output $@

clean:
	rm -f elmer.html client.html

watch: all
	while inotifywait -e MODIFY -r src example ; do make $^ ; done

test:
	elm make tests/TestRunner.elm --output $(TEMP)
	node $(TEMP)
	rm $(TEMP)

.PHONY: all elmer client test
