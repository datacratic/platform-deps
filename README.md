# Platform Dependencies #

Container repo for Datacratic platform dependencies to be installed per-user

After cloning run: git submodule update --init && make all

## Troubleshooting ##

### GCC Internal Compiler Errors ###

It's possible that while building on a machine with limitted resources, the
compilation will fail with a gcc internal compiler error which usually indicates
that gcc ran out of memory. This can be fixed by reducing the number of
processes that make spawns during the compilation process. There's two ways to
do this:

1. Reduce the number of submodules that are built in parallel by tweaking the -j
   command line argument provided to make.

2. Reduce the number of parallel jobs that are used to build each submodule by
   overwritting the JOBS variable for our Makefile.

Here's an example of how to tweak both parameters from the command line:

   nice make -kj2 JOBS=2

Note that we don't recommend specifying a -j parameter because it has a
multiplicative effect on the JOBS variable.


### Illegal Instruction ###

CityHash makes use of the sse4.2 instruction set which can be problematic on VM
machines in the cloud. Since the specs of the host machine can change when
migrating a VM you can run into a situation where the machine used for building
CityHash has sse4.2 but the environment in which it is actually used doesn't
which will result in the SIGILL signal to be raised (illegal instruction).

If this is a possibility, we recommand turning off sse4.2 entirely using the
DISABLE_SSE42 variable like so:

    nice make all DISABLE_SSE42=1

This will prevent CityHash from taking advantage of sse4.2 instructions
regardless of whether the machine supports it or not.
