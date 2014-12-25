#!/bin/sh

sqlite3 memos.db .schema > schema.sql
sqlite3 memos.db .dump   > memos.sql
