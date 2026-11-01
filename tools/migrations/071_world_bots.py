import mariadb


def migration_name():
    return "Adding world_bots registry for AI-driven world-population bots"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bots'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `world_bots` (
                `charid`   int(10) unsigned    NOT NULL,
                `active`   tinyint(1) unsigned NOT NULL DEFAULT 0,
                `anchor_x` float(7,3)          NOT NULL DEFAULT 0,
                `anchor_y` float(7,3)          NOT NULL DEFAULT 0,
                `anchor_z` float(7,3)          NOT NULL DEFAULT 0,
                PRIMARY KEY (`charid`),
                KEY `active` (`active`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
