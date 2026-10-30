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
TIMED="carry_test false_delivery_test ledger_audit_test ledger_said_test order_test explore_test walker_test walk_physics_test behaviour_test physics_test interference_test repeat_test drive_test session_test report_test controller_reach_test"
# Suites that take minutes, not seconds: several full races apiece.
SLOW="drive_test session_test"
# Known broken. Empty since 024: report_test was here from 014, recorded as
# "hangs with no output at all, cause unknown". It never hung. It threw a
# script error on a key that 012 deleted, and a script error in a SceneTree
# aborts _initialize before quit(), so the process ran until the timeout below
# killed it. See TRAPS 13 before adding anything to this list: a suite that
# sits here unread goes stale against the code it is supposed to measure.
BROKEN=""
# Not suites. replay.gd is a tool that needs REPLAY_LOG and REPLAY_OUT set and
# exits 1 naming the missing one; prompt_test prints the TOOLS section of the
# AI's prompt, and four EQUIP readbacks, for a human to read, and has no
# verdict to give. Neither failing here would mean anything.
# 102: that said "prints the AI's prompt", here and in two other places, from
# 006 to 101. It prints ToolRegistry.prompt_sections() - ONE of the three
# registry sections AIInterpreter.assembled_prompt() concatenates onto
# SYSTEM_PROMPT - and no world at all. Held by field_type_test section 8,
# which counts the sections off both sources.
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
  rc=$?
  if echo "$out" | grep -qE "SCRIPT ERROR|Parse Error"; then
    # Say which error and where. Reported as a bare "SCRIPT ERROR" for ten
    # releases, this cost report_test its place on the BROKEN list: the error
    # names the file and line, and reading it would have taken a minute.
    line="SCRIPT ERROR: $(echo "$out" | grep -E "SCRIPT ERROR|Parse Error" | head -1 | sed 's/^[[:space:]]*//')"
  elif [ "$rc" -eq 124 ]; then
    # timeout killed it. A suite whose quit() is never reached looks exactly
    # like a hang, and calling that "no result" is what made TRAPS 13 a
    # mystery instead of a one-minute read. Never report it as no result.
    line="TIMED OUT after 600s (quit() never reached? run it alone and read stderr)"
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
