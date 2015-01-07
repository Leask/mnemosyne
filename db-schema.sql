CREATE TABLE `memos` (
    `id`         INTEGER PRIMARY KEY AUTOINCREMENT,
    `memo`       TEXT     NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME NOT NULL,
    `deleted_at` DATETIME NOT NULL,
    `status`     TEXT     NOT NULL,
    `last_hit`   DATETIME NOT NULL,
    `hits`       INTEGER  NOT NULL DEFAULT 0
);
