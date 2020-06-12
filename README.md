[![Build](https://github.com/reznikmm/ada-overlay/workflows/Build/badge.svg)](https://github.com/reznikmm/ada-overlay/actions)

Ada Gentoo overlay
==================

Small unofficial Gentoo overlay for Ada related ebuilds

```bash
emerge --ask app-eselect/eselect-repository
mkdir -p /etc/portage/repos.conf
eselect repository add ada-overlay git https://github.com/reznikmm/ada-overlay.git
emerge -av dev-ada/matreshka
```
