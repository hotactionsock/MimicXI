import mariadb


def migration_name():
    return "Adding world_bot_watch / world_bot_live - live bot view for the website"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bot_live'")
    if not cur.fetchone():
        return True

    cur.execute("SHOW TABLES LIKE 'world_bot_watch'")
    return not cur.fetchone()


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS `world_bot_watch` (
                `charid`   int(10) unsigned NOT NULL,
                `until_ts` int(10) unsigned NOT NULL DEFAULT 0,
                PRIMARY KEY (`charid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS `world_bot_live` (
                `charid`  int(10) unsigned     NOT NULL,
                `ts`      int(10) unsigned     NOT NULL DEFAULT 0,
                `zone_id` smallint(5) unsigned NOT NULL DEFAULT 0,
                `data`    mediumtext           NOT NULL,
                PRIMARY KEY (`charid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
