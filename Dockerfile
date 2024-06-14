FROM golang:1.22 as builder

RUN git clone https://github.com/coredns/coredns /coredns

WORKDIR /coredns

RUN echo "alias:github.com/serverwentdown/alias" >> /coredns/plugins.cfg && \
    echo "redisc:github.com/miekg/redis" >> /coredns/plugins.cfg && \
    echo "ipin:github.com/wenerme/coredns-ipin" >> /coredns/plugins.cfg && \
    echo "ipecho:github.com/Eun/coredns-ipecho" >> /coredns/plugins.cfg && \
    echo "unbound:github.com/coredns/unbound" >> /coredns/plugins.cfg && \
    echo "nomad:github.com/ituoga/coredns-nomad" >> /coredns/plugins.cfg
RUN go generate && \
    go build -o /coredns/coredns
# RUN setcap cap_net_bind_service=+ep /coredns/coredns

FROM scratch

COPY --from=builder /coredns/coredns /coredns
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

USER nobody:nogroup

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
