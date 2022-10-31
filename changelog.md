# Changelog

## 2.4.0-i1 - 2022-10-31

* Update to ubuntu jammy (burp 2.4.0)
  * The parameter `port` isn't set on the default configuration file
    anymore; if updating either set it or add the port to the `server`
    parameter.
* Update burp-ui to 0.6.6
  * Use python 3.9 from deadsnakes PPA


## 2.2.18-i2 - 2022-07-17

* Jan Imhof:
  * burp-ui: Locked pip package versions
  * burp-ui: Added dependencies for LDAP support

## 2.2.18-i1 - 2022-02-13

* Initial release
