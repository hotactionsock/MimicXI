import mariadb


def migration_name():
    return "Adding world_bot_memory - what AI world bots learn from experience"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bot_memory'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `world_bot_memory` (
                `charid`       int(10) unsigned     NOT NULL,
                `kind`         tinyint(3) unsigned  NOT NULL,
                `ref`          int(10) unsigned     NOT NULL,
                `deaths`       smallint(5) unsigned NOT NULL DEFAULT 0,
                `successes`    smallint(5) unsigned NOT NULL DEFAULT 0,
                `exp`          int(10) unsigned     NOT NULL DEFAULT 0,
                `last_death`   int(10) unsigned     NOT NULL DEFAULT 0,
                `last_success` int(10) unsigned     NOT NULL DEFAULT 0,
                `death_level`  tinyint(3) unsigned  NOT NULL DEFAULT 0,
                PRIMARY KEY (`charid`, `kind`, `ref`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
