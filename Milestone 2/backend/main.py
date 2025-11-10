from fastapi import FastAPI
import api

app = FastAPI()

app.include_router(router=api.router, prefix="/api")

@app.get("/health")
def health_check():
    return {"status": "healthy"}