import redis
import json
import os

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=6379,
    decode_responses=True
)

def get_cached_categories():
    cached = redis_client.get("categories")
    if cached:
        return json.loads(cached)
    return None

def set_cached_categories(categories: list, ttl_seconds: int = 300):
    redis_client.set("categories", json.dumps(categories), ex=ttl_seconds)

def invalidate_categories_cache():
    redis_client.delete("categories")