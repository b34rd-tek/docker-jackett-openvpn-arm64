# Jackett and OpenVPN, JackettVPN

FROM alpine:3.15.3

LABEL org.opencontainers.image.authors="b34rd_tek <el_barbado@b34rd.tech>" \
      org.opencontainers.image.documentation="https://github.com/${PACKAGE}/README.md" \
      org.opencontainers.image.description="${DESCRIPTION}" \
      org.opencontainers.image.licenses="GPLv3" \
      org.opencontainers.image.source="https://github.com/${PACKAGE}" \
      org.opencontainers.image.url="https://hub.docker.com/r/${PACKAGE}/"

ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

#  install required packages
RUN apk update && apk add wget\
 bash\
 curl\
 gnupg\
 sed\
 openvpn\
 moreutils\
 net-tools\
 dos2unix\
 kmod\
 iptables\
 ipcalc\
 grep\
 libunwind\
 icu-dev\
 lttng-ust\
 krb5-libs\
 zlib\
 tzdata

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

# Install Jackett
RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxAMDx64.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && tar -xvzf /opt/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxAMDx64.tar.gz 
    
VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
