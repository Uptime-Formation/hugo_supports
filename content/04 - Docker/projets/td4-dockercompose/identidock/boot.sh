#!/bin/bash
set -e
if [ "$CONTEXT" = 'DEV' ]; then
    echo "Running Development Server"
    FLASK_ENV=development exec python "/app/identidock.py"
else
    echo "Running Production Server"
    exec uwsgi --socket 0.0.0.0:5000 -b 50000 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191
fi