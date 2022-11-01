build/ngspice.wasm:
	docker build -t ngspice-wasm .
	docker run -t -v $(realpath .):/mnt ngspice-wasm /mnt/build.sh
