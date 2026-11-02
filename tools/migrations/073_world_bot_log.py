import mariadb


def migration_name():
    return "Adding world_bot_log activity log for AI world bots"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bot_log'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `world_bot_log` (
                `id`       bigint(20) unsigned  NOT NULL AUTO_INCREMENT,
                `charid`   int(10) unsigned     NOT NULL,
                `ts`       int(10) unsigned     NOT NULL,
                `zone_id`  smallint(5) unsigned NOT NULL DEFAULT 0,
                `category` varchar(16)          NOT NULL,
                `event`    varchar(32)          NOT NULL,
                `message`  varchar(255)         NOT NULL,
                `data`     text                 NOT NULL,
                PRIMARY KEY (`id`),
                KEY `charid_ts` (`charid`, `ts`),
                KEY `ts` (`ts`),
                KEY `category_ts` (`category`, `ts`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
