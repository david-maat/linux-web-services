from fastapi import APIRouter
import socket
import database

router = APIRouter()

@router.get("/name")
def get_name():
  sql = "SELECT name FROM info"
  result = database.execute_sql_query(sql)

  if result and isinstance(result, list) and len(result) > 0:
    return {"name": result[0][0]}

  return {"name": "No name found"}


@router.get("/container_id")
def get_container_id():
    container_id = socket.gethostname()
    return {"container_id": container_id}