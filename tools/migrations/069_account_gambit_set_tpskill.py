import mariadb


def migration_name():
    return "Adding tp_trigger/tp_selector/tp_actionid columns to account_gambit_set (weaponskill config)"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW COLUMNS FROM account_gambit_set LIKE 'tp_trigger'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            ALTER TABLE `account_gambit_set`
                ADD COLUMN `tp_trigger`  tinyint(3) unsigned  NOT NULL DEFAULT 0,
                ADD COLUMN `tp_selector` tinyint(3) unsigned  NOT NULL DEFAULT 3,
                ADD COLUMN `tp_actionid` smallint(5) unsigned NOT NULL DEFAULT 0;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
