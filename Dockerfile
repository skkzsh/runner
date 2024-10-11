ARG UBUNTU_VER=${UBUNTU_VER:-22.04}
ARG RUNNER_VER=${RUNNER_VER:-2.314.1}
ARG GH_OWNER=${GH_OWNER:-skkzsh}
ARG GH_REPO=${GH_REPO:-runner}

FROM ubuntu:${UBUNTU_VER}

WORKDIR /opt/actions-runner

RUN apt-get update && apt-get install -y curl \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

RUN --mount=type=secret,id=gh_bearer_token \
    curl -L -H "Authorization: Bearer $(cat /run/secrets/gh_bearer_token)" \
    https://github.com/_services/pipelines/_apis/distributedtask/packagedownload/agent/linux-x64/${RUNNER_VER} \
    | tar zxf -

RUN ./bin/installdependencies.sh

RUN useradd -m runner && chown runner:runner .
USER runner

# TODO: secret (needs sudo)
ARG RUNNER_TOKEN
# RUN --mount=type=secret,id=runner_token \
RUN ./config.sh --url https://github.com/${GH_OWNER}/${GH_REPO} --token ${RUNNER_TOKEN}

ENTRYPOINT ./run.sh

