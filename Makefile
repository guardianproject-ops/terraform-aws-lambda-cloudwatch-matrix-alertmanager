export README_DEPS ?=  docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://gitlab.com/snippets/1957473/raw"; echo .build-harness)

## Test the lambda
test:
	cd lambda && $(MAKE) test

## Package the lambda deployment artifact
artifact:
	cd lambda && $(MAKE) package

## Clean the project
dist-clean:
	rm -rf artifacts/lambda/* artifacts.zip
