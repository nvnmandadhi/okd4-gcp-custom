FROM cgr.dev/chainguard/google-cloud-sdk:latest

USER root

ENV PLATFORM=amd64 \
    TOFU_VERSION=1.6.1 \
    OKD_VERSION=4.15.0-0.okd-2024-02-23-163410 \
    TOFU_DOWNLOAD_URL=https://github.com/opentofu/opentofu/releases/download \
    GCLOUD_SDK_PATH=/usr/share/google-cloud-sdk \
    OKD_RELEASES_URL=https://github.com/okd-project/okd/releases/download

RUN apk update && \
    apk add curl git wget make

RUN curl -LO ${TOFU_DOWNLOAD_URL}/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_${PLATFORM}.apk && \
    apk add --allow-untrusted tofu_${TOFU_VERSION}_${PLATFORM}.apk && \
    wget -qO - ${OKD_RELEASES_URL}/${OKD_VERSION}/openshift-install-linux-${OKD_VERSION}.tar.gz \
      | tar -xvzf - -C /usr/bin && \
    chmod +x -R /usr/bin