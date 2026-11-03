import mariadb


def migration_name():
    return "Adding world_bot_ah_prices - manual Auction House prices for world bots"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bot_ah_prices'")
    return not cur.fetchone()


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS `world_bot_ah_prices` (
                `itemid`       smallint(5) unsigned NOT NULL,
                `price_single` int(10) unsigned     NOT NULL DEFAULT 0,
                `price_stacks` int(10) unsigned     NOT NULL DEFAULT 0,
                `allow`        tinyint(1) unsigned  NOT NULL DEFAULT 1,
                `updated`      int(10) unsigned     NOT NULL DEFAULT 0,
                PRIMARY KEY (`itemid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
