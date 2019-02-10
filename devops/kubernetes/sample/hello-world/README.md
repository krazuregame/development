# Hello World NodeJS Sample Applicaiton Demo

## 1. Create the Hello World NodeJS Server Application
vi server.js
```
var http = require('http');
var handleRequest = function(request, response) {
    response.writeHead(200);
    response.end("Hello Docker - cosmos !");
}
var www = http.createServer(handleRequest);
www.listen(8080);
```

## 2. Run the Hello World Application in local host
```
node server.js
```

## 3. Create the Docker File
vi Dockerfile
```
FROM node:4.4
EXPOSE 8080
COPY server.js
CMD node server.js
```

## 4. Docker Build
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ docker build -t cosmossandbox.azurecr.io/hello-node:v1 .
Sending build context to Docker daemon  3.584kB
Step 1/4 : FROM node:4.4
4.4: Pulling from library/node
357ea8c3d80b: Pull complete
52befadefd24: Pull complete
3c0732d5313c: Pull complete
ceb711c7e301: Pull complete
868b1d0e2aad: Pull complete
3a438db159a5: Pull complete
Digest: sha256:e720e944ce6994a461cd2a9e0ae34c4bc45c0f9ee7b3f48052933182fc5f0bf1
Status: Downloaded newer image ```for node:4.4
 ---> 93b396996a16
Step 2/4 : EXPOSE 8080
 ---> Running in 1da81230e3a0
Removing intermediate container 1da81230e3a0
 ---> 09524bbf68b6
Step 3/4 : COPY server.js .
 ---> fa007ca7f1e1
Step 4/4 : CMD node server.js
 ---> Running in 3c9d1ea51c37
Removing intermediate container 3c9d1ea51c37
 ---> 8722bd99f7bd
Successfully built 8722bd99f7bd
Successfully tagged cosmossandbox.azurecr.io/hello-node:v1
```

## 5. Docker Run
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ docker run -d -p 8080:8080 cosmossandbox.azurecr.io/hello-node:v1
867cc40498eb3654a8c6e2e4c691add335b18f12debb8bec1620bc54619dfe64
```

## 6. Docker Ststus Check
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ docker ps
CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                    NAMES
867cc40498eb        cosmossandbox.azurecr.io/hello-node:v1   "/bin/sh -c 'node se…"   58 seconds ago      Up 58 seconds       0.0.0.0:8080->8080/tcp   cocky_stallman
```

## 7. Docker Process Kill
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ docker kill 867cc40498eb
867cc40498eb
```

## 8. Docker Push in Container Registry
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ docker push cosmossandbox.azurecr.io/hello-node:v1
The push refers to repository [cosmossandbox.azurecr.io/hello-node]
2ed35c7a47c8: Pushed
20a6f9d228c0: Pushed
80c332ac5101: Pushed
04dc8c446a38: Pushed
1050aff7cfff: Pushed
66d8e5ee400c: Pushed
2f71b45e4e25: Pushed
v1: digest: sha256:751136a6ce8b154ac76dd4d99d38c24b80499d8269cfb8d46c0d405c6673d82c size: 1794
```

## 9. Run hello node in Kubernetes Cluster
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl run hello-node --image cosmossandbox.azurecr.io/hello-node:v1 --port 8080
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/hello-node created
```

## 10. Check Pod Status
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6c94d4ffb5-jsh8c   1/1     Running   0          88s
```

## 11. Connect the load balancer
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl expose deployment hello-node --type="LoadBalancer"
service/hello-node exposed
```

## 12. Check Service Status
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl get services
NAME         TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)          AGE
hello-node   LoadBalancer   10.0.79.50   40.115.162.102   8080:30161/TCP   101s
```

## 13. Set Replica Setting (Scale Out)
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl scale deployment hello-node --replicas=3
deployment.extensions/hello-node scaled
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6c94d4ffb5-2j6mq   1/1     Running   0          61s
hello-node-6c94d4ffb5-jsh8c   1/1     Running   0          18m
hello-node-6c94d4ffb5-n2t28   1/1     Running   0          61s
```

## 14. Delete Deployment, Pods
```
cosmos@cosmosDev:~/work/git/development/devops/kubernetes/sample/hello-world$ kubectl delete deployment hello-node
deployment.extensions "hello-node" deleted
```
