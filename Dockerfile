FROM alpine:latest AS builder
ENV OSSFS_VERSION v1.80.7
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories
RUN apk --update add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev build-base make libcurl openssl libstdc++ libgcc pkgconfig
RUN wget -qO- https://github.com/aliyun/ossfs/archive/$OSSFS_VERSION.tar.gz |tar xz
RUN cd ossfs-1.80.7 \
  && ./autogen.sh \
  && ./configure --prefix=/usr \
  && make \
  && make install

FROM postgres:15-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories
RUN apk --update add fuse curl libxml2 openssl libstdc++ libgcc mysql-client tzdata && rm -rf /var/cache/apk/* 
ENV OSSFS_VERSION v1.80.7
COPY --from=builder /usr/bin/ossfs /usr/bin/ossfs
COPY mount.sh .
ENV OSS_URL http://oss-cn-beijing-internal.aliyuncs.com
ENV OSS_BUCKET bucket-name
ENV OSSFS_OPTIONS -o noxattr
ENV MNT_POINT /data/ossfs
ENV ACCESS_KEY changeme
ENV ACCESS_SECRET changeme
CMD ["/bin/sh", "-c", "/mount.sh & sleep 10 && chmod +x /data/ossfs/run.sh && /data/ossfs/run.sh"]