.PHONY: publish

publish:
	emacs -Q --script ./build-site.el
