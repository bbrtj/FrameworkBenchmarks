FROM perl:5.40

ARG TFB_TEST_NAME
ARG TFB_TEST_DATABASE

RUN apt-get update -yqq && apt-get install -yqq nginx

WORKDIR /thunderhorse

RUN cpanm --notest --no-man-page \
	Thunderhorse@0.100 \
	DBI@1.647 \
	DBD::MariaDB@1.24 \
	Cpanel::JSON::XS@4.38 \
	MooX::TypeTiny@0.002003 \
	MooX::XSConstructor@0.003000 \
	Class::XSAccessor@1.19 \
	Type::Tiny::XS@0.025

ADD ./ /thunderhorse/

ENV TEST_NAME=$TFB_TEST_NAME
ENV DATABASE=$TFB_TEST_DATABASE
ENV MAX_REQS=100000
ENV SOCKET_FILE=/tmp/perl-thunderhorse.sock
ENV PROXY_PORT=8181

EXPOSE 8080

CMD nginx -c /thunderhorse/nginx.conf && ./run.pl

