all: clean generate_rsa

generate_ec:
	cfssl genkey -initca csr/root_ca_ecdsa_csr.json | cfssljson -bare root_ca_ecdsa
	cfssl genkey -initca csr/int1_ca_ecdsa_csr.json | cfssljson -bare int1_ca_ecdsa
	cfssl sign -ca root_ca_ecdsa.pem -ca-key root_ca_ecdsa-key.pem -config signing_conf.json -profile intermediate int1_ca_ecdsa.csr | cfssljson -bare int1_ca_ecdsa
	cfssl genkey -initca csr/int2_ca_ecdsa_csr.json | cfssljson -bare int2_ca_ecdsa
	cfssl sign -ca int1_ca_ecdsa.pem -ca-key int1_ca_ecdsa-key.pem -config signing_conf.json -profile last_intermediate int2_ca_ecdsa.csr | cfssljson -bare int2_ca_ecdsa
	cfssl gencert -ca int2_ca_ecdsa.pem -ca-key int2_ca_ecdsa-key.pem -config signing_conf.json -profile server csr/server_ecdsa_csr.json | cfssljson -bare server
	cfssl gencert -ca int2_ca_ecdsa.pem -ca-key int2_ca_ecdsa-key.pem -config signing_conf.json -profile client csr/client_ecdsa_csr.json | cfssljson -bare client

generate_rsa:
	cfssl genkey -initca csr/root_ca_rsa_csr.json | cfssljson -bare root_ca_rsa
	cfssl genkey -initca csr/int1_ca_rsa_csr.json | cfssljson -bare int1_ca_rsa
	cfssl sign -ca root_ca_rsa.pem -ca-key root_ca_rsa-key.pem -config signing_conf.json -profile intermediate int1_ca_rsa.csr | cfssljson -bare int1_ca_rsa
	cfssl genkey -initca csr/int2_ca_rsa_csr.json | cfssljson -bare int2_ca_rsa
	cfssl sign -ca int1_ca_rsa.pem -ca-key int1_ca_rsa-key.pem -config signing_conf.json -profile last_intermediate int2_ca_rsa.csr | cfssljson -bare int2_ca_rsa
	cfssl gencert -ca int2_ca_rsa.pem -ca-key int2_ca_rsa-key.pem -config signing_conf.json -profile server csr/server_rsa_csr.json | cfssljson -bare server
	cfssl gencert -ca int2_ca_rsa.pem -ca-key int2_ca_rsa-key.pem -config signing_conf.json -profile client csr/client_rsa_csr.json | cfssljson -bare client

clean:
	@rm -f ${PWD}/*.csr ${PWD}/*.pem


