# macos m1 ldap: fix "authentication is disabled"

After changing password via an internal website (ldap), macos gives
"authentication is disabled" for touch id related setting.

Fix is quite simple:

```sh
# run these command directly (without sudo / su - another-admin-user)
#
# but for the first two commands, remember to switch user to another admin
# user when prompt password, since another admin's password is unaffected.
sysadminctl -secureTokenOff <username> -password <AD-pwd> interactive
sysadminctl -secureTokenOn <username> -password <AD-pwd> interactive
diskutil apfs UpdatePreboot /
# no reboot is required.
```

ref: <https://copyprogramming.com/howto/authentication-is-disabled-how-to-verify-whether-this-is-local-disabling-or-active-directory-disabling>
