ifndef VERBOSE
.SILENT:
endif

.DEFAULT_GOAL := help

log_error = (>&2 echo "\x1B[31m>> Error:$1\x1B[39m\n" && $(MAKE) help && exit 1)

.PHONY: help
help:
	@echo "Usage: make [os] [version] [command]"
	@echo "\n"
	@echo "Examples:"
	@echo "  make ubuntu 2004 up"
	@echo "  make windows server-2019 destroy"
	@echo "  make windows server-2019 rdp"
	@echo "  make ubuntu 2004 ssh"
	@echo "\n"


# Operating System Config

# ============= Windows ============= #
.PHONY: windows
windows:
	$(eval PLAT=windows)

server-2012R2:
	$(eval VERSION=server-2012R2)

server-2016:
	$(eval VERSION=server-2016)

server-2019:
	$(eval VERSION=server-2019)

server-2022:
	$(eval VERSION=server-2022)

# ============= Ubuntu ============= #
.PHONY: ubuntu
ubuntu:
	$(eval PLAT=ubuntu)

2204:
	$(eval VERSION=2004)

# ============= Vagrant ============= #

.PHONY: up
up:
	@[ "${PLAT}" ] || $(call log_error, "Operating System is not defined")
	@[ "${VERSION}" ] || $(call log_error, "Version is not defined")

	@VAGRANT_CWD=${PLAT}/${VERSION} vagrant up

.PHONY: destroy
destroy:
	@[ "${PLAT}" ] || $(call log_error, "Operating System is not defined")
	@[ "${VERSION}" ] || $(call log_error, "Version is not defined")

	@VAGRANT_CWD=${PLAT}/${VERSION} vagrant destroy -f

.PHONY: ssh
ssh:
	@[ "${PLAT}" ] || $(call log_error, "Operating System is not defined")
	@[ "${VERSION}" ] || $(call log_error, "Version is not defined")

	@VAGRANT_CWD=${PLAT}/${VERSION} vagrant ssh

.PHONY: rdp
	@[ "${PLAT}" ] || $(call log_error, "Operating System is not defined")
	@[ "${VERSION}" ] || $(call log_error, "Version is not defined")

	@VAGRANT_CWD=${PLAT}/${VERSION} vagrant rdp
