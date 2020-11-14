# usand

A convenient, minimal `unshare(1)`-based sandbox.

The current version is a proof-of-concept stage. It lacks options for
tuning its behavior, and it **not claimed to be secure** for running
potentially malicious programs.

## Premise

Run programs natively in your host filesystem, but without the ability
to write outside the tree based at the current working directory.

## Usage

```
usand.sh [cmd [args...]]
```

If `cmd` is omitted, the `unshare(1)` default of invoking a shell is
used. In the future, support for options to tune the sandboxing
behavior may be added; if so they will be placed before `cmd`.

## How it works

In a new namespace, all existing mounts are bind-remounted read-only,
then new bind mounts are made to get back a writable view of the
working directory and some essential nodes from `/dev`. Then, another
derived namespace is created, with capabilities dropped, so that the
mounts can't be unprotected from within.

See the (very short) script for details.
