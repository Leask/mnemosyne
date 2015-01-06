#!/bin/sh

configDir=~/.mnemosyne
dbFile=$configDir/memos.db
if [ ! -e $configDir ]; then
    mkdir $configDir
fi
if [ -e $dbFile ]; then
    rm $dbFile
fi
cat db-schema.sql | sqlite3 $dbFile
echo ':) Done'
