#!/bin/bash

###
# Настройка шардирования и инициализация базы данных
###

# Ожидание запуска mongos_router
echo "Ожидание запуска mongos_router..."
#sleep 10  # Увеличьте время ожидания, если необходимо

# Выполнение команд для настройки шардирования
echo "Настройка шардирования..."
docker exec -it mongos-router mongosh --port 27020 --eval "
  sh.addShard('shard1/shard1:27018');
  sh.addShard('shard2/shard2:27019');
  sh.enableSharding('somedb');
  sh.shardCollection('somedb.helloDoc', { 'name': 'hashed' });
"

echo "Ok"
