import mariadb


def migration_name():
    return "Adding the world bot Auction House purse (world_bots.ah_purse) and unsold-item memory (world_bot_ah)"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW COLUMNS FROM world_bots LIKE 'ah_purse'")
    if not cur.fetchone():
        return True

    cur.execute("SHOW TABLES LIKE 'world_bot_ah'")
    return not cur.fetchone()


def migrate(cur, db):
    try:
        cur.execute("SHOW COLUMNS FROM world_bots LIKE 'ah_purse'")
        if not cur.fetchone():
            cur.execute(
                """
                ALTER TABLE world_bots
                    ADD COLUMN `ah_purse` int(10) unsigned NOT NULL DEFAULT 0 AFTER `logged_out_until`;
                """
            )

        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS `world_bot_ah` (
                `charid`    int(10) unsigned     NOT NULL,
                `itemid`    smallint(5) unsigned NOT NULL,
                `fails`     tinyint(3) unsigned  NOT NULL DEFAULT 0,
                `last_fail` int(10) unsigned     NOT NULL DEFAULT 0,
                PRIMARY KEY (`charid`, `itemid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
