from fastapi import FastAPI
import api
import seeder

app = FastAPI()

# Run database seeding on startup
@app.on_event("startup")
async def startup_event():
    seeder.seed()

# Mount API routes without a trailing slash to satisfy FastAPI assertion.
app.include_router(router=api.router, prefix="")

@app.get("/health")
def health_check():
    return {"status": "healthy"}