ARG os=jammy-20230816
FROM ubuntu:${os}

RUN apt-get update && apt-get install -y \
        g++ \
        git \
        make \
        wget \
        ruby ruby-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://apt.puppet.com/puppet7-release-jammy.deb && dpkg -i puppet7-release-jammy.deb \
    && apt-get update && apt-get install -y \
        puppet-agent \
    && rm -rf /var/lib/apt/lists/*

RUN export PATH="/opt/puppetlabs/bin:$PATH" \
    && puppet module install aursu/openssh
