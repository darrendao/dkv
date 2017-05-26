killall ruby2.3
cd /app/dkv
REDIS_HOST='redis.vpc.internal' /usr/local/bin/puma -p 4567 -d
