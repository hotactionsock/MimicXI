import mariadb


def migration_name():
    return "Adding account_gambit_set/rule/assign tables for player-authored trust gambits"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'account_gambit_set'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `account_gambit_set` (
                `setid`  int(10) unsigned    NOT NULL AUTO_INCREMENT,
                `accid`  int(10) unsigned    NOT NULL,
                `name`   varchar(24)         NOT NULL,
                PRIMARY KEY (`setid`),
                UNIQUE KEY `accid_name` (`accid`, `name`),
                KEY `accid` (`accid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        cur.execute(
            """
            CREATE TABLE `account_gambit_rule` (
                `setid`    int(10) unsigned    NOT NULL,
                `ordinal`  tinyint(3) unsigned NOT NULL,
                `target`   tinyint(3) unsigned NOT NULL,
                `cond`     tinyint(3) unsigned NOT NULL,
                `arg`      smallint(5) unsigned NOT NULL DEFAULT 0,
                `reaction` tinyint(3) unsigned NOT NULL,
                `selector` tinyint(3) unsigned NOT NULL,
                `actionid` smallint(5) unsigned NOT NULL DEFAULT 0,
                PRIMARY KEY (`setid`, `ordinal`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        cur.execute(
            """
            CREATE TABLE `account_gambit_assign` (
                `accid`  int(10) unsigned    NOT NULL,
                `charid` int(10) unsigned    NOT NULL,
                `mjob`   tinyint(2) unsigned NOT NULL,
                `setid`  int(10) unsigned    NOT NULL,
                PRIMARY KEY (`accid`, `charid`, `mjob`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
