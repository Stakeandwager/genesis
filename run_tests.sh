#!/bin/bash
# Run the Genesis tests.
#
#   ./run_tests.sh /path/to/Godot_v4.7.1-stable_linux.x86_64
#   ./run_tests.sh /path/to/godot --all      also runs the slow racing suites
#
# Nothing is copied and no scratch project is built: the tests live in this
# repository and run against the scripts beside them, so what is tested is
# what is committed.
#
# Each suite prints its own result line. A suite ending "failures=0" or
# "bad=0" passed; sweep_test prints a VERDICT instead, because what it reports
# is a finding rather than a pass.
set -u
GODOT=${1:-godot}
ALL=${2:-}
cd "$(dirname "$0")"

# Suites that need physics stepped at a fixed rate.
TIMED="carry_test false_delivery_test ledger_audit_test order_test explore_test walker_test walk_physics_test behaviour_test physics_test interference_test repeat_test drive_test session_test report_test"
# Suites that take minutes, not seconds: several full races apiece.
SLOW="drive_test session_test"
# Known broken, kept so nobody rediscovers it: hangs with no output at all.
BROKEN="report_test"
# Not suites. replay.gd is a tool that needs REPLAY_LOG and REPLAY_OUT set and
# fails without them; prompt_test prints the AI's prompt for a human to read
# and has no verdict to give. Neither failing here would mean anything.
NOT_A_SUITE="replay prompt_test"

"$GODOT" --headless --import >/dev/null 2>&1

fails=0
for f in tests/*.gd; do
  name=$(basename "$f" .gd)
  case " $BROKEN " in *" $name "*) printf '%-22s skipped (known broken)\n' "$name"; continue ;; esac
  case " $NOT_A_SUITE " in *" $name "*) printf '%-22s skipped (not a suite)\n' "$name"; continue ;; esac
  case " $SLOW " in
    *" $name "*)
      if [ "$ALL" != "--all" ]; then
        printf '%-22s skipped (slow; pass --all)\n' "$name"
        continue
      fi ;;
  esac
  args=""
  case " $TIMED " in *" $name "*) args="--fixed-fps 120" ;; esac

  out=$(timeout 600 "$GODOT" --headless $args --script "$f" 2>&1)
  if echo "$out" | grep -qE "SCRIPT ERROR|Parse Error"; then
    line="SCRIPT ERROR"
  else
    line=$(echo "$out" | grep -E "failures=|bad=|VERDICT" | tail -1)
  fi
  printf '%-22s %s\n' "$name" "${line:-no result}"
  case "$line" in
    *failures=0|*bad=0|VERDICT*) ;;
    *) fails=$((fails+1)) ;;
  esac
done

echo
echo "suites with something to look at: $fails"
exit $fails
