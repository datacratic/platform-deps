Platform Dependencies
=====================

Container repo for Datacratic platform dependencies to be installed per-user

After cloning run: git submodule update --init && make all

Troubleshooting
---------------

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
