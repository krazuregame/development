주요내용
Apache HTTPD 이미지를 이용한 Webserver Container 실행 및 재기동, 삭제 등

 

HTTPD 이미지 받아오기 - Docker Hub에서 검색
root@cosmos:~# docker pull httpd
Using default tag: latest
latest: Pulling from library/httpd
3059b4820522: Pull complete
ff978d850939: Pull complete
e5742b3bf835: Pull complete
0f2aa39f856d: Pull complete
7223fa861e2e: Pull complete
c4e49a059257: Pull complete
d57f74a7654e: Pull complete
7ab4b123e15c: Pull complete
d8238a7ed1a6: Pull complete
2ce64294b91b: Pull complete
83ae454d6066: Pull complete
1d4469a74fc9: Pull complete
cb604ab7d359: Pull complete
Digest: sha256:3eae43b977887f7f660c640ba8477dc1af1626d757ff1a7ddba050418429f2f6
Status: Downloaded newer image for httpd:latest
 

이미지 실행
root@cosmos:~# docker run -d --name httpd24 httpd
cede8845a9d6fe6c62c39b8001d2bf6b26b8c624180fa04ae9ac006c7a1a341c
 

컨테이너 확인
root@cosmos:~# docker ps
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS               NAMES
cede8845a9d6        httpd               "httpd-foreground"   4 seconds ago       Up 3 seconds        80/tcp              httpd24
컨테이너 정보조회 (IP, Port)
root@cosmos:~# docker inspect httpd24
[
{
    "Id": "cede8845a9d6fe6c62c39b8001d2bf6b26b8c624180fa04ae9ac006c7a1a341c",
    "Created": "2016-05-12T04:22:53.755144171Z",
    "Path": "httpd-foreground",
    "Args": [],
    "State": {
        "Status": "running",
        "Running": true,
...
        "ExposedPorts": {
            "80/tcp": {}
        },
...
        "SandboxKey": "/var/run/docker/netns/45f231857acf",
        "SecondaryIPAddresses": null,
        "SecondaryIPv6Addresses": null,
        "EndpointID": "0cbf1b312478543aa8b10deea3445cca4fafd597b5c7f36004d1f17b1ee2fff3",
        "Gateway": "172.17.0.1",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "IPAddress": "172.17.0.2",
        "IPPrefixLen": 16,
        "IPv6Gateway": "",
        "MacAddress": "02:42:ac:11:00:02",
        "Networks": {
            "bridge": {
                "EndpointID": "0cbf1b312478543aa8b10deea3445cca4fafd597b5c7f36004d1f17b1ee2fff3",
                "Gateway": "172.17.0.1",
                "IPAddress": "172.17.0.2",
                "IPPrefixLen": 16,
                "IPv6Gateway": "",
                "GlobalIPv6Address": "",
                "GlobalIPv6PrefixLen": 0,
                "MacAddress": "02:42:ac:11:00:02"
            }
        }
    }
}
]
 

어플리케이션 호출
root@cosmos:~# curl 172.17.0.2
<html><body><h1>It works!</h1></body></html>
 

컨테이너 접속 변경
cosmos ~ # docker exec -ti httpd24 /bin/bash
root@f38e2dbac897:/usr/local/apache2#
root@f38e2dbac897:/usr/local/apache2# ls htdocs/
index.html
root@f38e2dbac897:/usr/local/apache2# exit
exit
 

컨테이너 파일 복사
# Copy File from Container inside
cosmos ~ # docker cp httpd24:/usr/local/apache2/htdocs/index.html ./
cosmos ~ # cat index.html
<html><body><h1>It works!</h1></body></html>
  
cosmos ~ # echo '<html><body><h1>It works very nicely!</h1></body></html>' > index.html
cosmos ~ # cat index.html
<html><body><h1>It works very nicely!</h1></body></html>
  
# Copy Local File into Container
docker cp index.html httpd24:/usr/local/apache2/htdocs/index.html
 

 

컨테이너 정지 / 재기동
cosmos ~ # docker stop httpd24
httpd24
  
cosmos ~ # docker start httpd24
httpd24
  
cosmos ~ # curl 172.17.0.3
<html><body><h1>It works very nicely!</h1></body></html>
 

컨테이너 변경사항저장
cosmos ~ # docker images | grep httpd
httpd                                                    latest              d595a4011ae3        2 weeks ago         178 MB
 
  
cosmos ~ # docker commit httpd24 httpd:2.4-20180919
sha256:0457fece9ff2f560358efdc15c578efb1cc681d0c3c0f5d2064600a1ee40c3cf
  
cosmos ~ # docker images | grep httpd
httpd                                                    2.4-20180919     0457fece9ff2        5 seconds ago       178 MB
httpd                                                    latest              94af1f614752        2 months ago        178 MB
 

 

컨테이너 삭제
cosmos ~ # docker stop httpd24
httpd24
  
cosmos:~# docker rm httpd24
httpd24
 

이미지삭제
root@cosmos:~# docker rmi httpd:latest
...
Deleted: ff978d850939f8af21e7ff9c5a276a7dcc49cb588bc957bd6c307b372cb375c9
Deleted: 3059b48205226912642a74158165aa3d828760fe65ec01cf132f1553aae1c133
 

컨테이너 기동(OS Reboot 시 자동 실행)
cosmos ~ # docker run -d --restart unless-stopped --name httpd24 httpd:2.4.34-20180919
1f504e5656dcf87ad305e43421b0711e7ca0061872a6be0b771d28b55316dc21

