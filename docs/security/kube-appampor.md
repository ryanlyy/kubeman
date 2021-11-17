This page includes appampor related information 
---

- [Kubernetes Configuration](#kubernetes-configuration)
- [kubernetes Runtime/Default](#kubernetes-runtimedefault)
  - [CRIO](#crio)
  - [Containerd](#containerd)
  - [Dockerd](#dockerd)
  - [Podman](#podman)
- [Q&A](#qa)
- [Appendix 1](#appendix-1)


# Kubernetes Configuration
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'

```
```yaml
metadata.annotations["container.apparmor.security.beta.kubernetes.io/*"]
```
* PSP
When PSP is used and with defaultProfileName, then "container.apparmor.security.beta.kubernetes.io" will be added into pod annotation automatically for each containers in this pod

* PSS/PSA
When PSS/PSA is used, if need to support AppArmor, then helm/chart shall be added into annotations for container.apparmor.security.beta.kuberentes.io for each container in this pod

# kubernetes Runtime/Default 
## CRIO
```golang
func (p *profileData) generateDefault(apparmorParserPath string, out io.Writer) error {
    compiled, err := template.New("apparmor_profile").Parse(defaultProfileTemplate)
    if err != nil {
        return errors.Wrap(err, "create AppArmor profile from template")
    }
    if macroExists("tunables/global") {
        p.Imports = append(p.Imports, "#include <tunables/global>")
    } else {
        p.Imports = append(p.Imports, "@{PROC}=/proc/")
    }
    if macroExists("abstractions/base") {
        p.InnerImports = append(p.InnerImports, "#include <abstractions/base>")
    }
    ver, err := getAAParserVersion(apparmorParserPath)
    if err != nil {
        return errors.Wrap(err, "get AppArmor version")
    }
    p.Version = ver
    return errors.Wrap(compiled.Execute(out, p), "execute compiled profile")
}
```

## Containerd
```golang
func loadData(name string) (*data, error) {
    p := data{Name: name,}
    if macroExists("tunables/global") {
        p.Imports = append(p.Imports, "#include <tunables/global>")
    } else {
        p.Imports = append(p.Imports, "@{PROC}=/proc/")
    }
    if macroExists("abstractions/base") {
        p.InnerImports = append(p.InnerImports, "#include <abstractions/base>")
    }
    ver, err := getVersion()
    if err != nil {
        return nil, errors.Wrap(err, "get apparmor_parser version")
    }
    p.Version = ver
    // Figure out the daemon profile.
    currentProfile, err := os.ReadFile("/proc/self/attr/current")
    if err != nil {
        // If we couldn't get the daemon profile, assume we are running
        // unconfined which is generally the default.
        currentProfile = nil
    }
    p.DaemonProfile = cleanProfileName(string(currentProfile))
    return &p, nil
}
```

## Dockerd
```golang
// generateDefault creates an apparmor profile from ProfileData.
func (p *profileData) generateDefault(out io.Writer) error {
        compiled, err := template.New("apparmor_profile").Parse(baseTemplate)
        if err != nil {
                return err
        }

        if macroExists("tunables/global") {
                p.Imports = append(p.Imports, "#include <tunables/global>")
        } else {
                p.Imports = append(p.Imports, "@{PROC}=/proc/")
        }

        if macroExists("abstractions/base") {
                p.InnerImports = append(p.InnerImports, "#include <abstractions/base>")
        }

        ver, err := aaparser.GetVersion()
        if err != nil {
                return err
        }
        p.Version = ver

        return compiled.Execute(out, p)
}
```

## Podman
```golang
func (p *profileData) generateDefault(apparmorParserPath string, out io.Writer) error {
    compiled, err := template.New("apparmor_profile").Parse(defaultProfileTemplate)
    if err != nil {
        return errors.Wrap(err, "create AppArmor profile from template")
    }
    if macroExists("tunables/global") {
        p.Imports = append(p.Imports, "#include <tunables/global>")
    } else {
        p.Imports = append(p.Imports, "@{PROC}=/proc/")
    }
    if macroExists("abstractions/base") {
        p.InnerImports = append(p.InnerImports, "#include <abstractions/base>")
    }
    ver, err := getAAParserVersion(apparmorParserPath)
    if err != nil {
        return errors.Wrap(err, "get AppArmor version")
    }
    p.Version = ver
    return errors.Wrap(compiled.Execute(out, p), "execute compiled profile")
}
```
# Q&A
- Q: Does Redhat support AppArmor?
  ```
  Red Hat Enterprise Linux kernel doesn't have support for AppArmor security modules. AppArmor is a security module for Linux kernel and it is part of the mainstream kernel since 2.6.36 kernel. It is considered as an alternative to SeLinux.
  
  Diagnostic Steps

    Documentation/security/apparmor.txt file.

    # grep -Hw CONFIG_SECURITY_APPARMOR /boot/config-$(uname -r)
    /boot/config-3.10.0-123.el7.x86_64:# CONFIG_SECURITY_APPARMOR is not set
   ```

# Appendix 1
```sh
cat global:
#include <tunables/home>
#include <tunables/multiarch>
#include <tunables/proc>
#include <tunables/alias>
#include <tunables/kernelvars>
#include <tunables/xdg-user-dirs>
#include <tunables/share>

root@lubuntu:/etc/apparmor.d/abstractions# cat base
# vim:syntax=apparmor
# ------------------------------------------------------------------
#
#    Copyright (C) 2002-2009 Novell/SUSE
#    Copyright (C) 2009-2011 Canonical Ltd.
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public
#    License published by the Free Software Foundation.
#
# ------------------------------------------------------------------



  # (Note that the ldd profile has inlined this file; if you make
  # modifications here, please consider including them in the ldd
  # profile as well.)

  # The __canary_death_handler function writes a time-stamped log
  # message to /dev/log for logging by syslogd. So, /dev/log, timezones,
  # and localisations of date should be available EVERYWHERE, so
  # StackGuard, FormatGuard, etc., alerts can be properly logged.
  /dev/log                       w,
  /dev/random                    r,
  /dev/urandom                   r,
  # Allow access to the uuidd daemon (this daemon is a thin wrapper around
  # time and getrandom()/{,u}random and, when available, runs under an
  # unprivilged, dedicated user).
  /run/uuidd/request             r,
  /etc/locale/**                 r,
  /etc/locale.alias              r,
  /etc/localtime                 r,
  /etc/writable/localtime        r,
  /usr/share/locale-bundle/**    r,
  /usr/share/locale-langpack/**  r,
  /usr/share/locale/**           r,
  /usr/share/**/locale/**        r,
  /usr/share/zoneinfo/           r,
  /usr/share/zoneinfo/**         r,
  /usr/share/X11/locale/**       r,
  /run/systemd/journal/dev-log w,
  # systemd native journal API (see sd_journal_print(4))
  /run/systemd/journal/socket w,
  # Nested containers and anything using systemd-cat need this. 'r' shouldn't
  # be required but applications fail without it. journald doesn't leak
  # anything when reading so this is ok.
  /run/systemd/journal/stdout rw,

  /usr/lib{,32,64}/locale/**             mr,
  /usr/lib{,32,64}/gconv/*.so            mr,
  /usr/lib{,32,64}/gconv/gconv-modules*  mr,
  /usr/lib/@{multiarch}/gconv/*.so           mr,
  /usr/lib/@{multiarch}/gconv/gconv-modules* mr,

  # used by glibc when binding to ephemeral ports
  /etc/bindresvport.blacklist    r,

  # ld.so.cache and ld are used to load shared libraries; they are best
  # available everywhere
  /etc/ld.so.cache               mr,
  /etc/ld.so.conf                r,
  /etc/ld.so.conf.d/{,*.conf}    r,
  /etc/ld.so.preload             r,
  /{usr/,}lib{,32,64}/ld{,32,64}-*.so   mr,
  /{usr/,}lib/@{multiarch}/ld{,32,64}-*.so    mr,
  /{usr/,}lib/tls/i686/{cmov,nosegneg}/ld-*.so     mr,
  /{usr/,}lib/i386-linux-gnu/tls/i686/{cmov,nosegneg}/ld-*.so     mr,
  /opt/*-linux-uclibc/lib/ld-uClibc*so* mr,

  # we might as well allow everything to use common libraries
  /{usr/,}lib{,32,64}/**                r,
  /{usr/,}lib{,32,64}/**.so*       mr,
  /{usr/,}lib/@{multiarch}/**            r,
  /{usr/,}lib/@{multiarch}/**.so*   mr,
  /{usr/,}lib/tls/i686/{cmov,nosegneg}/*.so*    mr,
  /{usr/,}lib/i386-linux-gnu/tls/i686/{cmov,nosegneg}/*.so*    mr,

  # /dev/null is pretty harmless and frequently used
  /dev/null                      rw,
  # as is /dev/zero
  /dev/zero                      rw,
  # recent glibc uses /dev/full in preference to /dev/null for programs
  # that don't have open fds at exec()
  /dev/full                      rw,

  # Sometimes used to determine kernel/user interfaces to use
  @{PROC}/sys/kernel/version     r,
  # Depending on which glibc routine uses this file, base may not be the
  # best place -- but many profiles require it, and it is quite harmless.
  @{PROC}/sys/kernel/ngroups_max r,

  # glibc's sysconf(3) routine to determine free memory, etc
  @{PROC}/meminfo                r,
  @{PROC}/stat                   r,
  @{PROC}/cpuinfo                r,
  @{sys}/devices/system/cpu/       r,
  @{sys}/devices/system/cpu/online r,

  # glibc's *printf protections read the maps file
  @{PROC}/@{pid}/{maps,auxv,status} r,

  # libgcrypt reads some flags from /proc
  @{PROC}/sys/crypto/*           r,

  # some applications will display license information
  /usr/share/common-licenses/**  r,

  # glibc statvfs
  @{PROC}/filesystems            r,

  # glibc malloc (man 5 proc)
  @{PROC}/sys/vm/overcommit_memory r,

  # Allow determining the highest valid capability of the running kernel
  @{PROC}/sys/kernel/cap_last_cap r,

  # Allow other processes to read our /proc entries, futexes, perf tracing and
  # kcmp for now (they will need 'read' in the first place). Administrators can
  # override with:
  #   deny ptrace (readby) ...
  ptrace (readby),

  # Allow other processes to trace us by default (they will need 'trace' in
  # the first place). Administrators can override with:
  #   deny ptrace (tracedby) ...
  ptrace (tracedby),

  # Allow us to ptrace read ourselves
  ptrace (read) peer=@{profile_name},

  # Allow unconfined processes to send us signals by default
  signal (receive) peer=unconfined,

  # Allow us to signal ourselves
  signal peer=@{profile_name},

  # Checking for PID existence is quite common so add it by default for now
  signal (receive, send) set=("exists"),

  # Allow us to create and use abstract and anonymous sockets
  unix peer=(label=@{profile_name}),

  # Allow unconfined processes to us via unix sockets
  unix (receive) peer=(label=unconfined),

  # Allow us to create abstract and anonymous sockets
  unix (create),

  # Allow us to getattr, getopt, setop and shutdown on unix sockets
  unix (getattr, getopt, setopt, shutdown),

  # Workaround https://launchpad.net/bugs/359338 until upstream handles stacked
  # filesystems generally. This does not appreciably decrease security with
  # Ubuntu profiles because the user is expected to have access to files owned
  # by him/her. Exceptions to this are explicit in the profiles. While this rule
  # grants access to those exceptions, the intended privacy is maintained due to
  # the encrypted contents of the files in this directory. Files in this
  # directory will also use filename encryption by default, so the files are
  # further protected. Also, with the use of 'owner', this rule properly
  # prevents access to the files from processes running under a different uid.

  # encrypted ~/.Private and old-style encrypted $HOME
  owner @{HOME}/.Private/ r,
  owner @{HOME}/.Private/** mrixwlk,
  # new-style encrypted $HOME
  owner @{HOMEDIRS}/.ecryptfs/*/.Private/ r,
  owner @{HOMEDIRS}/.ecryptfs/*/.Private/** mrixwlk,

```