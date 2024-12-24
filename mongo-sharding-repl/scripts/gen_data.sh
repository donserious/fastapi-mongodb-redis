#!/bin/bash

# Инициализация данных
echo "Инициализация данных..."
docker compose exec -T mongos_router mongosh --port 27020 --quiet << EOF
  use somedb
  for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
  db.helloDoc.countDocuments()
EOF

echo "Генерация данных завершена."


echo "Подсчет документов в shard1..."

# Выполнение команды для подсчета документов
docker compose exec -T shard1 mongosh --port 27018 --quiet << EOF
  use somedb
  db.helloDoc.countDocuments()
EOF

echo "Подсчет завершен."
