######################### -*- Mode: Makefile-Gmake -*- ########################
## ppc.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:31:06 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Mon Dec 26 22:24:07 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 2
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : handle the architecture specific variables.
## 
## arch-tag: d59ba6c1-4d5e-46c2-aa8f-8c6e1d4a487b
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

# prpmc and mbx are not guessed automatically yet.
ifeq ($(DEB_BUILD_ARCH),powerpc)
# This is only meaningful when building on a PowerPC
  ifeq ($(GUESS_SUBARCH),)
    GUESS_MACHINE:=$(shell awk '/machine/ { print $$3}' /proc/cpuinfo)
    GUESS_CPU:=$(shell awk '/cpu/ { print $$3}' /proc/cpuinfo)
    GUESS_GENERATION:=$(shell awk '/generation/ { print $$3}' /proc/cpuinfo)
    ifneq (,$(findstring POWER,$(GUESS_CPU)))
      GUESS_SUBARCH:=powerpc64
    else
      ifneq (,$(findstring PPC970,$(GUESS_CPU)))
        GUESS_SUBARCH:=powerpc64
      else
        ifneq (,$(findstring NuBus,$(GUESS_GENERATION)))
          GUESS_SUBARCH:=nubus
        else
          ifneq (,$(findstring Amiga,$(GUESS_MACHINE)))
            GUESS_SUBARCH:=apus
          endif
	endif
      endif
    endif
    ifeq ($(GUESS_SUBARCH),)
      GUESS_SUBARCH:=powerpc
    endif
  else
    GUESS_SUBARCH:=powerpc
  endif
endif

ifeq (,$(findstring $(KPKG_SUBARCH),apus Amiga APUs nubus powerpc powerpc32 powerpc64 prpmc mbx MBX))
  KPKG_SUBARCH:=$(GUESS_SUBARCH)
endif

KERNEL_ARCH:=powerpc

ifneq (,$(findstring $(KPKG_SUBARCH), powerpc powerpc32 powerpc64))
  ifneq (,$(findstring $(KPKG_SUBARCH), powerpc64))
    target := vmlinux
  endif
  ifneq (,$(findstring $(KPKG_SUBARCH), powerpc powerpc32))
    NEED_IMAGE_POST_PROCESSING = YES
    IMAGE_POST_PROCESS_TARGET := mkvmlinuz_support_install
    IMAGE_POST_PROCESS_DIR    := arch/powerpc/boot
    INSTALL_MKVMLINUZ_PATH = $(SRCTOP)/$(IMAGE_TOP)/usr/lib/kernel-image-${version}
    target := zImage
    loaderdep=mkvmlinuz
    target := vmlinux
    KERNEL_ARCH:=ppc
  endif
  kimagesrc = vmlinux
  kimage := vmlinux
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG= $(CONFDIR)/config.$(KPKG_SUBARCH)
endif

ifneq (,$(findstring $(KPKG_SUBARCH),APUs apus Amiga))
  KPKG_SUBARCH:=apus
  KERNEL_ARCH:=ppc
  loader := NoLoader
  kimage := vmapus.gz
  target = zImage
  kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/boot/images ]; then \
	echo arch/$(KERNEL_ARCH)/boot/images/vmapus.gz ; else \
	echo arch/$(KERNEL_ARCH)/boot/$(kimage) ; fi)
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG = $(CONFDIR)/config.apus
endif

ifneq (,$(findstring $(KPKG_SUBARCH), NuBuS nubus))
  KPKG_SUBARCH := nubus
  KERNEL_ARCH:=ppc
  target := zImage
  loader= NoLoader
  kimagesrc = arch/$(KERNEL_ARCH)/appleboot/Mach\ Kernel
  kimage := vmlinux
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
endif

ifneq (,$(findstring $(KPKG_SUBARCH),PRPMC prpmc))
  KPKG_SUBARCH:=prpmc
  KERNEL_ARCH:=ppc
  loader := NoLoader
  kimage := zImage
  target = $(kimage)
  kimagesrc = arch/$(KERNEL_ARCH)/boot/images/zImage.pplus
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
endif

ifneq (,$(findstring $(KPKG_SUBARCH),MBX mbx))
  KPKG_SUBARCH:=mbx
  KERNEL_ARCH:=ppc
  loader := NoLoader
  kimage := zImage
  target = $(kimage)
  kimagesrc = $(shell if [ -d arch/$(KERNEL_ARCH)/mbxboot ]; then \
	echo arch/$(KERNEL_ARCH)/mbxboot/$(kimage) ; else \
	echo arch/$(KERNEL_ARCH)/boot/images/zvmlinux.embedded; fi)
  kimagedest = $(INT_IMAGE_DESTDIR)/vmlinuz-$(version)
  kelfimagesrc = vmlinux
  kelfimagedest = $(INT_IMAGE_DESTDIR)/vmlinux-$(version)
  DEBCONFIG = $(CONFDIR)/config.mbx
endif

#Local variables:
#mode: makefile
#End: