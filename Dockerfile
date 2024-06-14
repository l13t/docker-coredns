FROM golang:1.22 as builder

RUN git clone https://github.com/coredns/coredns /coredns

WORKDIR /coredns

RUN echo "alias:github.com/serverwentdown/alias" >> /coredns/plugin.cfg && \
    echo "redisc:github.com/miekg/redis" >> /coredns/plugin.cfg && \
    echo "ipin:github.com/wenerme/coredns-ipin" >> /coredns/plugin.cfg && \
    echo "ipecho:github.com/Eun/coredns-ipecho" >> /coredns/plugin.cfg && \
    echo "unbound:github.com/coredns/unbound" >> /coredns/plugin.cfg && \
    echo "nomad:github.com/ituoga/coredns-nomad" >> /coredns/plugin.cfg
RUN go generate coredns.go && \
    go get && \
    cat /coredns/plugin.cfg && \
    CGO_ENABLED=0 go build -o /coredns/coredns -ldflags "-s -w -extldflags '-static'" .
# RUN setcap cap_net_bind_service=+ep /coredns/coredns

FROM scratch

COPY --from=builder /coredns/coredns /coredns
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

USER nobody:nogroup

EXPOSE 53 53/udp
# ENTRYPOINT ["/coredns"]
CMD ["/coredns"]
