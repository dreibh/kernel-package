######################### -*- Mode: Makefile-Gmake -*- ########################
## minimal.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Tue Nov  1 03:31:22 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Fri Oct 10 00:27:07 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 31
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: 8b6406ba-8211-4d71-be2b-cec0bf634c2d
## 
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
###############################################################################

# This makefile is merely there for boot strapping; it only offers the
# ability to run clean, and to create a ./debian directoty. Separating
# this file greatly simplifies the rest of the kernel-package.

# Where the package libs are stored
LIBLOC     :=/usr/share/kernel-package

define which_debdir
DEBDIR=$(shell if test -f ./debian/ruleset/kernel_version.mk; then echo ./debian;     \
                                                              else echo $(LIBLOC); fi)
endef
$(eval $(which_debdir))

include $(DEBDIR)/ruleset/common/archvars.mk
include $(DEBDIR)/ruleset/misc/version_vars.mk
include $(DEBDIR)/ruleset/misc/defaults.mk
-include $(CONFLOC)
include $(DEBDIR)/ruleset/misc/config.mk

ifneq ($(strip $(filter ppc powerpc ppc64 powerpc64,$(architecture))),)
  include $(DEBDIR)/ruleset/arches/what_is_ppc_called_today.mk
endif

FILES_TO_CLEAN  = modules/modversions.h modules/ksyms.ver conf.vars \
                  scripts/cramfs/cramfsck scripts/cramfs/mkcramfs 
STAMPS_TO_CLEAN = 
DIRS_TO_CLEAN   = debian/stamp

define save_upstream_debianization
@echo save_upstream_debianization
test ! -e scripts/package/builddeb || mv -f scripts/package/builddeb scripts/package/builddeb.kpkg-dist
test ! -e scripts/package/Makefile ||					  \
    test -f scripts/package/Makefile.kpkg-dist ||			  \
    (mv -f scripts/package/Makefile scripts/package/Makefile.kpkg-dist && \
       (echo "# Dummy file "; echo "help:") >  scripts/package/Makefile)
endef

define restore_upstream_debianization
@echo restore_upstream_debianization
test ! -f scripts/package/builddeb.kpkg-dist ||	mv -f scripts/package/builddeb.kpkg-dist scripts/package/builddeb
test ! -f scripts/package/Makefile.kpkg-dist ||	mv -f scripts/package/Makefile.kpkg-dist scripts/package/Makefile
endef

# The assumption is that we have already cleaned out the source tree;
# we are only concerned now with running clean and saving the .config
# file
clean: minimal_clean
minimal_clean:
	$(REASON)
	@echo $(if $(strip $(kpkg_version)),"This is kernel package version $(kpkg_version).","Cleaning.")
ifeq ($(DEB_HOST_ARCH_OS), linux)
	$(save_upstream_debianization)
	test ! -f .config || cp -pf .config config.precious
	test ! -e stamp-building || rm -f stamp-building
	test ! -f Makefile || \
            $(MAKE) $(FLAV_ARG) $(EXTRAV_ARG) $(CROSS_ARG) ARCH=$(KERNEL_ARCH) distclean
	test ! -f config.precious || mv -f config.precious .config
	$(restore_upstream_debianization)
else
	rm -f .config
  ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	rm -rf bin
	if test -e $(architecture)/compile/GENERIC ; then     \
	  $(PMAKE) -C $(architecture)/compile/GENERIC clean ; \
	fi
  endif
endif
	rm -f $(FILES_TO_CLEAN) $(STAMPS_TO_CLEAN)

debian/stamp/conf/minimal_debian: 
	$(REASON)
	@echo "This is kernel package version $(kpkg_version)."
	test -d debian             || mkdir debian
	@test -d debian/stamp	   || mkdir debian/stamp
	@test -d debian/stamp/conf || mkdir debian/stamp/conf
	test ! -e stamp-building || rm -f stamp-building
	install -p -m 755 $(LIBLOC)/rules debian/rules
	for file in $(DEBIAN_FILES); do                                      \
            cp -f  $(LIBLOC)/$$file ./debian/;                               \
        done
	for dir  in $(DEBIAN_DIRS);  do                                      \
          cp -af $(LIBLOC)/$$dir  ./debian/;                                 \
        done
	test -f debian/control || sed         -e 's/=V/$(KERNELRELEASE)/g'  \
                -e 's/=D/$(debian)/g'         -e 's/=A/$(DEB_HOST_ARCH)/g'  \
		-e 's/=SA/$(INT_SUBARCH)/g'  \
		-e 's/=I/$(initrddep)/g'				    \
		-e 's/=CV/$(VERSION).$(PATCHLEVEL)/g'			    \
		-e 's/=M/$(maintainer) <$(email)>/g'			    \
		-e 's/=ST/$(INT_STEM)/g'      -e 's/=B/$(KERNEL_ARCH)/g'    \
                  $(CONTROL) > debian/control
	test -f debian/changelog ||  sed -e 's/=V/$(KERNELRELEASE)/g'       \
            -e 's/=D/$(debian)/g'        -e 's/=A/$(DEB_HOST_ARCH)/g'       \
            -e 's/=ST/$(INT_STEM)/g'     -e 's/=B/$(KERNEL_ARCH)/g'         \
            -e 's/=M/$(maintainer) <$(email)>/g'                            \
             $(LIBLOC)/changelog > debian/changelog
	chmod 0644 debian/control debian/changelog
	test -d ./debian/stamp || mkdir debian/stamp 
	$(MAKE) -f debian/rules debian/stamp/conf/kernel-conf
	$(MAKE) -f debian/rules debian/stamp/conf/full-changelog
	echo done > $@

debian: debian/stamp/conf/minimal_debian

#Local variables:
#mode: makefile
#End:
