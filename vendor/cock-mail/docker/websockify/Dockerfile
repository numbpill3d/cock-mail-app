FROM local.local/alpine:mini

RUN apk update
RUN apk add websockify patch
RUN apk cache purge

COPY *.patch /patch/

RUN cd /usr/lib/python3.*/site-packages/websockify && \
    patch -p2 < /patch/00-add-haproxy.patch && \
    patch -p2 < /patch/01-add-ssl-target-name.patch && \
    rm -rf __pycache__ && \
    python3 -m compileall -f -q . && \
    rm -rf /patch

USER nobody

CMD ["websockify", "--help"]
