Сборка docker образа likecoin для akash
```
git clone -b 'fotan-1' https://github.com/likecoin/likecoin-chain.git
git clone https://github.com/bloqhub/akash-likecoin.git
cp ./akash-likecoin/Dockerfile ./likecoin-chain/
cp ./akash-likecoin/supervisord.conf ./likecoin-chain/
docker build -t bloqhub/liked-ssh:0.1 --build-arg password=sshpassword ./
```
sshpassword - пароль ssh для root аккаунта и размещаем образ на dockerhub   
помещаем собранный образ в docker hub
```
docker push bloqhub/althea-ssh:0.2.3
```
