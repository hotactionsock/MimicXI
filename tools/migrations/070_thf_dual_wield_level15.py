import mariadb


def migration_name():
    return "THF Dual Wield (trait 18, rank 1) moved to level 15 and un-gated from ABYSSEA content"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SELECT 1 FROM traits WHERE traitid = 18 AND job = 6 AND rank = 1 AND level = 83;")
    return cur.fetchone() is not None


def migrate(cur, db):
    try:
        cur.execute(
            "UPDATE traits SET level = 15, content_tag = NULL "
            "WHERE traitid = 18 AND job = 6 AND rank = 1;"
        )
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
