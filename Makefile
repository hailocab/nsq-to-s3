PROJECT = github.com/goller/nsq-to-s3

IMAGE = nsq-to-s3
EXECUTABLE = nsq-to-s3

REMOTE_REPO = goller/nsq-to-s3
LDFLAGS = "-X $(PROJECT)/nsq-to-s3.Build $(REV) -s"
TEST_COMMAND = godep go test
REV ?= $(shell git rev-parse --short=8 HEAD)
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD | tr / _)

.PHONY: dep-save dep-restore test test-verbose test-integration cover cover-integration vet lint build build-docker install clean publish

all: test

help:
	@echo "Available targets:"
	@echo ""
	@echo "  dep-save"
	@echo "  dep-restore"
	@echo "  test"
	@echo "  test-verbose"
	@echo "  test-integration"
	@echo "  cover"
	@echo "  cover-integration"
	@echo "  vet"
	@echo "  lint"
	@echo "  build"
	@echo "  build-docker"
	@echo "  publish"
	@echo "  install"
	@echo "  install-dev-tools"
	@echo "  clean"

dep-save:
	godep save ./...

dep-restore:
	godep restore

test:
	$(TEST_COMMAND) ./...

test-verbose:
	$(TEST_COMMAND) -test.v ./...

test-integration:
	$(TEST_COMMAND) ./... -tags integration

cover:
	bin/coverage.sh

cover-integration:
	bin/coverage.sh -i $$COVERALLS_TOKEN

vet:
	go vet ./...

lint:
	golint ./...

build:
	go fmt ./...
	godep go build -ldflags $(LDFLAGS) -o bin/$(EXECUTABLE)

build-docker:
	GOOS=linux CGO_ENABLED=0 godep go build -a -installsuffix cgo -ldflags $(LDFLAGS) -o bin/$(EXECUTABLE)-linux
	docker build -t nsq-to-s3 .

docker-login:
	docker login -u="$$DOCKER_USER" -p="$$DOCKER_AUTH"

publish:
	@echo "==> Publishing $(EXECUTABLE) to $(REMOTE_REPO)"
	@echo "==> Tagging with '$(BRANCH)' and pushing"
	docker rmi $(REMOTE_REPO):$(BRANCH) >/dev/null 2>&1 || true
	docker tag $(IMAGE) $(REMOTE_REPO):$(BRANCH)
	docker push $(REMOTE_REPO):$(BRANCH)
	@echo "==> Tagging with '$(REV)' and pushing"
	docker rmi $(REMOTE_REPO):$(REV) >/dev/null 2>&1 || true
	docker tag $(IMAGE) $(REMOTE_REPO):$(REV)
	docker push $(REMOTE_REPO):$(REV)

install:
	go fmt ./...
	godep go install -ldflags $(LDFLAGS) $(BINARIES)


install-dev-tools:
	go get github.com/tools/godep && go install github.com/tools/godep
	go get golang.org/x/tools/cmd/cover && go install golang.org/x/tools/cmd/cover
	go get golang.org/x/tools/cmd/vet && go install golang.org/x/tools/cmd/vet
	go get github.com/golang/lint
	go get github.com/golang/lint/golint && go install github.com/golang/lint/golint
	go get golang.org/x/tools/cmd/goimports && go install golang.org/x/tools/cmd/goimports
	go get github.com/nsf/gocode && go install github.com/nsf/gocode
	go get github.com/rogpeppe/godef && go install github.com/rogpeppe/godef
	go get github.com/axw/gocov/gocov && go install github.com/axw/gocov/gocov
	go get gopkg.in/matm/v1/gocov-html && go install gopkg.in/matm/v1/gocov-html

clean:
	go clean ./...
