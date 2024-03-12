$win_tag = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
$appname="kafka_dockeree"
#$ce_memopt="-m 2GB"
$ce_memopt=""

$container = docker run ${ce_memopt} -d -p 9092:9092 --name ${appname}_server --hostname ${appname}_server ${appname}_server:${win_tag}

write-output @"
***
kafka running ${appname}_server:9092
run [docker stop $container] to shut down services
***
"@