all: clean generate

generate:
	cfssl genkey -initca root_ca/root_ca_csr.json | cfssljson -bare root_ca
	cfssl genkey -initca int1_ca/int1_ca_csr.json | cfssljson -bare int1_ca
	cfssl sign -ca root_ca.pem -ca-key root_ca-key.pem -config signing_conf.json -profile intermediate int1_ca.csr | cfssljson -bare int1_ca
	cfssl genkey -initca int2_ca/int2_ca_csr.json | cfssljson -bare int2_ca
	cfssl sign -ca int1_ca.pem -ca-key int1_ca-key.pem -config signing_conf.json -profile last_intermediate int2_ca.csr | cfssljson -bare int2_ca

clean:
	@rm -f ${PWD}/*.csr ${PWD}/*.pem


