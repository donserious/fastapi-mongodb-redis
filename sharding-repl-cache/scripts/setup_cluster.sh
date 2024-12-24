#!/bin/bash

sleep 5

# Инициализация репликаций для shard1
docker compose exec -T shard1 mongosh --port 27018 --quiet << EOF
  rs.initiate({_id: "rs1", members: [
     {_id: 0, host: "shard1:27018"},
     {_id: 1, host: "shard1r1:37017"},
     {_id: 2, host: "shard1r2:37018"},
     {_id: 3, host: "shard1r3:37019"}
  ]}) 
EOF


# Инициализация репликаций для shard2
docker compose exec -T shard2 mongosh --port 27019 --quiet << EOF
  rs.initiate({_id: "rs2", members: [
     {_id: 0, host: "shard2:27019"},
     {_id: 1, host: "shard2r1:37117"},
     {_id: 2, host: "shard2r2:37118"},
     {_id: 3, host: "shard2r3:37119"}
  ]})
EOF

# Инициализация репликационного набора для shard1
#docker compose exec -T shard1 mongosh --port 27018 --quiet << EOF
#  rs.initiate({
#    _id: 'rs1',
#    members: [
#      { _id: 0, host: 'shard1:27018' }
#      // { _id: 1, host: 'shard2:27019' }
#    ]
#  });
#EOF

# Инициализация репликационного набора для shard2
#docker compose exec -T shard2 mongosh --port 27019 --quiet << EOF
#  rs.initiate({
#    _id: 'rs2',
#    members: [
#      // { _id: 0, host: 'shard1:27018' }
#      { _id: 1, host: 'shard2:27019' }
#    ]
#  });
#EOF

sleep 6
echo 'start init config server...'
# Выполнение команды инициализации репликации в контейнере configSrv
docker compose exec -T configSrv mongosh --port 27017 --quiet << EOF
  rs.initiate({
    _id: 'config_server',
    configsvr: true,
    members: [
      { _id: 0, host: 'configSrv:27017' }
    ]
  });
EOF

sleep 6
echo 'start setup shards...'
# Выполнение команд для настройки шардирования
docker compose exec -T mongos-router mongosh --port 27020 --quiet << EOF
  sh.addShard('rs1/shard1:27018')
  sh.addShard('rs2/shard2:27019')
  sh.enableSharding('somedb')
  sh.shardCollection('somedb.helloDoc', { 'name': 'hashed' })
EOF

sleep 2

# Инициализация данных
echo 'сгенерировано данных:'
docker compose exec -T mongos-router mongosh --port 27020 --quiet << EOF
  use somedb
  for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
  db.helloDoc.countDocuments()
EOF

sleep 2

echo 'в первом шарде:'
# Выполнение команды для подсчета документов
docker compose exec -T shard1 mongosh --port 27018 --quiet << EOF
  use somedb
  db.helloDoc.countDocuments()
EOF

sleep 2

echo 'во втором шарде:'
# Выполнение команды для подсчета документов
docker compose exec -T shard2 mongosh --port 27019 --quiet << EOF
  use somedb
  db.helloDoc.countDocuments()
EOF

echo 'Setup finished.'
