FROM golang:1.27

RUN go install github.com/brancz/gojsontoyaml@c6b07b0d03d2ac3e9a26acbaff526ee9b49dda5d && \
    go install github.com/google/go-jsonnet/cmd/jsonnet@567b61ac4a6c23546a62d79324bb4aaed6bdc941 && \
    go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@ddded59c7066658f3d5abc7fcfc6be2220c92cad

RUN apt-get update \
  && apt-get install -y jq python3
