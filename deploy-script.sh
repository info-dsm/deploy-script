sudo yum install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

echo "docker installed"

sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo systemctl restart docker

echo "docker-compose installed"

cat << EOF > tmp.sh
#spring config
export SPRING_CONFIG_IMPORT=optional:configserver:http://infov2-config-server:8888/

#aws config
export AWS_SECRET_ACCESS_KEY=${{AWS_ACCESS_KEY}}
export AWS_ACCESS_KEY_ID=${{AWS_SECRET_KEY}}

# email settings
export SMTP_HOST=${{SMTP_HOST}}
export LOG_RECEIVER_EMAIL_USERNAME=${{LOG_RECEIVER_EMAIL_USERNAME}}
export LOG_SENDER_EMAIL_USERNAME=${{LOG_SENDER_EMAIL_USERNAME}}
export LOG_SENDER_EMAIL_PASSWORD=${{LOG_SENDER_EMAIL_PASSWORD}}


# log path settings
export LOG_APPLIES_PATH=${{LOG_APPLIES_PATH}}
export LOG_AUTH_PATH=${{LOG_AUTH_PATH}}
export LOG_COMPANY_PATH=${{LOG_COMPANY_PATH}}
export LOG_EMAIL_PATH=${{LOG_EMAIL_PATH}}
export LOG_EMPLOYMENT_PATH=${{LOG_EMPLOYMENT_PATH}}
export LOG_EUREKA_PATH=${{LOG_EUREKA_PATH}}
export LOG_FILE_PATH=${{LOG_FILE_PATH}}
export LOG_NOTICE_PATH=${{LOG_NOTICE_PATH}}
export LOG_STATISTICS_PATH=${{LOG_STATISTICS_PATH}}
export LOG_USER_PATH=${{LOG_USER_PATH}}
export LOG_API_GATEWAY_PATH=${{LOG_API_GATEWAY}}
EOF

cat tmp.sh >> ~/.bashrc

rm tmp.sh
source ~/.bashrc

echo "environment variable setup complete"

mkdir info
cd info
mkdir data 
mkdir proxy
mkdir logs
mkdir -p tmp/company
mkdir tmp/file
mkdir -p data/prometheus/config
mkdir -p data/prometheus/data
mkdir data/grafana
mkdir proxy/data
mkdir proxy/ssl
mkdir proxy/ssl/certs
mkdir proxy/ssl/private

echo "dir setup complete"

cat << EOF > proxy/ssl/private/key.pem
${{INFODSM_SSL_PRIVATE_KEY}}
EOF

cat << EOF > proxy/ssl/certs/cloudflare.crt
${{INFODSM_SSL_CERTS_CLOUDFLARE_CRT}}
EOF


cat << EOF > proxy/nginx.conf
user  root;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}

http {

    default_type  application/json;

    upstream api-server {
	server infov2-apigateway:8000;
    }


    server {
        listen 443 ssl;
	listen [::]:443 ssl;

	ssl_certificate         /etc/ssl/certs/cert.pem;
    	ssl_certificate_key     /etc/ssl/private/key.pem;

	#	ssl_verify_client 	on;
	#ssl_client_certificate 	/etc/ssl/certs/cloudflare.crt;

    	server_name 		info-dsm.info api.info-dsm.info;


        location / {
            proxy_pass  	http://api-server;
        }
    }

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;
    include /etc/nginx/conf.d/*.conf;
}
EOF


cat << EOF > proxy/ssl/certs/cert.pem
-----BEGIN CERTIFICATE-----
${{INFODSM_SSL_CERTS_CERT_PEM}}
EOF



cat << EOF > docker-compose.yml
version: '3'

services:
  redis:
    image: docker.io/redis:alpine3.17
    command: redis-server --port 6379
    restart: always
    ports:
      - "6379:6379"
    networks:
      - info
      - grafana
    container_name: redis
  infov2-config-server:
    image: docker.io/jinwoo794533/infov2-config-server:latest
    ports:
      - "8888:8888"
    container_name: "infov2-config-server"
    networks:
      - info
  infov2-apiGateway:
    image: docker.io/jinwoo794533/infov2-apigateway:latest
    ports:
      - "8000:8000"
    container_name: infov2-apigateway
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_API_GATEWAY_PATH}
    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-applies:
    image: docker.io/jinwoo794533/infov2-applies:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_APPLIES_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-auth:
    image: docker.io/jinwoo794533/infov2-auth:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_AUTH_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
      - redis
  infov2-company:
    image: docker.io/jinwoo794533/infov2-company:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_COMPANY_PATH}

    user: root
    volumes:
      - ./logs/:/var/run/spring/info/
      - ./tmp/company:/tmp/spring/company
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-email:
    image: docker.io/jinwoo794533/infov2-email:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_EMAIL_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-employment:
    image: docker.io/jinwoo794533/infov2-employment:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_EMPLOYMENT_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-eureka:
    image: docker.io/jinwoo794533/infov2-eureka:0.00.02
    container_name: info-eureka
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_EUREKA_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    ports:
      - "8761:8761"
    networks:
      - info
    depends_on:
      - infov2-config-server
      - kafka
  infov2-file:
    image: docker.io/jinwoo794533/infov2-file:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      AWS_ACCESS_KEY_ID: ${{AWS_ACCESS_KEY}}
      AWS_SECRET_ACCESS_KEY: ${{AWS_SECRET_KEY}}
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_FILE_PATH}

    user: root
    volumes:
      - ./logs/:/var/run/spring/info/
      - ./tmp/file:/tmp/spring/file
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-notice:
    image: docker.io/jinwoo794533/infov2-notice:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_NOTICE_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server
  infov2-user:
    image: docker.io/jinwoo794533/infov2-user:latest
    environment:
      SPRING_CONFIG_IMPORT: optional:configserver:http://infov2-config-server:8888/
      SMTP_HOST: ${SMTP_HOST}
      LOG_RECEIVER_EMAIL_USERNAME: ${LOG_RECEIVER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_USERNAME: ${LOG_SENDER_EMAIL_USERNAME}
      LOG_SENDER_EMAIL_PASSWORD: ${LOG_SENDER_EMAIL_PASSWORD}
      LOG_PATH: ${LOG_USER_PATH}

    volumes:
      - ./logs/:/var/run/spring/info/
    networks:
      - info
    depends_on:
      - infov2-eureka
      - infov2-config-server


  zookeeper:
    image: docker.io/bitnami/zookeeper:3.7.1
    hostname: zookeeper
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
    networks:
      - kafka

  kafka:
    image: docker.io/bitnami/kafka:3.4.0
    ports:
      - '9092:9092'
    container_name: info-kafka
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT
      - KAFKA_CFG_LISTENERS=CLIENT://:9333,EXTERNAL://:9092
      - KAFKA_CFG_ADVERTISED_LISTENERS=CLIENT://info-kafka:9333,EXTERNAL://info-kafka:9092
      - KAFKA_CFG_INTER_BROKER_LISTENER_NAME=CLIENT
    depends_on:
      - zookeeper
    networks:
      - info
      - kafka

  nginx:
    image: docker.io/nginx:1.22.1
    ports:
      - '443:443'
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf
      - ./proxy/data:/var/log/nginx/
      - ./proxy/ssl:/etc/ssl/
    networks:
      - info
    container_name: nginx
    depends_on:
      - infov2-apiGateway




networks:
  info:
    driver: bridge
  kafka:
    driver: bridge
  grafana:
    driver: bridge
EOF


echo "file setup complete"

docker-compose up -d

