#!/bin/sh
set -e
npx typeorm migration:run -d dist/database/data-source.js
exec node dist/main
