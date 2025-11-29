# Toy Advanced Submodule

This repository demonstrates that git submodule has the equivalent functionality commonly used by [vcstool](https://github.com/dirk-thomas/vcstool).

Submodules are registered in [`.gitmodules`](.gitmodules), each specifies

```ini
[submodule "submodule_name"]
	path = path/to/submodule
	url = <remote git URL>
	branch = my_branch
    update = none
```

## Cloning the repository

```bash
$ cd <your-workspace>
$ git clone git@github.com:paulsohn/toy-advanced-submodule.git
$ cd toy-advanced-submodule
```

Note that in order to defer submodule checkout, `--recursive` flag is not used here.

## Initialization / Deinitialization by group

After cloning, you can initialize submodules which are only under specified directories.

```bash
# initialize submodules under sub/group-a, not sub/group-b
$ git submodule update --init --checkout sub/group-a
# initialize submodules under sub/group-b
$ git submodule update --init --checkout sub/group-b

# deinitialize submodules under sub/group-a, not sub/group-b
$ git submodule deinit sub/group-a
# deinitialize submodules under sub/group-b
$ git submodule deinit sub/group-b

# initialize all submodules at once
$ git submodule update --init --checkout
# deinitialize all submodules at once
$ git submodule deinit --all
```

`--checkout` flag is necessary for initializing `update = none` submodules.

## Syncing the submodules

```bash
# update every branch-tracking submodules into the latest
$ git submodule update --remote
# revert every branch-tracking submodules into the current commit
$ git submodule update
```

Unlike initializing, `--checkout` flag should not be specified, so that `update = none` submodules are not updated.
These commands accepts pathspec as the last argument, so that you can sync / revert only particular directories.

## Finding the version (and the tag)

Although every submodule is pinned to a particular version, the versions and tags are not maintained inside any regular files.

To see the commit hashes and associated tags of a submodule, you can use `git submodule status` command.

```bash
# status of a submodule
$ git submodule status sub/group-a/hello1
 2a52e96389d02209b451ae1ddf45d645b42d744c sub/group-a/hello1 (RELEASE_1.0)
# status of multiple submodules in a direcotry
$ git submodule status sub/group-a
 2a52e96389d02209b451ae1ddf45d645b42d744c sub/group-a/hello1 (RELEASE_1.0)
 a4bb0474c5a88a7dba12bd9d4765666f12d8b0c7 sub/group-a/nested/hello2 (a4bb047)
# status of all submodules
$ git submodule status
 2a52e96389d02209b451ae1ddf45d645b42d744c sub/group-a/hello1 (RELEASE_1.0)
 a4bb0474c5a88a7dba12bd9d4765666f12d8b0c7 sub/group-a/nested/hello2 (a4bb047)
 8d2636da55da593c421e1cb09eea502a05556a69 sub/group-b/hello3 (RELEASE_1.1)
 a9095e79eaafd9f11a9d12e5a1ae125fde81a5eb sub/group-b/nested/hello4 (remotes/origin/bisect)
```

## Pinning the version

You can change the remote-tracking branch of each submodule:

```bash
# set tracking branch to 'bisect'
$ git submodule set-branch -b bisect sub/group-a/hello1
# unset tracking branch
$ git submodule set-branch -d sub/group-a/hello1
```

**Important Note**:
even if you set tracking branch automatically, the pinned version does not update automatically to the branch HEAD.
If you just set the branch, then don't forget to do:

```bash
$ git submodule update --remote --checkout sub/group-a/hello1
```
or
```bash
$ git -C sub/group-a/hello1 switch bisect sub/group-a/hello1
```

## Checking out to a specific version

```bash
$ cd sub/group-a/hello1
$ git checkout master # branch name, tag or commit hash
$ cd - # to the superproject directory
```

Some notes:
* `cd` can be omitted; every git command can be executed with a context, and in this case `git -C sub/group-a/hello1 checkout master`.
* The superproject does not distinguish whether a submodule is on a branch or in detatched HEAD state, as long as the commit hashes agree with each other.

## Adding and removing a submodule

Adding a new submodule:
```bash
$ git submodule add --branch <branch_to_follow> --name <submodule_name> <remote_repository_url> path/to/submodule
```
The submodule name specifier `--name <submodule_name>` is optional, and defaults to the submodule path if omitted.

Removing an exising submodule:
```bash
$ git submodule rm path/to/submodule
```
If you added a submodule and not yet commited, then you should add `--force` before the path and do force removal.

For example, if you want to clone `https://github.com/githubtraining/github-games` into `sub/group-a/github-games`, with the name `games`:
```bash
$ git submodule add --branch game-instructions --name games https://github.com/githubtraining/github-games sub/group-a/github-games
```

Later, if you want to remove the `games` submodule, you can:
```bash
$ git rm sub/group-a/github-games
```

If you just don't need the submodule locally, but have no intention to commit its removal, then consider deinitializing it.

Submodule names are often confusing, since some git commands accepts logical names for git submodule but other doesn't.
I recommend not to specify submodule name at all.
