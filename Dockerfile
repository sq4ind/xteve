# xTeVe build
FROM golang:alpine AS xteve-build

RUN apk add curl

WORKDIR /tmp/xteve
RUN curl -fsSL https://github.com/xteve-project/xTeVe/archive/2.2.0.200.tar.gz | tar -xz --strip-components=1 && \
    go get github.com/koron/go-ssdp github.com/gorilla/websocket github.com/kardianos/osext && \
    mkdir /opt/xteve && \
    go build -o /opt/xteve xteve.go

WORKDIR /build
RUN mkdir -p /build/etc/opt/xteve/backup /build/tmp/xteve && \
    cp --archive --parents --no-dereference /opt/xteve /build && \
    rm -rf /tmp/* /var/cache/apk/*

WORKDIR /build
RUN mkdir -p /build/etc/opt/xteve/backup /build/tmp/xteve && \
    cp --archive --parents --no-dereference /opt/xteve /build && \
    rm -rf /tmp/* /var/cache/apk/*


# final image
FROM alpine:3.18
LABEL maintainer="<sq4ind@gmail.com>"

# xTeVe
COPY --from=xteve-build /build /

RUN set -eux && \
	apk add --no-cache --update-cache \
		ffmpeg \
		tzdata \
		vlc \
        libva-intel-driver  \
        && \
	rm -rf /var/cache/apk/*

WORKDIR /opt/xteve

EXPOSE 34400
VOLUME ["/etc/opt/xteve", "/tmp/xteve"]
ENTRYPOINT ["/opt/xteve/xteve"]
CMD ["-config", "/etc/opt/xteve", "-port", "34400"]
