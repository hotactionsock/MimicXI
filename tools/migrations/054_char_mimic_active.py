import mariadb


def migration_name():
    return "Adding char_mimic_active table for mimic trusts"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'char_mimic_active'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            CREATE TABLE `char_mimic_active` (
                `charid` int(10) unsigned NOT NULL,
                `master_charid` int(10) unsigned NOT NULL,
                `spawned_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`charid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
