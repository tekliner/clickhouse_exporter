FROM golang:1.13-alpine

LABEL maintainer="Andrey Inishev"

RUN apk update
RUN apk add git mercurial

WORKDIR /app/clickhouse-exporter
COPY . .

RUN CGO_ENABLED=0 go build -mod=vendor

FROM alpine:3.10

COPY --from=0 /app/clickhouse-exporter/clickhouse-exporter /usr/local/bin/clickhouse-exporter

ENTRYPOINT ["/usr/local/bin/clickhouse-exporter"]

CMD ["-scrape_uri=http://localhost:8123"]

EXPOSE 9116
