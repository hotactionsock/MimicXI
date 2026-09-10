import mariadb


def migration_name():
    return "Adding account_squad table for mimic-trust squad rosters"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'account_squad'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `account_squad` (
                `accid`  int(10) unsigned    NOT NULL,
                `slot`   tinyint(1) unsigned NOT NULL,
                `charid` int(10) unsigned    NOT NULL,
                PRIMARY KEY (`accid`, `slot`),
                KEY `charid` (`charid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
