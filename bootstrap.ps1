Write-Output "bootstrapping java/zookeeper/kafka"

Write-Output "zookeeper_home = ${env:zookeeper_home}"

Write-Output "starting zookeeper"
Start-Process -NoNewWindow -Filepath "$env:zookeeper_home/bin/zkserver.cmd"
Write-Output "starting kafka"
Start-Process -Filepath "$env:kafka_home/bin/windows\kafka-server-start.bat" -ArgumentList "$env:kafka_home/config/server.properties" -NoNewWindow -Wait