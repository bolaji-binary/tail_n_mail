NOECHO = @
TEST_FILES = tests/[0-9]*.test

test_release test:
	$(NOECHO) prove $(TEST_FILES)

fulltest:
	$(NOECHO) RELEASE_TESTING=1 prove $(TEST_FILES)
