#!/bin/sh

rm memos.db
cat schema.sql | sqlite3 memos.db
