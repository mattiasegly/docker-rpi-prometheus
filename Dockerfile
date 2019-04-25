#Using stretch because of curl SSL error on buster
FROM balenalib/rpi:stretch AS builder
RUN [ "cross-build-start" ]

ARG OS=linux
ARG ARCH=armv6
ARG RELEASE=2.9.1

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	tar \
&& rm -rf /var/lib/apt/lists/*

RUN curl -LJ https://github.com/prometheus/prometheus/releases/download/v$RELEASE/prometheus-$RELEASE.$OS-$ARCH.tar.gz -o prometheus.tar.gz && \
	mkdir /extract && \
	tar -xzf prometheus.tar.gz -C /extract --strip-components=1

RUN [ "cross-build-end" ]

FROM balenalib/rpi:buster
RUN [ "cross-build-start" ]

COPY --from=builder /extract /prometheus

RUN [ "cross-build-end" ]

VOLUME /prometheus/data
EXPOSE 9090

#ENTRYPOINT ["entrypoint.sh"]
CMD ["/prometheus/prometheus", "--config.file=/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/data"]
