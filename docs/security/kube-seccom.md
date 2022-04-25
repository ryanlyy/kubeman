This page is related with seccomp
---

- [seccomp Purpose](#seccomp-purpose)
- [docker default](#docker-default)
- [CRIO default](#crio-default)
- [containerd default](#containerd-default)
- [seccomp kube implementation](#seccomp-kube-implementation)


https://jvns.ca/blog/2020/04/29/why-strace-doesnt-work-in-docker/

# seccomp Purpose
https://kubernetes.io/docs/tutorials/clusters/seccomp/

seccomp (short for secure computing mode) is a computer security facility in the Linux kernel. seccomp allows a process to make a one-way transition into a "secure" state where it cannot make any system calls except exit(), sigreturn(), read() and write() to already-open file descriptors. Should it attempt any other system calls, the kernel will terminate the process with SIGKILL or SIGSYS.[1][2] In this sense, it does not virtualize the system's resources but isolates the process from them entirely.

seccomp mode is enabled via the prctl(2) system call using the PR_SET_SECCOMP argument, or (since Linux kernel 3.17[3]) via the seccomp(2) system call.[4] seccomp mode used to be enabled by writing to a file, /proc/self/seccomp, but this method was removed in favor of prctl().[5] In some kernel versions, seccomp disables the RDTSC x86 instruction, which returns the number of elapsed processor cycles since power-on, used for high-precision timing.[6] 

# docker default
The default seccomp profile provides a sane default for running containers with seccomp and disables around 44 system calls out of 300+. It is moderately protective while providing wide application compatibility

https://github.com/moby/moby/blob/master/profiles/seccomp/default.json

# CRIO default 
[SecurityProfile_RuntimeDefault](https://github.com/cri-o/cri-o/blob/main/internal/config/seccomp/seccomp.go)
```bash
/etc/crio/seccomp.json
```
[CRIO runtime/default seccomp](crio-seccomp.json)

# containerd default
https://github.com/containerd/cri/blob/master/vendor/github.com/containerd/containerd/contrib/seccomp/seccomp_default.go

# seccomp kube implementation
```golang
fs.StringVar(&f.SeccompProfileRoot, "seccomp-profile-root", f.SeccompProfileRoot, "<Warning: Alpha feature> Directory path for seccomp profiles.")

        return &KubeletFlags{
                ContainerRuntimeOptions: *NewContainerRuntimeOptions(),
                CertDirectory:           "/var/lib/kubelet/pki",
                RootDirectory:           defaultRootDir,
                MasterServiceNamespace:  metav1.NamespaceDefault,
                MaxContainerCount:       -1,
                MaxPerPodContainerCount: 1,
                MinimumGCAge:            metav1.Duration{Duration: 0},
                NonMasqueradeCIDR:       "10.0.0.0/8",
                RegisterSchedulable:     true,
                RemoteRuntimeEndpoint:   remoteRuntimeEndpoint,
                NodeLabels:              make(map[string]string),
                RegisterNode:            true,
                SeccompProfileRoot:      filepath.Join(defaultRootDir, "seccomp"),
        }
}


const defaultRootDir = "/var/lib/kubelet"

        k, err := createAndInitKubelet(&kubeServer.KubeletConfiguration,
                kubeDeps,
                &kubeServer.ContainerRuntimeOptions,
                kubeServer.ContainerRuntime,
                hostname,
                hostnameOverridden,
                nodeName,
                nodeIPs,
                kubeServer.ProviderID,
                kubeServer.CloudProvider,
                kubeServer.CertDirectory,
                kubeServer.RootDirectory,
                kubeServer.ImageCredentialProviderConfigFile,
                kubeServer.ImageCredentialProviderBinDir,
                kubeServer.RegisterNode,
                kubeServer.RegisterWithTaints,
                kubeServer.AllowedUnsafeSysctls,
                kubeServer.ExperimentalMounterPath,
                kubeServer.KernelMemcgNotification,
                kubeServer.ExperimentalCheckNodeCapabilitiesBeforeMount,
                kubeServer.ExperimentalNodeAllocatableIgnoreEvictionThreshold,
                kubeServer.MinimumGCAge,
                kubeServer.MaxPerPodContainerCount,
                kubeServer.MaxContainerCount,
                kubeServer.MasterServiceNamespace,
                kubeServer.RegisterSchedulable,
                kubeServer.KeepTerminatedPodVolumes,
                kubeServer.NodeLabels,
                kubeServer.SeccompProfileRoot,
                kubeServer.NodeStatusMaxImages,
                kubeServer.KubeletFlags.SeccompDefault || kubeServer.KubeletConfiguration.SeccompDefault,
        )


func fieldProfile(scmp *v1.SeccompProfile, profileRootPath string, fallbackToRuntimeDefault bool) string {
        if scmp == nil {
                if fallbackToRuntimeDefault {
                        return v1.SeccompProfileRuntimeDefault
                }
                return ""
        }
        if scmp.Type == v1.SeccompProfileTypeRuntimeDefault {
                return v1.SeccompProfileRuntimeDefault
        }
        if scmp.Type == v1.SeccompProfileTypeLocalhost && scmp.LocalhostProfile != nil && len(*scmp.LocalhostProfile) > 0 {
                fname := filepath.Join(profileRootPath, *scmp.LocalhostProfile)
                return v1.SeccompLocalhostProfileNamePrefix + fname
        }
        if scmp.Type == v1.SeccompProfileTypeUnconfined {
                return v1.SeccompProfileNameUnconfined
        }

        if fallbackToRuntimeDefault {
                return v1.SeccompProfileRuntimeDefault
        }
        return ""
}

```

profileRootPath is only used by localHost profile. Currently NCS does not support localhost profile (/var/lib/kubelet/seccomp)

Next to show how kubelet control effective securityContext

```golang
// determineEffectiveSecurityContext gets container's security context from v1.Pod and v1.Container.
func (m *kubeGenericRuntimeManager) determineEffectiveSecurityContext(pod *v1.Pod, container *v1.Container, uid *int64, username string) *runtimeapi.LinuxContainerSecurityContext {
        effectiveSc := securitycontext.DetermineEffectiveSecurityContext(pod, container)
        synthesized := convertToRuntimeSecurityContext(effectiveSc)
        if synthesized == nil {
                synthesized = &runtimeapi.LinuxContainerSecurityContext{
                        MaskedPaths:   securitycontext.ConvertToRuntimeMaskedPaths(effectiveSc.ProcMount),
                        ReadonlyPaths: securitycontext.ConvertToRuntimeReadonlyPaths(effectiveSc.ProcMount),
                }
        }

//###############################################
        // TODO: Deprecated, remove after we switch to Seccomp field
        // set SeccompProfilePath.
        synthesized.SeccompProfilePath = m.getSeccompProfilePath(pod.Annotations, container.Name, pod.Spec.SecurityContext, container.SecurityContext, m.seccompDefault)

        synthesized.Seccomp = m.getSeccompProfile(pod.Annotations, container.Name, pod.Spec.SecurityContext, container.SecurityContext, m.seccompDefault)

//#############################################
        // set ApparmorProfile.
        synthesized.ApparmorProfile = apparmor.GetProfileNameFromPodAnnotations(pod.Annotations, container.Name)

        // set RunAsUser.
        if synthesized.RunAsUser == nil {
                if uid != nil {
                        synthesized.RunAsUser = &runtimeapi.Int64Value{Value: *uid}
                }
                synthesized.RunAsUsername = username
        }
        // set namespace options and supplemental groups.
        synthesized.NamespaceOptions = namespacesForPod(pod)
        podSc := pod.Spec.SecurityContext
        if podSc != nil {
                if podSc.FSGroup != nil {
                        synthesized.SupplementalGroups = append(synthesized.SupplementalGroups, int64(*podSc.FSGroup))
                }

                if podSc.SupplementalGroups != nil {
                        for _, sg := range podSc.SupplementalGroups {
                                synthesized.SupplementalGroups = append(synthesized.SupplementalGroups, int64(sg))
                        }
                }
        }
        if groups := m.runtimeHelper.GetExtraSupplementalGroupsForPod(pod); len(groups) > 0 {
                synthesized.SupplementalGroups = append(synthesized.SupplementalGroups, groups...)
        }

        synthesized.NoNewPrivs = securitycontext.AddNoNewPrivileges(effectiveSc)

        synthesized.MaskedPaths = securitycontext.ConvertToRuntimeMaskedPaths(effectiveSc.ProcMount)
        synthesized.ReadonlyPaths = securitycontext.ConvertToRuntimeReadonlyPaths(effectiveSc.ProcMount)

        return synthesized
}



func fieldSeccompProfile(scmp *v1.SeccompProfile, profileRootPath string, fallbackToRuntimeDefault bool) *runtimeapi.SecurityProfile {
        if scmp == nil {
                if fallbackToRuntimeDefault {
                        return &runtimeapi.SecurityProfile{
                                ProfileType: runtimeapi.SecurityProfile_RuntimeDefault,
                        }
                }
                return &runtimeapi.SecurityProfile{
                        ProfileType: runtimeapi.SecurityProfile_Unconfined,
                }
        }

//########################################
        if scmp.Type == v1.SeccompProfileTypeRuntimeDefault {
                return &runtimeapi.SecurityProfile{
                        ProfileType: runtimeapi.SecurityProfile_RuntimeDefault,
                }
        }
        if scmp.Type == v1.SeccompProfileTypeLocalhost && scmp.LocalhostProfile != nil && len(*scmp.LocalhostProfile) > 0 {
                fname := filepath.Join(profileRootPath, *scmp.LocalhostProfile)
                return &runtimeapi.SecurityProfile{
                        ProfileType:  runtimeapi.SecurityProfile_Localhost,
                        LocalhostRef: fname,
                }
        }
//#######################################################
        return &runtimeapi.SecurityProfile{
                ProfileType: runtimeapi.SecurityProfile_Unconfined,
        }
}



// Available profile types.
type SecurityProfile_ProfileType int32

const (
        // The container runtime default profile should be used.
        SecurityProfile_RuntimeDefault SecurityProfile_ProfileType = 0
        // Disable the feature for the sandbox or the container.
        SecurityProfile_Unconfined SecurityProfile_ProfileType = 1
        // A pre-defined profile on the node should be used.
        SecurityProfile_Localhost SecurityProfile_ProfileType = 2
)

var SecurityProfile_ProfileType_name = map[int32]string{
        0: "RuntimeDefault",
        1: "Unconfined",
        2: "Localhost",
}

var SecurityProfile_ProfileType_value = map[string]int32{
        "RuntimeDefault": 0,
        "Unconfined":     1,
        "Localhost":      2,
}

```


runtime/default == docker/default
```golang
// SeccompFieldForAnnotation takes a pod annotation and returns the converted
// seccomp profile field.
func SeccompFieldForAnnotation(annotation string) *api.SeccompProfile {
        // If only seccomp annotations are specified, copy the values into the
        // corresponding fields. This ensures that existing applications continue
        // to enforce seccomp, and prevents the kubelet from needing to resolve
        // annotations & fields.
        if annotation == v1.SeccompProfileNameUnconfined {
                return &api.SeccompProfile{Type: api.SeccompProfileTypeUnconfined}
        }

        if annotation == api.SeccompProfileRuntimeDefault || annotation == api.DeprecatedSeccompProfileDockerDefault {
                return &api.SeccompProfile{Type: api.SeccompProfileTypeRuntimeDefault}
        }

        if strings.HasPrefix(annotation, v1.SeccompLocalhostProfileNamePrefix) {
                localhostProfile := strings.TrimPrefix(annotation, v1.SeccompLocalhostProfileNamePrefix)
                if localhostProfile != "" {
                        return &api.SeccompProfile{
                                Type:             api.SeccompProfileTypeLocalhost,
                                LocalhostProfile: &localhostProfile,
                        }
                }
        }

        // we can only reach this code path if the localhostProfile name has a zero
        // length or if the annotation has an unrecognized value
        return nil
}


// convertToRuntimeSecurityContext converts v1.SecurityContext to runtimeapi.SecurityContext.
func convertToRuntimeSecurityContext(securityContext *v1.SecurityContext) *runtimeapi.LinuxContainerSecurityContext {
        if securityContext == nil {
                return nil
        }

        sc := &runtimeapi.LinuxContainerSecurityContext{
                Capabilities:   convertToRuntimeCapabilities(securityContext.Capabilities),
                SelinuxOptions: convertToRuntimeSELinuxOption(securityContext.SELinuxOptions),
        }
        if securityContext.RunAsUser != nil {
                sc.RunAsUser = &runtimeapi.Int64Value{Value: int64(*securityContext.RunAsUser)}
        }
        if securityContext.RunAsGroup != nil {
                sc.RunAsGroup = &runtimeapi.Int64Value{Value: int64(*securityContext.RunAsGroup)}
        }
        if securityContext.Privileged != nil {
                sc.Privileged = *securityContext.Privileged
        }
        if securityContext.ReadOnlyRootFilesystem != nil {
                sc.ReadonlyRootfs = *securityContext.ReadOnlyRootFilesystem
        }

        return sc
}

```
