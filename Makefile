all: clean generate_rsa

generate_ec:
	cfssl genkey -initca csr/root_ca_ecdsa_csr.json | cfssljson -bare certs/root_ca_ecdsa
	cfssl genkey -initca csr/int1_ca_ecdsa_csr.json | cfssljson -bare certs/int1_ca_ecdsa
	cfssl sign -ca certs/root_ca_ecdsa.pem -ca-key certs/root_ca_ecdsa-key.pem -config signing_conf.json -profile intermediate certs/int1_ca_ecdsa.csr | cfssljson -bare certs/int1_ca_ecdsa
	cfssl genkey -initca csr/int2_ca_ecdsa_csr.json | cfssljson -bare certs/int2_ca_ecdsa
	cfssl sign -ca certs/int1_ca_ecdsa.pem -ca-key certs/int1_ca_ecdsa-key.pem -config signing_conf.json -profile last_intermediate certs/int2_ca_ecdsa.csr | cfssljson -bare certs/int2_ca_ecdsa
	cfssl gencert -ca certs/int2_ca_ecdsa.pem -ca-key certs/int2_ca_ecdsa-key.pem -config signing_conf.json -profile server csr/server_ecdsa_csr.json | cfssljson -bare certs/server_ec
	cfssl gencert -ca certs/int2_ca_ecdsa.pem -ca-key certs/int2_ca_ecdsa-key.pem -config signing_conf.json -profile client csr/client_ecdsa_csr.json | cfssljson -bare certs/client_ec
	openssl pkcs8 -in certs/server_ec-key.pem -topk8 -nocrypt -out certs/server_ec-key.pk8
	openssl pkcs8 -in certs/client_ec-key.pem -topk8 -nocrypt -out certs/client_ec-key.pk8

generate_rsa:
	cfssl genkey -initca csr/root_ca_rsa_csr.json | cfssljson -bare certs/root_ca_rsa
	cfssl genkey -initca csr/int1_ca_rsa_csr.json | cfssljson -bare certs/int1_ca_rsa
	cfssl sign -ca certs/root_ca_rsa.pem -ca-key certs/root_ca_rsa-key.pem -config signing_conf.json -profile intermediate certs/int1_ca_rsa.csr | cfssljson -bare certs/int1_ca_rsa
	cfssl genkey -initca csr/int2_ca_rsa_csr.json | cfssljson -bare certs/int2_ca_rsa
	cfssl sign -ca certs/int1_ca_rsa.pem -ca-key certs/int1_ca_rsa-key.pem -config signing_conf.json -profile last_intermediate certs/int2_ca_rsa.csr | cfssljson -bare certs/int2_ca_rsa
	cfssl gencert -ca certs/int2_ca_rsa.pem -ca-key certs/int2_ca_rsa-key.pem -config signing_conf.json -profile server csr/server_rsa_csr.json | cfssljson -bare certs/server_rsa
	cfssl gencert -ca certs/int2_ca_rsa.pem -ca-key certs/int2_ca_rsa-key.pem -config signing_conf.json -profile client csr/client_rsa_csr.json | cfssljson -bare certs/client_rsa
	openssl pkcs8 -in certs/server_rsa-key.pem -topk8 -nocrypt -out certs/server_rsa-key.pk8
	openssl pkcs8 -in certs/client_rsa-key.pem -topk8 -nocrypt -out certs/client_rsa-key.pk8

clean:
	@rm -f ${PWD}/certs/*.csr ${PWD}/certs/*.pem ${PWD}/certs/*.pk8


