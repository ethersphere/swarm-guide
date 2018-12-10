FROM python:3.7.1

RUN pip install \
    Sphinx==1.8.2 \
    sphinx-rtd-theme==0.4.2

RUN mkdir -p /src
WORKDIR /src

