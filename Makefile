VERSION=$(shell git describe --tags)
TARGET_DIR=./BUILD/

.PHONY: all

all: build_deps
	cd webgui; npm install
	cd webadmin; npm install
	cd webgui; cp production.env .env
	cd webadmin; cp production.env .env
	fpm --input-type dir \
		--output-type deb \
		--force \
		--vendor uw-ictd \
		--config-files /etc/colte/config.yml \
		--config-files /usr/bin/colte-webgui/.env \
		--config-files /usr/bin/colte-webadmin/.env \
		--after-install ./package/postinst \
		--after-remove ./package/postrm \
		--maintainer sevilla@cs.washington.edu \
		--description "The Community LTE Project" \
		--url "https://github.com/uw-ictd/colte" \
		--name colte \
		--version $(VERSION) \
		--package $(TARGET_DIR) \
		--depends 'open5gs, haulage, python3, nodejs (>= 8.0.0), default-mysql-client, default-mysql-server, python3-netaddr, python3-ruamel.yaml, python3-mysqldb' \
		./package/sample_db.sql=/etc/colte/sample_db.sql \
		./package/haulage.yml=/etc/colte/haulage.yml \
		./conf/coltenat.sh=/usr/bin/coltenat \
		./package/colte-nat.service=/etc/systemd/system/colte-nat.service \
		./conf/colteconf.py=/usr/bin/colteconf \
		./conf/coltedb.py=/usr/bin/coltedb \
		./conf/open5gs_dbconf.sh=/etc/colte/colte_open5gsdb \
		./conf/config.yml=/etc/colte/config.yml \
		./webgui/=/usr/bin/colte-webgui \
		./package/colte-webgui.service=/etc/systemd/system/colte-webgui.service \
		./package/colte-webadmin.service=/etc/systemd/system/colte-webadmin.service \
		./package/webgui.env=/etc/colte/webgui.env \
		./package/pricing.json=/etc/colte/pricing.json \
		./package/transactions_log.txt=/var/log/colte/transactions_log.txt \
		./webadmin/=/usr/bin/colte-webadmin \
		./package/webadmin.env=/etc/colte/webadmin.env

build_deps:
	sudo apt-get install ruby ruby-dev rubygems build-essential default-mysql-client default-mysql-server npm nodejs
	sudo gem install --no-ri --no-rdoc fpm
	mkdir -p $(TARGET_DIR)
