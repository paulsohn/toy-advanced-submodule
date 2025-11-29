# Toy Advanced Submodule

This repository demonstrates that git submodule has the equivalent functionality commonly used by [vcstool](https://github.com/dirk-thomas/vcstool).

Submodules are registered in [`.gitmodules`](.gitmodules), each specifies

```ini
[submodule "submodule_name"]
	path = path/to/submodule
	url = <remote git URL>
	branch = my_branch # optional
    update = none # optional
```

In our submodule structure, 'branch tracking' is realized by a submodule without `submodule.<submodule_name>.update` and with `submodule.<submodule_name>.branch` specified, and 'tag/commit pinning' is realized by a submodule with `submodule.<submodule_name>.update = none` specified.

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
# revert every submodules (branch-tracking and pinned) into the version pinned in the superproject.
# if you checked out (e.g. pulled) a superproject, you must update pinned submodules as well, so `--checkout` is used.
$ git submodule update --checkout
```

These commands accepts pathspec as the last argument, so that you can sync / revert only particular directories.

Note that `git submodule update --remote --checkout` means to update every submodules to the latest remote, including `update = none` ones, which would be not an intended usecase.
It is therefore suffice to remember that `--remote` does not come along with `--checkout`.

These commands are assumed that no local submodule checkouts has been staged before the execution.

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

## Checking out to a specific version

```bash
$ cd sub/group-a/hello1
$ git checkout master # branch name, tag or commit hash from `sub/group-a/hello1` repository
$ cd - # to the superproject directory
```

`cd` can be omitted; every git command can be executed with a context, so we can use one-liner:
```bash
$ git -C sub/group-a/hello1 checkout master
```

The superproject does not distinguish whether a submodule is on a branch or in detatched HEAD state, as long as the commit hashes agree with each other.
Therefore, this is not a proper way to specify `sub/group-a/hello1` to track the `master` branch; from the superproject's perspective, the submodule is only pinned to the latest commit of the branch.
See below for the correct way (`set-branch`) to tell the superproject to use `master` branch on sync.

If you want to edit the submodule and commit the changes, then you should do things in this order:
1. Checkout the submodule into your desired base branch.
2. Create a submodule commit.
3. Create a superproject commit.

## Configuring the branch to 'track'

You can configure the remote-tracking branch of each submodule:

```bash
# set tracking branch to 'bisect'
$ git submodule set-branch -b bisect sub/group-a/hello1
# unset tracking branch
$ git submodule set-branch -d sub/group-a/hello1
```

Additionally, if `update = none` is specified in `.gitmodules` for that submodule, you might want to remove that line by CLI or in an editor, so that it can be synced.
```bash
$ git config --file .gitmodules --unset submodule.sub/group-a/hello1.update none
```

**Important Note**:
even if you have configured tracking branch automatically, the submodule version in the superproject does not update automatically to the branch HEAD.
If you have just set the branch, then do not forget to do either:
```bash
$ git submodule update --remote sub/group-a/hello1
```
or
```bash
$ git -C sub/group-a/hello1 fetch
$ git -C sub/group-a/hello1 switch bisect
```

[`check-submodules.sh`](./check-submodules.sh) can be used to check if the actual commit is on the configured branch.
Please note that all checkouts to validate should be staged before running this script.

## Pinning the version

To exclude submodule `sub/group-a/hello2` from branch-tracking, you can add `update = none` of the corresponding configuration entity.
This can be done via either an editor, or the CLI command:
```bash
$ git config --file .gitmodules submodule.sub/group-a/hello2.update none
```

Optionally, you may consider executing `git submodule set-branch -d sub/group-a/hello2`, but this does not affect to the behavior (unless you accidently executed `git submodule update --remote --checkout`) and it is in most cases informative to leave the branch name.

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

Some git commands manipulating submodules accepts logical names while others don't, so submodule name other than its path on the superdirectory might be confusing.
