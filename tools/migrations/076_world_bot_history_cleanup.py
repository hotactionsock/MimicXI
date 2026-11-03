import mariadb

# Bots used to keep their activity log (and could keep their memories) after
# being deleted, so a new bot given the same charid inherited the old
# character's history - log sentences with the old name, deaths it never had.
# This removes, once:
#   * log rows of charids that are no longer bots
#   * for each bot, log rows from before its own 'created' event (the latest
#     one - earlier ones belong to previous characters with that charid)
#   * memories last touched before that bot was created
# Bots with no 'created' row are left alone.

LATEST_CREATED = (
    "SELECT charid, MAX(id) AS created_id, MAX(ts) AS created_ts FROM world_bot_log"
    " WHERE event = 'created' GROUP BY charid"
)


def migration_name():
    return "Removing world bot history left behind by deleted characters"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW TABLES LIKE 'world_bot_log'")
    if not cur.fetchone():
        return False

    cur.execute("SELECT 1 FROM world_bot_log WHERE charid NOT IN (SELECT charid FROM world_bots) LIMIT 1")
    if cur.fetchone():
        return True

    cur.execute(
        "SELECT 1 FROM world_bot_log l JOIN (" + LATEST_CREATED + ") c ON c.charid = l.charid"
        " WHERE l.id < c.created_id LIMIT 1"
    )
    if cur.fetchone():
        return True

    cur.execute("SHOW TABLES LIKE 'world_bot_memory'")
    if cur.fetchone():
        cur.execute(
            "SELECT 1 FROM world_bot_memory m JOIN (" + LATEST_CREATED + ") c ON c.charid = m.charid"
            " WHERE GREATEST(m.last_death, m.last_success) < c.created_ts LIMIT 1"
        )
        if cur.fetchone():
            return True

    return False


def migrate(cur, db):
    try:
        # Each bot's latest 'created' event, in a temporary table (a DELETE
        # can't read the table it deletes from).
        cur.execute("DROP TEMPORARY TABLE IF EXISTS bot_created")
        cur.execute("CREATE TEMPORARY TABLE bot_created AS " + LATEST_CREATED)

        cur.execute("DELETE FROM world_bot_log WHERE charid NOT IN (SELECT charid FROM world_bots)")
        cur.execute(
            "DELETE l FROM world_bot_log l JOIN bot_created c ON c.charid = l.charid"
            " WHERE l.id < c.created_id"
        )

        cur.execute("SHOW TABLES LIKE 'world_bot_memory'")
        if cur.fetchone():
            cur.execute("DELETE FROM world_bot_memory WHERE charid NOT IN (SELECT charid FROM world_bots)")
            cur.execute(
                "DELETE m FROM world_bot_memory m JOIN bot_created c ON c.charid = m.charid"
                " WHERE GREATEST(m.last_death, m.last_success) < c.created_ts"
            )

        cur.execute("DROP TEMPORARY TABLE IF EXISTS bot_created")
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
