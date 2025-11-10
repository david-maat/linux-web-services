import socket
import database


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


def seed():
	create_table()

	name = "David Maat"

	result = insert_info(name)

	if result is True:
		print("Seed succeeded.")
	else:
		print("Seed returned:", result)


if __name__ == "__main__":
	seed()

