FROM debian:bullseye-slim

EXPOSE 53

RUN apt update
RUN apt install -y dnsmasq

RUN sed -i -e "s/\#domain-needed/domain-needed/" /etc/dnsmasq.conf
RUN sed -i -e "s/\#bogus-priv/bogus-priv/" /etc/dnsmasq.conf
RUN sed -i -e "s/\#local=.*/local=\/home\//" /etc/dnsmasq.conf
# Use another hosts file because modification to /etc/hosts in Dockerfile are not reflected.
RUN sed -i -e "s/\#addn-hosts=.*/addn-hosts=\/etc\/dnsmasq_hosts/" /etc/dnsmasq.conf

COPY ./files/hosts /etc/dnsmasq_hosts

ENTRYPOINT ["dnsmasq", "--keep-in-foreground"]
