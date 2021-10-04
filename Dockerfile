FROM centos:8

MAINTAINER Anand.Bisen@SAS.COM

RUN dnf install -y dnf-plugins-core
RUN dnf group install -y "Development Tools"
RUN dnf install -y \
                   bzip2-devel           \
                   clang                 \
                   gdbm-devel            \
                   libtirpc-devel        \
                   libuuid-devel         \
                   libffi-devel          \
                   libnsl                \
                   ncurses-devel         \
                   openssl-devel         \
                   readline-devel        \
                   sqlite-devel          \
                   tix                   \
                   tk-devel              \
                   wget                  \
                   xz-devel              


RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.3-linux-x86_64.tar.gz -P /tmp &&\
    tar -xvf /tmp/julia-1.6.3-linux-x86_64.tar.gz -C /opt &&\
    rm -f /tmp/julia-1.6.3-linux-x86_64.tar.gz &&\
    ln -sf /opt/julia-1.6.3/bin/julia /usr/local/bin/julia

RUN julia -e 'using Pkg; Pkg.add(["ArgParse", "Downloads"]);'

COPY build-python.jl /usr/local/bin

ENTRYPOINT ["/bin/bash"]
