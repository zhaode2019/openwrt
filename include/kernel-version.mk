# Use the default kernel version if the Makefile doesn't override it

LINUX_RELEASE?=1

ifdef CONFIG_TESTING_KERNEL
  KERNEL_PATCHVER:=$(KERNEL_TESTING_PATCHVER)
endif

LINUX_VERSION-4.9 = .243
LINUX_VERSION-4.14 = .212
LINUX_VERSION-4.19 = .148
LINUX_VERSION-5.4 = .83

LINUX_KERNEL_HASH-4.9.243 = d3aa189ca7fcc6e52d6c0333a0d7acd8789e9a492b32dbf9476e926ffaa73984
LINUX_KERNEL_HASH-4.14.212 = 0e1bc32c4842c3bbee3a15454408f528acd4d3c5e83312b93008d5ee2e9a0c79
LINUX_KERNEL_HASH-4.19.148 = 3308c74a93ce6d4e495fde35d1351061240a895f76a288248c343713bd63555b
LINUX_KERNEL_HASH-5.4.83 = beec970bbb93de8ab839f27930f7ab00c7bd65af0ffa07a50e765affdc2561c6

remove_uri_prefix=$(subst git://,,$(subst http://,,$(subst https://,,$(1))))
sanitize_uri=$(call qstrip,$(subst @,_,$(subst :,_,$(subst .,_,$(subst -,_,$(subst /,_,$(1)))))))

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_CLONE_URI)),)
  LINUX_VERSION:=$(call sanitize_uri,$(call remove_uri_prefix,$(CONFIG_KERNEL_GIT_CLONE_URI)))
  ifeq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
    CONFIG_KERNEL_GIT_REF:=HEAD
  endif
  LINUX_VERSION:=$(LINUX_VERSION)-$(call sanitize_uri,$(CONFIG_KERNEL_GIT_REF))
else
ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif
ifdef KERNEL_TESTING_PATCHVER
  LINUX_TESTING_VERSION:=$(KERNEL_TESTING_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_TESTING_PATCHVER)))
endif
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_HASH:=$(LINUX_KERNEL_HASH-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_HASH?=x
