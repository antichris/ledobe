# Changelog

This project adheres to [Semantic Versioning][semver2].

## 0.3.0

### Added

- Automatic Git fetch whenever a component version is changed in the Makefile
- Manifests of bundled contents for the `build` and `home` directories in the final image, created during the `aggregate` stage
- Solution for "No rule to make target" error when building core lib to the `README`

### Changed

- Makefile recipe for Djinni not to remove the files it generates in the core lib
- The `aggregate` stage of Dockerfile:
	- To support running commands by being based of the `base` image
	- To gather the files for the final stage under a sub-directory (instead of root)
- Order of directives in the `aggregate` stage to reduce the potential for build cache misses caused by `ENV` variable value changes
- Names of `make` dependency sentinels to form a directory structure

### Fixed

- Git checkouts of each component in Makefile to use the respective version variable as a ref explicitly, instead of trying to check out a file if the ref is not valid
- Dockerfile to prepare a manifest of the `home` directory bundled contents during the `aggregate` build stage, instead of generating in the Docker `entrypoint` every time a container starts
- Makefile recipe for Djinni to depend on the core lib sources alone, without building the core lib binary


## 0.2.0

### Added

- Proper support for the version numbers in Makefile. Changing any of them triggers a Git checkout and rebuild of the corresponding component
- A Makefile variable for core lib CMake options
- A `base` stage in Dockerfile for all other stages, including the final image
- Suppression of error messages of `find` when searching core lib source dependencies in Makefile
- An `rmrf` function in Makefile that suppresses errors on file/directory removal

### Changed

- Core lib CMake options not to build tests
- Makefile core lib Git target to run Git `submodule init`
- Time zone to `Etc/UTC` for all stages in Dockerfile
- `debconf` interface to `noninteractive` for all download stages in Dockerfile
- Docker `entrypoint` layout to be structured with functions

### Fixed

- Missing user-local NPM directory on initial run, which prevented global installs and execution of NPM commands without restarting the container
- Severe Docker `entrypoint` performance degradation when the home directory has many files, as when running after previous build sessions having cached NPM, SBT and Yarn packages
- Repeated regeneration of core lib CMake build files, caused by the Makefile target for patching the `sha512256` portability header having circular dependency (changing the sources and having to run again because the sources are changed)

### Updated

- Ledger Live components:
	- Desktop to `2.37.2`
	- core lib to `4.2.0-rc-845b1b`
	- core lib bindings for Node.js to `6.14.5`
- Node.js to `14.18.3`
- Yarn to `1.22.17`
- Build environment packages (Dockerfile `final` stage):
	- `libudev-dev` to `245.4-4ubuntu3.15`
	- `openjdk-8-jre-headless` to `8u312-b07-0ubuntu1~20.04`
	- `openssh-client` to `1:8.2p1-4ubuntu0.4`
	- `qtbase5-dev` to `5.12.8+dfsg-0ubuntu2.1`
- `wget` package in download stages to `1.20.3-1ubuntu2`

### Downgraded

- SBT version down to `0.13.17`, what Djinni actually uses


## 0.1.5

### Updated

- `libudev-dev` package to `245.4-4ubuntu3.13`


## 0.1.4

### Added

- Two more sections to `README`:
	- Scope
	- Troubleshooting


## 0.1.3

### Updated

- `ca-certificates` package to `20210119~20.04.2`
- `git` package to `1:2.25.1-1ubuntu3.2`


## 0.1.2

### Updated

- `libudev-dev` package to `245.4-4ubuntu3.11`


## 0.1.1

### Updated

- `libudev-dev` package to `245.4-4ubuntu3.7`


## 0.1.0

Initial release


[semver2]: https://semver.org/spec/v2.0.0.html
