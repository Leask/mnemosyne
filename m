#!/usr/bin/env node
//

// load requirements
var env    = require('./env'),
    memo   = require('./memo'),
    table  = require('cli-table'),
    moment = require('moment');

// utilities
var type = function(object) {
    return Object.prototype.toString.call(object).slice(8, -1).toLowerCase();
}

var isArray = function(object) {
    return type(object) === 'array';
}

var absoluteTime = function(rawTime) {
    return new Date(rawTime).toString();
};

var relativeTime = function(rawTime) {
    return moment(rawTime).fromNow();
};

var exit = function() {
    memo.Del();
    process.exit(1);
}

// check configurations
if (!env) {
    console.log(':( Error loading configurations');
    exit();
}

// patch prototypes
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/gm, '');
    };
}

// functions
var renderMemo = function(memo) {
    console.log(
        'ID       : ' + memo.id                       + '\n'
      + 'HITS     : ' + memo.hits                     + '\n'
      + 'CREATED  : ' + absoluteTime(memo.created_at) + '\n'
      + 'UPDATED  : ' + absoluteTime(memo.updated_at) + '\n'
      + 'LAST HIT : ' + absoluteTime(memo.last_hit)   + '\n'
      + 'MEMO     : ' + memo.memo
    );
}

var renderMemos = function(memos) {
    var width = {
        ID       : 7,
        MEMO     : process.stdout.columns,
        HITS     : 7,
        CREATED  : 21,
        UPDATED  : 21,
        LAST_HIT : 21
    };
    for (var i in width) {
        if (i !== 'MEMO') {
            width.MEMO -= width[i] + 2;
        }
    }
    var output = new table({
        head      : ['ID', 'MEMO', 'HITS', 'CREATED', 'UPDATED', 'LAST HIT'],
        colWidths : [width.ID     , width.MEMO   , width.HITS,
                     width.CREATED, width.UPDATED, width.LAST_HIT]
    });
    console.log(
        'Mnemosyne found ' + memos.length + ' memo'
      + (memos.length > 1 ? 's' : '')
      + ' for you @ ' + new Date() + ': '
    )
    for (i = 0; i < memos.length; i++) {
        output.push([
            memos[i].id,
            memos[i].memo.replace(/\n/g, ' '),
            memos[i].hits,
            relativeTime(memos[i].created_at),
            relativeTime(memos[i].updated_at),
            relativeTime(memos[i].last_hit)
        ]);
    }
    console.log(output.toString());
};

var render = function(data) {
    return isArray(data) ? renderMemos(data) : renderMemo(data);
};

var checkId = function(id) {
    id = Number(id);
    if (isNaN(id)) {
        console.log(':( Error memo id');
        exit();
    }
    return id;
};

var get = function(id) {
    memo.GetById(checkId(id), function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        render(data);
    });
};

var del = function(id) {
    memo.DelById(checkId(id), function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        console.log(':) Done');
    });
};

var touch = function(text) {
    memo.Touch(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        render(data);
    })
};

var search = function() {
    memo.Search(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        render(data);
    })
};

var trash = function() {
    memo.GetTrash(function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        render(data);
    })
};

var empty = function() {
    memo.EmptyTrash(function(err, data) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        console.log(':) Done');
    })
};

var fetchStdin = function(callback) {
    var stdinChunk = '';
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
    console.log('- (t)ouch  : text');
    console.log('- (s)earch : text');
    console.log('- (g)et    : text');
    console.log('- t(r)ash  : text');
    console.log('- DEL      : text');
    console.log('- EMPTY    : text');
    console.log('- (h)elp   : text');
}

var unknownCommand = function() {
    console.log(':( Unknown command');
};

var exec = function() {
    command = (command || 'touch').trim();
    text    = (text    || ''     ).trim();
    switch (command) {
        case 'touch':
        case 't':
            touch(text);
            break;
        case 'search':
        case 's':
            search(text);
            break;
        case 'get':
        case 'g':
            get(text);
            break;
        case 'trash':
        case 'r':
            trash();
            break;
        case 'DEL':
            del(text);
            break;
        case 'EMPTY':
            empty();
            break;
        case 'help':
        case 'h':
            help();
            break;
        default:
            unknownCommand();
            exit();
    }
};

// main
memo.Init(env);
process.argv.shift();
process.argv.shift();
var command = process.argv.shift();
var text    = process.argv.join(' ');
if (process.stdin._readableState.highWaterMark) {
    fetchStdin(function(err, text) {
        if (err) {
            console.log(':( ' + err);
            exit();
        }
        exec();
    });
} else {
    exec();
}
