#!/bin/bash

# Ожидание, пока контейнеры MongoDB запустятся
sleep 10

# Инициализация репликационного набора для shard1
docker exec -it shard1 mongosh --port 27018 --eval "
  rs.initiate({
    _id: 'shard1',
    members: [
      { _id: 0, host: 'shard1:27018' }
      // { _id: 1, host: 'shard2:27019' }
    ]
  });
"

# Инициализация репликационного набора для shard2
docker exec -it shard2 mongosh --port 27019 --eval "
  rs.initiate({
    _id: 'shard2',
    members: [
      // { _id: 0, host: 'shard1:27018' }
      { _id: 1, host: 'shard2:27019' }
    ]
  });
"

# Вывод сообщения о завершении инициализации
echo "Репликационные наборы shard1 и shard2 инициализированы."
