ARG win_tag=1809

# Use a Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore:$win_tag

    # Download the JDK
RUN powershell -Command "Invoke-WebRequest -Uri 'https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe' -OutFile '\jdk-21_windows-x64_bin.exe'"

# Install the JDK silently
ENV JAVA_HOME="C:\Program Files\Java\jdk-21"
RUN powershell -Command "Start-Process -FilePath '\jdk-21_windows-x64_bin.exe' -ArgumentList '/s' -Wait"

# Remove the installer to save space
RUN powershell -Command "Remove-Item -Path '\jdk-21_windows-x64_bin.exe'"

# Download 7-zip
RUN powershell -Command "Invoke-WebRequest -Uri 'https://7-zip.org/a/7z2301-x64.exe' -OutFile '\7z2301-x64.exe'"

# Install 7-zip silently
RUN powershell start-process -filepath \7z2301-x64.exe -passthru -wait -argumentlist "/S"

# Remove the installer to save space
RUN powershell -Command "Remove-Item -Path '\7z2301-x64.exe'"

# Copy the PowerShell script
COPY SetPathVariable.ps1 /

# Run the PowerShell script
RUN powershell -ExecutionPolicy Bypass /SetPathVariable.ps1 -NewLocation 'C:\Program Files\7-Zip'

ENV ZK_VERSION=3.8.4
ENV ZOOKEEPER_HOME=c:\\zookeeper
RUN powershell (new-object System.Net.WebClient).Downloadfile('https://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/stable/apache-zookeeper-%ZK_VERSION%-bin.tar.gz', '\zookeeper-%ZK_VERSION%.tar.gz')
RUN 7z.exe e zookeeper-%ZK_VERSION%.tar.gz 
RUN 7z.exe x zookeeper-%ZK_VERSION%.tar -y
RUN DEL \zookeeper-%ZK_VERSION%.tar.gz 
RUN DEL \zookeeper-%ZK_VERSION%.tar
RUN REN \apache-zookeeper-%ZK_VERSION%-bin zookeeper
RUN powershell -executionpolicy bypass /SetPathVariable.ps1 -NewLocation '%ZOOKEEPER_HOME%/bin'

ENV K_SBT_VER=3.7.0
ENV K_VER=2.13
ENV K_NAME=kafka_${K_VER}-${K_SBT_VER}
ENV KAFKA_HOME=c:\\kafka

RUN powershell (new-object System.Net.WebClient).Downloadfile('https://mirrors.ukfast.co.uk/sites/ftp.apache.org/kafka/%K_SBT_VER%/%K_NAME%.tgz', '\%K_NAME%.tgz')

RUN 7z.exe e %K_NAME%.tgz
RUN 7z.exe x %K_NAME%.tar 
RUN REN %K_NAME% kafka
RUN DEL \%K_NAME%.tgz
RUN DEL \%K_NAME%.tar

COPY conf/zookeeper/zoo.cfg c:/zookeeper/conf/

COPY conf/kafka/server.properties ${KAFKA_HOME}/config/
RUN powershell "((Get-Content -path %KAFKA_HOME%/config/server.properties -Raw) -replace '--k_name--','%K_NAME%') | Set-Content -Path %KAFKA_HOME%/config/server.properties"

COPY bootstrap.ps1 /

EXPOSE 9092

ENTRYPOINT [ "powershell", \
"-executionpolicy" , \
"bypass", \
 "/bootstrap.ps1" ]