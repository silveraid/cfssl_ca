SHELL         := bash
CONFIG        := $(PWD)/config.sh
CFSSL	      := bin/cfssl
JSON	      := bin/cfssljson
CFSSL_URL     := $(shell curl -s https://api.github.com/repos/cloudflare/cfssl/releases/latest | jq -r '.assets[].browser_download_url | select(contains("/cfssl_")) | select(endswith("linux_amd64"))')
CFSSLJSON_URL := $(shell curl -s https://api.github.com/repos/cloudflare/cfssl/releases/latest | jq -r '.assets[].browser_download_url | select(contains("/cfssljson_")) | select(endswith("linux_amd64"))')

all: clean cfssl ca client server

certs: client server

cfssl:
	rm -f $(CFSSL) $(JSON)
	curl -L -o $(CFSSL) $(CFSSL_URL) && chmod 755 $(CFSSL)
	curl -L -o $(JSON) $(CFSSLJSON_URL) && chmod 755 $(JSON)

root_ca:
	mkdir -p certs
	$(CFSSL) gencert -initca config/ca_root-config.json | $(JSON) -bare certs/ca_root

int_ca:
	$(CFSSL) gencert -initca config/ca_int-config.json | $(JSON) -bare certs/ca_int
	$(CFSSL) sign \
		-ca certs/ca_root.pem \
		-ca-key certs/ca_root-key.pem \
		-config config/signing-profiles.json \
		-profile intermediate \
		certs/ca_int.csr | $(JSON) -bare certs/ca_int
	cat certs/ca_int.pem certs/ca_root.pem > certs/bundle_ca.pem

ca: root_ca int_ca

client:
	source $(CONFIG); \
	for i in "$${!CLIENTS[@]}"; do \
		echo "GENERATING CLIENTS: $${i}"; \
		sed "s/PLACEHOLDER/$${i}/" config/csr-generic.json | \
		$(CFSSL) gencert \
			-ca certs/ca_int.pem \
			-ca-key certs/ca_int-key.pem \
			-config config/signing-profiles.json \
			-profile client \
			-hostname "$${CLIENTS[$$i]}" \
			- \
			| $(JSON) -bare certs/client_$${i}; \
		cat certs/client_$${i}.pem certs/ca_int.pem > certs/client_$${i}-chain.pem; \
		openssl pkcs8 \
			-in certs/client_$${i}-key.pem \
			-topk8 \
			-nocrypt \
			-out certs/client_$${i}-key.pk8.pem; \
	done

client-signedbyroot:
	source $(CONFIG); \
	for i in "$${!CLIENTS[@]}"; do \
		echo "GENERATING CLIENTS: $${i}"; \
		sed "s/PLACEHOLDER/$${i}/" config/csr-generic.json | \
		$(CFSSL) gencert \
			-ca certs/ca_root.pem \
			-ca-key certs/ca_root-key.pem \
			-config config/signing-profiles.json \
			-profile client \
			-hostname "$${CLIENTS[$$i]}" \
			- \
			| $(JSON) -bare certs/client_$${i}; \
		cat certs/client_$${i}.pem certs/ca_root.pem > certs/client_$${i}-chain.pem; \
		openssl pkcs8 \
			-in certs/client_$${i}-key.pem \
			-topk8 \
			-nocrypt \
			-out certs/client_$${i}-key.pk8.pem; \
		done

server:
	source $(CONFIG); \
	for i in "$${!SERVERS[@]}"; do \
		echo "GENERATING SERVER: $${i}"; \
		sed "s/PLACEHOLDER/$${i}/" config/csr-generic.json | \
		$(CFSSL) gencert \
			-ca certs/ca_int.pem \
			-ca-key certs/ca_int-key.pem \
			-config config/signing-profiles.json \
			-profile server \
			-hostname "$${SERVERS[$$i]}" \
			- \
			| $(JSON) -bare certs/server_$${i}; \
		cat certs/server_$${i}.pem certs/ca_int.pem > certs/server_$${i}-chain.pem; \
		openssl pkcs8 \
			-in certs/server_$${i}-key.pem \
			-topk8 \
			-nocrypt \
			-out certs/server_$${i}-key.pk8.pem; \
	done


server-signedbyroot:
	source $(CONFIG); \
	for i in "$${!SERVERS[@]}"; do \
		echo "GENERATING SERVER: $${i}"; \
		sed "s/PLACEHOLDER/$${i}/" config/csr-generic.json | \
		$(CFSSL) gencert \
			-ca certs/ca_root.pem \
			-ca-key certs/ca_root-key.pem \
			-config config/signing-profiles.json \
			-profile server \
			-hostname "$${SERVERS[$$i]}" \
			- \
			| $(JSON) -bare certs/server_$${i}; \
		cat certs/server_$${i}.pem certs/ca_root.pem > certs/server_$${i}-chain.pem; \
		openssl pkcs8 \
			-in certs/server_$${i}-key.pem \
			-topk8 \
			-nocrypt \
			-out certs/server_$${i}-key.pk8.pem; \
	done

clean:
	rm -f ${PWD}/certs/*.csr ${PWD}/certs/*.pem ${PWD}/certs/*.pk8
