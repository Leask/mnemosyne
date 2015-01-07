#!/usr/bin/env node
//

// load requirements
var env    = require('./env'),
    memo   = require('./memo'),
    table  = require('cli-table'),
    moment = require('moment');

// check configurations
if (!env) {
    console.log(':( Error loading configurations');
    process.exit(1);
}

// patch prototypes
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/gm, '');
    };
}

// init
memo.Init(env);

var relativeTime = function(absTime) {
    return moment(absTime).fromNow();
};

var renderMemos = function(memos) {
    var output = new table({
        head: ['ID', 'MEMO', 'HIT', 'CREATED', 'UPDATED', 'LAST HIT']
      , colWidths: [5, 50, 5, 20, 20, 20]
    });
    for (var i = 0; i < memos.length; i++) {
        output.push([
            memos[i].rowid,
            memos[i].memo,
            memos[i].hits,
            relativeTime(memos[i].created_at),
            relativeTime(memos[i].updated_at),
            relativeTime(memos[i].last_hit)
        ]);
    }
    console.log(output.toString());
};

var list = function() {
    memo.GetAll(function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        renderMemos(data);
    });
};

var touch = function(text) {
    memo.Touch(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        renderMemos([data]);
    })
};

var search = function() {
    memo.Search(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        renderMemos(data);
    })
};

var fetchStdin = function(callback) {
    var stdinChunk = null;
    process.stdin.setEncoding('utf8');
    process.stdin.on('readable', function() {
        var chunk = process.stdin.read();
        stdinChunk += chunk ? chunk : '';
    });
    process.stdin.on('end', function() {
        callback(null, stdinChunk);
    });
};

var help = function() {
    console.log('- l / list   : text');
    console.log('- t / touch  : text');
    console.log('- s / search : text');
    console.log('- h / help   : text');
}

var unknownCommand = function() {
    console.log(':( Unknown command');
};

// main
process.argv.shift();
process.argv.shift();
var command = process.argv.shift();
var text    = process.argv.join(' ').trim();
switch (command) {
    case 'list':
    case 'l':
        list();
        break;
    case 'touch':
    case 't':
        touch(text);
        break;
    case 'search':
    case 's':
        search(text);
        break;
    case 'help':
    case 'h':
        help();
        break;
    default:
        unknownCommand();
        process.exit(1);
}
if (process.stdin._readableState.highWaterMark) {
    // fetchStdin(parseList);
} else {
    // fetchList(parseList);
}
