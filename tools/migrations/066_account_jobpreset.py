import mariadb


def migration_name():
    return "Adding account_jobpreset table for squad job lineups"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'account_jobpreset'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `account_jobpreset` (
                `accid`  int(10) unsigned    NOT NULL,
                `name`   varchar(24)         NOT NULL,
                `charid` int(10) unsigned    NOT NULL,
                `mjob`   tinyint(2) unsigned NOT NULL DEFAULT 0,
                `sjob`   tinyint(2) unsigned NOT NULL DEFAULT 0,
                PRIMARY KEY (`accid`, `name`, `charid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
