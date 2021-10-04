# build-python

This repository automates the process of building a self contained
Python install against CentOS/RHEL 8 environment.

## Usage

* Build the Docker container with all necessary dependencies required
for compiling Python from source

```bash
$ docker build . -t build-python`
```

* Launch the container in interactive mode with the target directory
for the build mounted from the host

```bash
$ docker run --rm -it \
        -v <local-dir>:/python \
        -v `pwd`:/workspace \
        build-python /bin/bash
```

* Build python

```bash
$ build-python.jl -v 3.9.4 \
                  -d /python \
                  -r /workspace/requirements.txt
```
