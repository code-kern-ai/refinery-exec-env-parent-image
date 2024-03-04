FROM python:3.9-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

COPY submodules/parent-images/requirements/exec-env-requirements.txt .

RUN pip install --no-cache-dir -r exec-env-requirements.txt

# RUN python3 -m nltk.downloader all # all size of ~3.5 GB
# partial download only ~100 MB
RUN python3 -m nltk.downloader words stopwords wordnet omw-1.4 brown punkt