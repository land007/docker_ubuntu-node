FROM land007/ubuntu-build:latest

MAINTAINER Yiqiu Jia <yiqiujia@hotmail.com>

RUN apt-get update && apt-get install -y python ffmpeg && apt-get clean && \
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ENV NVM_DIR=/root/.nvm \
#	SHIPPABLE_NODE_VERSION=v8.11.1
#	SHIPPABLE_NODE_VERSION=v8.14.0
#	SHIPPABLE_NODE_VERSION=v9.11.1
	SHIPPABLE_NODE_VERSION=v9.11.2
#	SHIPPABLE_NODE_VERSION=v10.13.0
#	SHIPPABLE_NODE_VERSION=v10.14.1
RUN . $HOME/.nvm/nvm.sh && nvm install $SHIPPABLE_NODE_VERSION && nvm alias default $SHIPPABLE_NODE_VERSION && nvm use default && cd / && npm init -y && npm install -g node-gyp supervisor http-server && npm install socket.io ws express http-proxy bagpipe eventproxy pty.js chokidar request nodemailer await-signal log4js moment && \
#RUN . $HOME/.nvm/nvm.sh && nvm install $SHIPPABLE_NODE_VERSION && nvm alias default $SHIPPABLE_NODE_VERSION && nvm use default && npm install gulp babel  jasmine mocha serial-jasmine serial-mocha aws-test-worker -g && \
#	. $HOME/.nvm/nvm.sh && cd / && npm install pty.js && \
	. $HOME/.nvm/nvm.sh && which node
#RUN ln -s /root/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/bin/node /usr/bin/node
#RUN ln -s /root/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/bin/supervisor /usr/bin/supervisor
ENV PATH $PATH:/root/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/bin

ADD check.sh /
RUN sed -i 's/\r$//' /check.sh && chmod a+x /check.sh
# Define working directory.
#RUN mkdir /node
ADD node /node
RUN ln -s $HOME/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/lib/node_modules /node && \
	sed -i 's/\r$//' /node/start.sh && chmod a+x /node/start.sh && \
	ln -s /node ~/ && ln -s /node /home/land007 && \
	mv /node /node_
WORKDIR /node
VOLUME ["/node"]

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/ubuntu-node" >> /.image_names && \
	echo "land007/ubuntu-node" > /.image_name

EXPOSE 80/tcp
#CMD /check.sh /node ; /etc/init.d/ssh start ; /node/start.sh
RUN echo "/check.sh /node" >> /start.sh && \
#RUN echo "supervisor -w /node/ /node/server.js" >> /start.sh && \
	echo "/usr/bin/nohup supervisor -w /node/ /node/server.js > /node/node.out 2>&1 &" >> /start.sh

#docker stop ubuntu-node ; docker rm ubuntu-node ; docker run -it --privileged -v ~/docker/ubuntu-node:/node -p 80:80 --name ubuntu-node land007/ubuntu-node:latest
