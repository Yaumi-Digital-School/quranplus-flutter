#!/usr/bin/env bash
set -euo pipefail

# initiate_page.sh
# Scaffolds a new page under lib/pages/<page_name>/ following the project pattern:
#   <page_name>/
#     widgets/
#     <page_name>.dart                   (page widget)
#     <page_name>_state_notifier.dart    (state class + Riverpod notifier)
#
# After running this script, run build_runner to generate the .g.dart file:
#   dart run build_runner build --delete-conflicting-outputs

print_usage() {
  cat <<EOF
Usage: $(basename "$0") <page_name> [--stateful]

Arguments:
  page_name    snake_case name (e.g. notification_settings_page)

Options:
  --stateful   Use ConsumerStatefulWidget (default: ConsumerWidget)
  -h, --help   Show this help

Examples:
  $(basename "$0") notification_settings_page
  $(basename "$0") notification_settings_page --stateful
EOF
}

PAGE_NAME=""
STATEFUL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stateful)
      STATEFUL=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*)
      echo "Error: unknown option '$1'" >&2
      print_usage
      exit 1
      ;;
    *)
      if [[ -z "$PAGE_NAME" ]]; then
        PAGE_NAME="$1"
      else
        echo "Error: only one page name allowed (got '$PAGE_NAME' and '$1')" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$PAGE_NAME" ]]; then
  echo "Error: page name is required" >&2
  print_usage
  exit 1
fi

if [[ ! "$PAGE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: page name must be snake_case (lowercase letters, digits, underscores), starting with a letter." >&2
  echo "Got: '$PAGE_NAME'" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PAGES_DIR="$REPO_ROOT/lib/pages"

if [[ ! -d "$PAGES_DIR" ]]; then
  echo "Error: $PAGES_DIR does not exist" >&2
  exit 1
fi

PAGE_DIR="$PAGES_DIR/$PAGE_NAME"

if [[ -e "$PAGE_DIR" ]]; then
  echo "Error: '$PAGE_DIR' already exists" >&2
  exit 1
fi

# snake_case -> PascalCase
to_pascal_case() {
  local input="$1"
  local result=""
  local part
  IFS='_' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    result+="$(printf '%s' "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}"
  done
  printf '%s' "$result"
}

PASCAL_NAME="$(to_pascal_case "$PAGE_NAME")"
STATE_CLASS="${PASCAL_NAME}State"
NOTIFIER_CLASS="${PASCAL_NAME}Notifier"
STATE_NOTIFIER_BASENAME="${PAGE_NAME}_state_notifier"

# Provider name follows riverpod_generator: strip "Notifier" suffix, lowercase first char
# e.g. NotificationSettingsPageNotifier -> notificationSettingsPageProvider
PROVIDER_NAME="$(printf '%s' "${PASCAL_NAME:0:1}" | tr '[:upper:]' '[:lower:]')${PASCAL_NAME:1}Provider"

mkdir -p "$PAGE_DIR/widgets"
touch "$PAGE_DIR/widgets/.gitkeep"

cat > "$PAGE_DIR/${STATE_NOTIFIER_BASENAME}.dart" <<EOF
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${STATE_NOTIFIER_BASENAME}.g.dart';

class ${STATE_CLASS} {
  const ${STATE_CLASS}();

  ${STATE_CLASS} copyWith() {
    return const ${STATE_CLASS}();
  }
}

@riverpod
class ${NOTIFIER_CLASS} extends _\$${NOTIFIER_CLASS} {
  @override
  ${STATE_CLASS} build() {
    return const ${STATE_CLASS}();
  }
}
EOF

if $STATEFUL; then
  cat > "$PAGE_DIR/${PAGE_NAME}.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/${PAGE_NAME}/${STATE_NOTIFIER_BASENAME}.dart';

class ${PASCAL_NAME} extends ConsumerStatefulWidget {
  const ${PASCAL_NAME}({super.key});

  @override
  ConsumerState<${PASCAL_NAME}> createState() => _${PASCAL_NAME}State();
}

class _${PASCAL_NAME}State extends ConsumerState<${PASCAL_NAME}> {
  @override
  Widget build(BuildContext context) {
    final ${STATE_CLASS} state = ref.watch(${PROVIDER_NAME});

    return const Scaffold();
  }
}
EOF
else
  cat > "$PAGE_DIR/${PAGE_NAME}.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/${PAGE_NAME}/${STATE_NOTIFIER_BASENAME}.dart';

class ${PASCAL_NAME} extends ConsumerWidget {
  const ${PASCAL_NAME}({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${STATE_CLASS} state = ref.watch(${PROVIDER_NAME});

    return const Scaffold();
  }
}
EOF
fi

echo "Created:"
echo "  $PAGE_DIR/widgets/"
echo "  $PAGE_DIR/${PAGE_NAME}.dart  (${PASCAL_NAME})"
echo "  $PAGE_DIR/${STATE_NOTIFIER_BASENAME}.dart  (${STATE_CLASS}, ${NOTIFIER_CLASS})"
echo ""
echo "Next: run build_runner to generate ${STATE_NOTIFIER_BASENAME}.g.dart"
echo "  dart run build_runner build --delete-conflicting-outputs"
