FROM ubuntu:20.04
MAINTAINER Luis Munoz <lfmunoz4@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
  \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
  openssh-server \
  ca-certificates \
  apt-transport-https \
  curl \
  zip \
  unzip \
  wget \
  tree \
  gnupg-agent \
  software-properties-common \
  gnupg2 \
  sshpass \
  lsb-release \
  sudo \
  git \
  vim \
  build-essential \
  ; \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
  apt-key fingerprint 0EBFCD88; \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"; \
  apt-get update; \
  apt-get install --yes --no-install-recommends docker-ce docker-ce-cli containerd.io; \
  rm -rf /var/lib/apt/lists/*; \
  \
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash; \
  /bin/bash -c "source $HOME/.nvm/nvm.sh; nvm install --lts"; \
  curl -s "https://get.sdkman.io" | bash; \
  bash -c "source $HOME/.sdkman/bin/sdkman-init.sh; sdk install java 8.0.275-amzn"; \
  \
  echo 'export NVM_DIR="/root/.nvm"'  >> /etc/bash.bashrc; \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/bash.bashrc; \
  echo '' >> /etc/bash.bashrc; \
  echo 'export SDKMAN_DIR="/root/.sdkman"' >> /etc/bash.bashrc; \
  echo '[[ -s "/root/.sdkman/bin/sdkman-init.sh" ]] && source "/root/.sdkman/bin/sdkman-init.sh"' >> /etc/bash.bashrc; \
  echo 'nvm use stable' >> /etc/profile.d/nvm.sh; \
  \
  echo '#!/bin/bash'  >> /bin/bertha; \
  echo '' >> /bin/bertha; \
  echo 'export NVM_DIR="/root/.nvm"'  >> /bin/bertha; \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'   >> /bin/bertha; \
  echo '' >> /bin/bertha; \
  echo 'export SDKMAN_DIR="/root/.sdkman"'  >> /bin/bertha; \
  echo '[[ -s "/root/.sdkman/bin/sdkman-init.sh" ]] && source "/root/.sdkman/bin/sdkman-init.sh"' >> /bin/bertha; \
  echo 'nvm use stable' >> /bin/bertha; \
  echo '$*' >> /bin/bertha; \
  chmod 755 /bin/bertha; \
  \
  sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config; \
  echo "root:root" | chpasswd; \
  mkdir -p /var/run/sshd; \
  rm -rf /var/cache/apk/*; \
  sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config; \
  sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config; \
  sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config; \
  sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config; \
  sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config; \
  sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config; \
  /usr/bin/ssh-keygen -A; \
  ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key; 


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

