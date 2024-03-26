## Comando obrigatório
## Baixa a imagem do node com versão alpine (versão mais simplificada e leve)
FROM node:18

ENV NODE_ENV=production
#ENV NODE_ENV=prod
#Diretório biblioteca Oracle
ENV LD_LIBRARY_PATH=/usr/local/instantclient_19_22

## Define o local onde o app vai ficar no disco do container
## Pode ser o diretório que você quiser
WORKDIR /usr/app/MaisLaudos

## Copia tudo que começa com package e termina com .json para dentro da pasta WORKDIR
COPY package*.json ./

# Copiar o Oracle Instant Client do host para a imagem
COPY ./instantclient-basic-linux.x64-19.22.0.0.0dbru.zip /tmp/
#COPY ./instantclient-sdk-linux.x64-19.22.0.0.0dbru.zip /tmp/
# Extrair arquivos do instant client
RUN unzip /tmp/instantclient-basic-linux.x64-19.22.0.0.0dbru.zip -d /usr/local/
#RUN unzip /tmp/instantclient-sdk-linux.x64-19.22.0.0.0dbru.zip -d /usr/local/

#APENAS TESTE
#RUN cp /usr/app/MaisLaudos/test/L/'testeregistromodificado.pdf' /usr/local/L/

# Atualize os pacotes e instale o pacote libaio
RUN apt-get update
RUN apt-get install -y libaio1
RUN apt install -y openssh-server
RUN apt-get install nano
RUN apt-get install -y iputils-ping

#Comando para permitir comandos do Git sem ssl
RUN git config --global http.sslVerify false

#Diretórios necessário para o projeto, re-criar pastas vazias necessários para estrutura do sistema
#Docker não copia pastas vazias.
RUN mkdir /usr/local/X/
RUN mkdir /usr/local/L/
RUN mkdir -p src/models/docs
RUN mkdir -p src/models/img
RUN mkdir -p src/models/js/tmp
RUN mkdir -p src/logs

#Configurações lib Oracle Client
#Excluir arquivos temporarios da imagem
RUN rm -rf /tmp/*.zip

#Definir library no ldconfig
RUN ln -s /usr/local/instantclient_19_22 /usr/local/instantclient
RUN echo /usr/local/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf
RUN ldconfig

## Executa npm install para adicionar as dependências e criar a pasta node_modules
RUN npm install --production

## Copia tudo que está no diretório onde o arquivo Dockerfile está
## para dentro da pasta WORKDIR do container
## Vamos ignorar a node_modules por isso criaremos um .dockerignore
COPY . .
#Ou Clonar pasta do projeto
#RUN git clone /usr/app/https://ronni.novello:06129192Rf@gitserver.santacasadepiracicaba.com.br/ronni.novello/MaisLaudos.git

## Container ficará ouvindo os acessos na porta 3000
#EXPOSE 3000

## Não se repete no Dockerfile
## Executa o comando npm start para iniciar o script que que está no package.json
CMD [ "node", "./src/server.js" ]