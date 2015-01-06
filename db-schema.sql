CREATE VIRTUAL TABLE `memos` USING fts4 (
    `memo` TEXT NOT NULL,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `deleted_at` DATETIME,
    `status` TEXT,
    `first_matched` DATETIME,
    `last_matched` DATETIME,
    `hits` INTEGER DEFAULT 0
);
