#!/usr/bin/env bash
#
# Fails when a user-facing string is hardcoded instead of going through
# context.l10n.* in lib/features. Keeps the pt-BR localization honest and
# prevents new English literals from creeping into the launch-critical screens.
#
# PENDING files are temporarily excluded until their own localization PR lands.
# This list must shrink to zero (tracked by issue #2).
set -euo pipefail

PENDING=(
  'add_to_library_bottom_sheet.dart' # TODO(#2): localize the add/edit form
  'library_entry_model.dart'         # GameStatus.displayName fallback used by the form above
)

is_pending() {
  local base
  base=$(basename "$1")
  for p in "${PENDING[@]}"; do [ "$base" = "$p" ] && return 0; done
  return 1
}

# A user-facing literal: a capitalized string passed positionally to Text(...)
# or to a common string-typed named argument. Newlines are collapsed first so
# that `dart format` line wrapping — e.g. Text(\n  'Long sentence') — is still
# caught (a same-line-only regex silently misses those).
pattern="Text\( *['\"][A-Z]|(tooltip|hintText|labelText|label): *['\"][A-Z]"

fail=0
while IFS= read -r f; do
  is_pending "$f" && continue
  if tr '\n' ' ' <"$f" | tr -s ' ' | grep -qE "$pattern"; then
    echo "❌ $f: hardcoded user-facing string (use context.l10n.*)"
    fail=1
  fi
done < <(find lib/features lib/core -name '*.dart')

if [ "$fail" = 1 ]; then
  echo "Found hardcoded user-facing strings — route them through context.l10n.*"
  exit 1
fi

echo "✅ No hardcoded user-facing string literals in lib/features or lib/core."
