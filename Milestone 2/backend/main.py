from fastapi import FastAPI
import api

app = FastAPI()

# Mount API routes without a trailing slash to satisfy FastAPI assertion.
app.include_router(router=api.router, prefix="")

@app.get("/health")
def health_check():
    return {"status": "healthy"}