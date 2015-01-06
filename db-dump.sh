#!/bin/sh

configDir=~/.mnemosyne
dbFile=$configDir/memos.db
if [ ! -e $configDir ]; then
    mkdir $configDir
fi
if [ -e $dbFile ]; then
    sqlite3 $dbFile .schema > db-schema.sql
    sqlite3 $dbFile .dump   > db-dump.sql
    echo ':) Done'
else
    echo ':( Failed'
    exit 1
fi
