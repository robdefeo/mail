PKGS := github.com/mailchain/mail
SRCDIRS := $(shell go list -f '{{.Dir}}' $(PKGS))
GO := go

check: build test vet gofmt misspell unconvert ineffassign unparam

build:
	go build ./...
test: 
	$(GO) test $(PKGS)

vet: | test
	$(GO) vet $(PKGS)

misspell:
	$(GO) get github.com/client9/misspell/cmd/misspell
	misspell \
		-locale US \
		-error \
		*.md *.go

unconvert:
	$(GO) get github.com/mdempsky/unconvert
	unconvert -v $(PKGS)

ineffassign:
	$(GO) get github.com/gordonklaus/ineffassign
	find $(SRCDIRS) -name '*.go' | xargs ineffassign

pedantic: check errcheck

unparam:
	$(GO) get mvdan.cc/unparam
	unparam ./...

errcheck:
	$(GO) get github.com/kisielk/errcheck
	errcheck $(PKGS)

gofmt:  
	@echo Checking code is gofmted
	@test -z "$(shell gofmt -s -l -d -e $(SRCDIRS) | tee /dev/stderr)"

license:
	$(GO) get github.com/google/addlicense
	addlicense -l mit -c Finobo .

proto:
	rm -f ./*.pb.go
	protoc ./data.proto -I. --go_out=:.