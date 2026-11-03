import mariadb


def migration_name():
    return "Adding logged_out_at to world_bots (online population)"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW COLUMNS FROM world_bots LIKE 'logged_out_at'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            ALTER TABLE world_bots
                ADD COLUMN `logged_out_at` int(10) unsigned NOT NULL DEFAULT 0 AFTER `logged_out_until`;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
