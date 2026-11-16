FROM golang:1.27

RUN go install github.com/grafana/tanka/cmd/tk@5f013dd40ac287ab6d6977442af63ddae1d02198 && \
    go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@ddded59c7066658f3d5abc7fcfc6be2220c92cad

RUN apt-get update \
  && apt-get install -y jq python3
