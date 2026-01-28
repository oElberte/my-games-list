.PHONY: help l10n

help:
	@echo "Available targets:"
	@echo "  make l10n    - Generate localization files"
	@echo "  make help    - Show this help message"

l10n:
	cd lib/l10n; dart merge_arb.dart; cd ../..;
	flutter gen-l10n