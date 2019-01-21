# Sample Java Application - Hello World


## Main.java(Hello world Application)
```
cosmos@cosmosdev2:~/work/java$ cat Main.java
public class Main
{
    public static void main(String[] args) {
        System.out.println("Hello, World~~~!!!!");
    }
}
```

### Local Build 
```
cosmos@cosmosdev2:~/work/java$ javac Main.java
cosmos@cosmosdev2:~/work/java$ java Main
Hello, World~~~!!!!
```

### Docker Build by CMD 
```
cosmos@cosmosdev2:~/work/java$ docker run --rm -v $PWD:/app -w /app java:8 javac Main.java
cosmos@cosmosdev2:~/work/java$ docker run --rm -v $PWD:/app -w /app java:8 java Main
Hello, World~~~!!!!
```

### Docker Build by Dockerfile

#### Make Dockerfile
```
cosmos@cosmosdev2:~/work/java$ cat Dockerfile
FROM java:8
COPY . /var/www/java
WORKDIR /var/www/java
RUN javac Main.java
CMD ["java", "Main"]
```
#### Docker Build from Docker file
```
cosmos@cosmosdev2:~/work/java$ docker build -t java-app .
Sending build context to Docker daemon  4.096kB
Step 1/5 : FROM java:8
 ---> d23bdf5b1b1b
Step 2/5 : COPY . /var/www/java
 ---> 5142ae10536e
Step 3/5 : WORKDIR /var/www/java
 ---> Running in 2deb6eb8f411
Removing intermediate container 2deb6eb8f411
 ---> cda371b03105
Step 4/5 : RUN javac Main.java
 ---> Running in 773249c3e4bb
Removing intermediate container 773249c3e4bb
 ---> 44241204f444
Step 5/5 : CMD ["java", "Main"]
 ---> Running in ce245f537241
Removing intermediate container ce245f537241
 ---> 46a5502e729a
Successfully built 46a5502e729a
Successfully tagged java-app:latest
```
#### Docker Run from local image
```
cosmos@cosmosdev2:~/work/java$ docker run java-app
Hello, World~~~!!!!
```

