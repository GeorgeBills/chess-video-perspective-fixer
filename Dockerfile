FROM alpine:3.13

RUN apk add --no-cache \
    bash \
    ffmpeg \
    fdk-aac

COPY ffmpeg.sh .

ENTRYPOINT [ "./ffmpeg.sh" ]
