#!/bin/sh

echo "[reverb] Starting Laravel reverb..."

while true; do
  php artisan reverb:start \
    --host="0.0.0.0" \
    --port="8080" \
    --verbose

  echo "[reverb] Reverb exited. Restarting in 5 seconds..."
  sleep 5
done
