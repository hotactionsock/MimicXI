import mariadb


def migration_name():
    return "Adding account_warehouse + account_warehouse_meta for the mwarehouse addon stash"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'account_warehouse'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `account_warehouse` (
                `rowid`     int(10) unsigned     NOT NULL AUTO_INCREMENT,
                `accid`     int(10) unsigned     NOT NULL,
                `itemId`    smallint(5) unsigned NOT NULL DEFAULT 0,
                `quantity`  int(10) unsigned     NOT NULL DEFAULT 0,
                `signature` varchar(20)          NOT NULL DEFAULT '',
                `extra`     blob(24)             DEFAULT NULL,
                PRIMARY KEY (`rowid`),
                KEY `accid` (`accid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        cur.execute(
            """
            CREATE TABLE `account_warehouse_meta` (
                `accid`      int(10) unsigned NOT NULL,
                `generation` int(10) unsigned NOT NULL DEFAULT 0,
                PRIMARY KEY (`accid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
