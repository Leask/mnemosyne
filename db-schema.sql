CREATE VIRTUAL TABLE `memos` USING fts4 (
    `memo`       TEXT     NOT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME NOT NULL,
    `deleted_at` DATETIME NOT NULL,
    `status`     TEXT     NOT NULL,
    `last_hit`   DATETIME NOT NULL,
    `hits`       INTEGER  NOT NULL DEFAULT 0
);
