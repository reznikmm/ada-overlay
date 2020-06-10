Ada_Ru Gentoo overlay
=====================

Small unofficial Gentoo overlay for Ada related stuff

```bash
emerge --ask app-eselect/eselect-repository
mkdir -p /etc/portage/repos.conf
eselect repository add ada-overlay git https://github.com/reznikmm/ada-overlay.git
emerge -av dev-ada/matreshka
```
