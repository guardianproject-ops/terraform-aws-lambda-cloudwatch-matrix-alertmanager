SOURCES = lambda_function.py
ARTIFACTS ?= ../artifacts/lambda

package: clean build
	mkdir -p $(ARTIFACTS)
	cp $(SOURCES) $(ARTIFACTS)

build:
	mkdir -p "${PWD}/package"

clean:
	rm -rf package
	rm -rf $(ARTIFACTS)

test:
	python3 -m unittest test.py

