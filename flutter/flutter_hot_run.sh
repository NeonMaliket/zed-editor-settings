#!/bin/sh
cd "$(dirname "$0")/.." || exit 1

PID_FILE="/tmp/$(basename "$PWD")_flutter.pid"
STAMP="/tmp/$(basename "$PWD")_flutter.stamp"
rm -f "$PID_FILE"
touch "$STAMP"

(
   while true; do
      sleep 0.5
      [ -f "$PID_FILE" ] || continue
      touch "$STAMP.next"
      changed=$(find lib -name '*.dart' -newer "$STAMP" | head -1)
      mv "$STAMP.next" "$STAMP"
      if [ -n "$changed" ]; then
         kill -USR1 "$(cat "$PID_FILE")" 2>/dev/null
      fi
   done
) &
WATCHER=$!
trap 'kill $WATCHER 2>/dev/null; rm -f "$PID_FILE" "$STAMP" "$STAMP.next"' EXIT INT TERM

flutter run --pid-file "$PID_FILE" "$@"
