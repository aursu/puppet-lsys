ARG centos=stream9-20230605.0
FROM aursu/centos:${centos}-systemd

RUN microdnf -y install \
        diffutils \
        dnf \
        tar \
        vim \
    && microdnf clean all && rm -rf /var/cache/dnf /var/lib/rpm/__db*

RUN rpm -Uvh https://yum.puppet.com/puppet7-release-el-9.noarch.rpm \
    && dnf -y install puppet-agent \
    && dnf clean all && rm -rf /var/cache/dnf /var/lib/rpm/__db*

RUN export PATH="/opt/puppetlabs/bin:$PATH" \
    && puppet module install aursu/openssh \
    && /opt/puppetlabs/puppet/bin/gem install --no-document yard \
    && /opt/puppetlabs/puppet/bin/gem install --no-document puppet-strings
