#!/bin/zsh
PG=/opt/homebrew/opt/postgresql@18/bin
DATA=/opt/homebrew/var/postgresql@18
JOB=sh.brew.postgresql@18
for attempt in 1 2 3 4 5; do
  brew services stop postgresql@18 >/dev/null 2>&1
  for i in {1..600}; do
    if ! launchctl print gui/$UID/$JOB >/dev/null 2>&1 && ! $PG/pg_ctl -D $DATA status >/dev/null 2>&1; then break; fi
    perl -e 'select(undef,undef,undef,0.5)'
  done
  perl -e 'select(undef,undef,undef,2)'
  brew services start postgresql@18 >/dev/null 2>&1
  for i in {1..120}; do
    if $PG/pg_isready -q; then exit 0; fi
    perl -e 'select(undef,undef,undef,0.5)'
  done
  echo "restart attempt $attempt failed" >&2
done
exit 1
