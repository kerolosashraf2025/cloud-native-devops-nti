import os
import time
import json
from pymongo import MongoClient
from redis import Redis

MONGODB_URI = os.getenv("MONGODB_URI")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

DB_NAME = os.getenv("DB_NAME", "nti-db")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "votes")

if not MONGODB_URI:
    raise Exception("MONGODB_URI is not set")

print("Connecting to MongoDB...")
mongo_client = MongoClient(MONGODB_URI)
db = mongo_client[DB_NAME]
collection = db[COLLECTION_NAME]

print("Connecting to Redis...")
redis_client = Redis(host=REDIS_HOST, port=REDIS_PORT, db=0, socket_timeout=5)

print("Mongo Writer started successfully ✅")

while True:
    try:
        item = redis_client.blpop("votes", timeout=5)

        if item:
            _, data = item
            vote_data = json.loads(data.decode("utf-8"))

            vote_data["source"] = "voting-app"
            vote_data["createdAt"] = time.time()

            collection.insert_one(vote_data)
            print(f"Inserted vote: {vote_data}")

    except Exception as e:
        print(f"Error: {str(e)}")
        time.sleep(5)
