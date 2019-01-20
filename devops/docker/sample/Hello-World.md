# SSH 접속

[user1@ip-10-0-0-151 ~]$
 

# Image검색 (https://hub.docker.com/)
[user1@ip-10-0-0-151 ~]$ sudo docker search hello-world
NAME                                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
hello-world                               Hello World! (an example of minimal Docker...   206       [OK]
...
 

# Image 받기
[user1@ip-10-0-0-151 ~]$ sudo docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
c04b14da8d14: Pull complete
Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
Status: Downloaded newer image for hello-world:latest
[user1@ip-10-0-0-151 ~]$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB
 

# Conatainer 실행
hello-world 컨테이너는 실행하면 아래와 같은 메세지를 출력하고 바로 종료된다.

[user1@ip-10-0-0-151 ~]$ sudo docker run --name=user1-hello-world hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash
Share images, automate workflows, and more with a free Docker Hub account:
 https://hub.docker.com
For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
 

# Conatainer 재실행
## 생성된 컨테이너 확인
[user1@ip-10-0-0-151 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
a87e2c6f67d4        hello-world         "/hello"            9 seconds ago       Exited (0) 7 seconds ago                        user1-hello-world
 
 
## 컨테이너 재실행 (ID 또는 Name 이용)
[user1@ip-10-0-0-151 ~]$ sudo docker start a87e2c6f67d4
a87e2c6f67d4
  
## 로그확인
[user1@ip-10-0-0-151 ~]$ sudo docker logs a87e2c6f67d4


# Conatainer 삭제
## 생성된 컨테이너 확인
[user1@ip-10-0-0-151 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                          PORTS               NAMES
a87e2c6f67d4        hello-world         "/hello"            3 minutes ago       Exited (0) About a minute ago                       user1-hello-world
 
## 컨테이너 삭제 (ID 또는 Name으로 삭제)
[user1@ip-10-0-0-151 ~]$ sudo docker rm user1-hello-world
user1-hello-world
Image삭제
[user1@ip-10-0-0-151 ~]$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              c54a2cc56cbb        4 months ago        1.848 kB
  
## image는 해당 이미지로 생성된 컨테이너가 모두 삭제되야 지울 수 있다.
[user1@ip-10-0-0-151 ~]$ sudo docker rmi hello-world
Untagged: hello-world:latest
Deleted: sha256:c54a2cc56cbb2f04003c1cd4507e118af7c0d340fe7e2720f70976c4b75237dc
Deleted: sha256:a02596fdd012f22b03af6ad7d11fa590c57507558357b079c3e8cebceb4262d7

