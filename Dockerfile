FROM robertdebock/fedora:rawhide
MAINTAINER Ookiineko <chiisaineko@protonmail.com>
ENV container docker
ENV LC_ALL C
ENV LANG C.UTF-8
SHELL ["/bin/bash", "-c"]
ADD cfg /tmp/fch_i/0
ADD scripts /tmp/fch_i/1
COPY preinst /tmp/fch_i/2
COPY postinst /tmp/fch_i/3
COPY proxies /tmp/fch_i/4
RUN source /tmp/fch_i/4 && \
    bash /tmp/fch_i/2 && \
    echo 'Updating DNF cache' && \
    dnf makecache && \
    echo 'Installing ca-certiticates and DNF plugins' && \
    dnf install -y ca-certificates dnf-plugins-core && \
    echo 'Adding Cygwin repo' && \
    dnf copr enable -y yselkowitz/cygwin && \
    echo 'Doing system upgrade' && \
    dnf upgrade -y && \
    echo 'Installing build dpes' && \
    dnf group install -y "C Development Tools and Libraries" && \
    echo 'Installing packages' && \
    dnf install -y ncurses python3-pip python2.7 netcat curl unzip rsync gnupg2 psmisc procps-ng wget zip nano tmux ncdu p7zip unrar neofetch \
                   tar cpio gzip htop iputils bash-completion net-tools passwd less mandoc man-pages file bind-utils tmate openssh-server git-core \
                   openssh-clients ninja-build openssl-devel pkgconf-pkg-config libcurl-devel libssh2-devel xz-devel zlib-devel libffi-devel cmake \
                   libzstd-devel libxml2-devel chrpath python3-setuptools cygwin64 cygwin64-binutils cygwin64-cpp cygwin64-default-manifest hostname \
                   cygwin64-filesystem cygwin64-gcc cygwin64-gcc-c++ cygwin64-gettext cygwin64-gettext-static cygwin64-libbfd cygwin64-libiconv \
                   cygwin64-libiconv-static cygwin64-libltdl cygwin64-libtool cygwin64-ncurses cygwin64-pkg-config cygwin64-w32api-headers cygport \
                   cygwin64-w32api-runtime cygwin64-zlib cygwin64-zlib-static && \
    echo 'Post install' && \
    sed -i -re 's/^account\s+required\s+pam_nologin\.so//g' /etc/pam.d/login && \
    useradd -m -s /bin/bash -u 1000 fedora && \
    usermod -aG wheel fedora && \
    chown fedora:fedora -R /tmp/fch_i && \
    su fedora -pc 'bash /tmp/fch_i/0/inst' && \
    su fedora -pc 'bash /tmp/fch_i/1/inst' && \
    ln -s /mnt/workspace /workspace && \
    ln -s /mnt/workspace /home/fedora/Workspace && \
    dnf clean all && \
    bash /tmp/fch_i/3 && \
    rm -rf /tmp/* /var/tmp/* && \
    echo 'Done!'

STOPSIGNAL SIGRTMIN+3
