# DarkOS Linux

## About
A collection of shell scripts to compile and build a simple Linux
distribution all from source.

## Usage
The easiest method is to use the included `Dockerfile` to generate the
`iso` by running `dockerBuildExtract.sh`. That way, you don't have to worry
about needing to have all the dependencies installed. The included script,
`buildISO.sh`, does the following:
* Download all required source code
* Build each individual component (e.g. linux kernel, busybox, glibc)
* Assemble the filesystem
* Generate the `iso`

If you have `Docker` installed and wish to build with `Docker`
(recommended), run the `dockerBuildExtract.sh` script:
```bash
./dockerBuildExtract.sh
```

If you already have all the dependencies installed, you can just run the
`buildISO.sh` script:
```bash
./buildISO.sh
```

## Running
Once you have built the `iso` and boot it up, you will be greeted with the
the GRUB boot selector. After which, you will be dropped into the,
DarkOS Linux shell:
```
Welcome to DarkOS Linux <version>!
~ #
```

