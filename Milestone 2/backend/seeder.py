import socket
import database


SEED_MARKER_KEY = "seeded_v1"


def create_table():
	sql = (
		"CREATE TABLE IF NOT EXISTS info ("
		"id SERIAL PRIMARY KEY, "
		"name TEXT"
		")"
	)
	return database.execute_sql_query(sql)


def insert_info(name: str):
	sql = "INSERT INTO info (name) VALUES (%s)"
	return database.execute_sql_query(sql, (name,))


def create_seed_meta_table():
	sql = (
		"CREATE TABLE IF NOT EXISTS app_meta ("
		"key TEXT PRIMARY KEY, "
		"value TEXT, "
		"created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()"
		")"
	)
	return database.execute_sql_query(sql)


def is_already_seeded() -> bool:
	sql = "SELECT value FROM app_meta WHERE key = %s"
	result = database.execute_sql_query(sql, (SEED_MARKER_KEY,))
	if result == "Connection Error":
		return False
	if isinstance(result, Exception):
		return False
	return bool(result)


def mark_seeded():
	sql = "INSERT INTO app_meta (key, value) VALUES (%s, %s) ON CONFLICT (key) DO NOTHING"
	return database.execute_sql_query(sql, (SEED_MARKER_KEY, "true"))


def seed():
	create_seed_meta_table()
	create_table()

	if is_already_seeded():
		print("Seed skipped (database already initialized).")
		return

	name = "David Maat2"
	result = insert_info(name)

	if result is True:
		mark_seeded()
		print("Seed succeeded.")
	else:
		print("Seed returned:", result)


if __name__ == "__main__":
	seed()

