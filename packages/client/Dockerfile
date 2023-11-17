# Client build
FROM node:20.9.0-alpine3.18 as client
RUN apk add yarn python3 g++ gcc make musl-dev ocaml --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN mkdir /client
WORKDIR /client
COPY src /client/src 
COPY static /client/static
COPY package.json /client/package.json
COPY bsconfig.json /client/bsconfig.json
RUN yarn install 
RUN yarn res:build

# Runtime
FROM nginx
COPY --from=client /client/static/* /usr/share/nginx/html/
COPY --from=client /client/src/*bs.js /usr/share/nginx/html/

