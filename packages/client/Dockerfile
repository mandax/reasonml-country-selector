# Install dependencies
FROM node:20.9.0-alpine3.18 as cache
RUN apk add yarn python3 g++ gcc make musl-dev ocaml --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN mkdir /build
WORKDIR /build
COPY package.json /build/package.json
COPY bsconfig.json /build/bsconfig.json
RUN yarn install 

# Build
FROM cache as build 
WORKDIR /build
COPY src /build/src
RUN yarn res:build

# Runtime
FROM node:20.9.0-alpine3.18 as server
RUN mkdir /server
RUN npm install -g http-server
COPY static/* /server
COPY --from=build /build/lib/es6/src/* /server
EXPOSE 80
CMD ["http-server", "-c-1", "-p80", "/server"]
