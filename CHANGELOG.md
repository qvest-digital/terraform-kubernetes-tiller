# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.1] - 2019-10-11

Thanks to [Terje Torkelsen](https://github.com/tesharp) who spotted an evil typo /
copy&paste error and provided a PR to fix it.

### Fixed

- Incorrect labels on deployed pods have been changed.

## [3.2.0] - 2019-09-17

Thanks again to [Steven Miller](https://github.com/sjmiller609) who provided input
for the configurable storage backend configuration.

### Added

- The storage backend has been made configurable.

### Updated

- Default tiller version has been updated to v2.14.3

## [3.1.0] - 2019-07-28

### Added

- Support for custom TLS certificates.

## [3.0.0] - 2019-07-03

Thanks to  [Steven Miller](https://github.com/sjmiller609) for the pull request
that initiated this release!

### Updated

- The minimum required version of Terraform is now v0.12.

### Changed

- The service account token is now automatically mounted which reduces the
  complexity of the module's configuration slightly by using a new feature
  that has been introduced with version 1.8 of the kubernetes provider plugin.

### Added

- A node selector can now be specified to control where the tiller pod
  should be deployed.
- The parameter `sessionAffinity` can now be specified when configuring
  the Tiller service.

## [2.0.0] - 2019-06-26

Thanks to [Noah Fontes](https://github.com/impl) for the pull request
that made this release possible!

### Updated

- The module is now compatible with Terraform v0.12.
- Minimum required version of the Kubernetes provider plugin is now v1.7.0.
- Default Tiller version to be installed is now v2.14.1.

### Fixed

- Label matching should now work as supposed to out-of-the-box.

## [1.0.2] - 2019-02-28

### Fixed

- Creation of cluster role binding now works as supposed to.

## [1.0.1] - 2019-02-28

### Added

- The service account token (RBAC) will now automatically be mounted.

### Fixed

- The installation namespace is now truly optional and stuff won't
  be deployed into `kube-system` even if the input parameters have
  been set to a different one.

## [1.0.0] - 2019-02-06

### Added

- Support to deploy Tiller into your Kubernetes cluster using Terraform.
  This module is basically an alternative to calling `helm init` on a random
  machine.
