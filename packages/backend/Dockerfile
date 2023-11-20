# Install dependencies
FROM ocaml/opam:ubuntu-lts-ocaml-5.1 as cache
RUN mkdir $HOME/build
RUN sudo apt install -y libev-dev
WORKDIR $HOME/build
COPY ./dune-project $HOME/build/dune-project
COPY ./bin $HOME/build/bin
COPY ./test $HOME/build/test
RUN opam install $HOME/build/. --deps-only -y -v
# NOTE: for some reason opam is not installing dependencies correctly, 
#       for the sake of getting this running, let's install manually
RUN opam install dune -y
RUN opam install opium -y
RUN eval $(opam env)

# Build
FROM cache as build 
WORKDIR /home/opam/build
RUN opam exec -- dune build
RUN opam exec -- dune install

# Runtime
FROM build as server
RUN mkdir $HOME/server
WORKDIR /server
COPY ./countries.json $HOME/server/countries.json
EXPOSE 4000
CMD ["backend", "-p", "4000"]
