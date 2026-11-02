import mariadb


def migration_name():
    return "Adding career_job to world_bots"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW COLUMNS FROM world_bots LIKE 'career_job'")
    if cur.fetchone():
        return False

    return True


def migrate(cur, db):
    try:
        cur.execute(
            """
            ALTER TABLE world_bots
                ADD COLUMN `career_job` tinyint(2) unsigned NOT NULL DEFAULT 0 AFTER `anchor_z`;
            """
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
