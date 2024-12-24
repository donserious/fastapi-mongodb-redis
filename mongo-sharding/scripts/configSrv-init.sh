#!/bin/bash

# Ожидание, пока контейнер MongoDB запустится
sleep 10

# Выполнение команды инициализации репликации в контейнере configSrv
docker exec -it configSrv mongosh --port 27017 --eval "
  rs.initiate({
    _id: 'config_server',
    configsvr: true,
    members: [
      { _id: 0, host: 'configSrv:27017' }
    ]
  });
"

# Выход из mongo shell
echo "Репликация инициализирована."
