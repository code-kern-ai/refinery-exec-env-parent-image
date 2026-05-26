ARG DHI_PYTHON_BUILD=dhi.io/python:3.11.11-debian12-dev
ARG DHI_PYTHON_RUNTIME=dhi.io/python:3.11.11-debian12

FROM ${DHI_PYTHON_BUILD} AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV VENV_PATH=/opt/venv
ENV PATH="${VENV_PATH}/bin:${PATH}"
ENV NLTK_DATA=/opt/nltk_data

RUN python -m venv "${VENV_PATH}"

RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

COPY submodules/parent-images/requirements/exec-env-requirements.txt .

RUN pip install --no-cache-dir -r exec-env-requirements.txt

RUN mkdir -p "${NLTK_DATA}" && \
    NLTK_DATA="${NLTK_DATA}" python -m nltk.downloader -d "${NLTK_DATA}" \
    words stopwords wordnet omw-1.4 brown punkt

FROM ${DHI_PYTHON_RUNTIME}

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV VENV_PATH=/opt/venv
ENV PATH="${VENV_PATH}/bin:${PATH}"
ENV NLTK_DATA=/opt/nltk_data

COPY --from=builder --chown=65532:65532 ${VENV_PATH} ${VENV_PATH}
COPY --from=builder --chown=65532:65532 /opt/nltk_data /opt/nltk_data

USER 65532:65532
