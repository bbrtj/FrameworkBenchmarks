# Setup

* Perl 5.40+
* MariaDB

# Requirements

* Thunderhorse (install from CPAN)
* DBI + DBD::mysql (install from CPAN)
* nginx (if you want to front with nginx, nginx.conf provided)
* Various speed-improving modules from CPAN are optional but included

# Deployment

## pagi-server

    pagi-server -E production --port 8080 --max-workers=25 -a app.pl

# Expert contact

@bbrtj (bbrtj.pro@gmail.com)

