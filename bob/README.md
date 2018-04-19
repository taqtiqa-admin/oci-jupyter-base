# Bob
Bob the [Buildah](https://github.com/projectatomic/buildah)

Bob is a collection of scripts for easily, and repeatedly building custom containers, with an emphasis on lean images, and targeting the Buildah tool.  Bob likes both `rkt` and `docker` containers. 
If you think there is a better build tool for this use case, please let us know - we can change.

It is inspired by and builds on [Veewee](https://github.com/jedi4ever/veewee)

## Opinionated
Bob tries not to be grumpy or inflexible, but he is opinionated. He currently holds the following opinions:
 - **Documentation is removed:** unless the containers purpose is to serve documents, e.g. a Jupyter container would be expected to have the documents related to the Jupyter Lab tools, but not, say, `cron` man files. The same reasoning applies to caches and logs.
 - [**Convention over configuration:**](https://en.wikipedia.org/wiki/Convention_over_configuration) Always happy to hear convention proposals, and why they work - open an issue, or pull request.
 
## Conventions
 - **Folder naming/hierarchy:** The folder hierarchy *SHALL* be resolved within a container as
````bash
 /home/bob/scripts/${DISTRIB_ID}/${DISTRIB_RELEASE}/<component>/{install|config|uninstall}/.sh
````
 - **Shell variable names:** The name communicates context and location. An example.  Setting a variable `WORKER_NAME` in the file `./alpine/3.7/nomad/install.sh` means it *SHALL* have the name `INSTALL_NOMAD_WORKER_NAME`.
 - **Buildah Configuration scripts:** *SHALL* be named `buildah-config.sh`.  Example: Once copied into the container:
````bash
/home/bob/scripts/${DISTRIB_ID}/${DISTRIB_RELEASE}/<component>/buildah-config.sh
````
 - All Bob's scripts are removed before an image save/commit/push.

## Setting up an OCI build

If you change the directories/files you would like checked out from Bob:

1. edit the file `.git/info/sparse-checkout`
1. run `git read-tree -mu HEAD` (note `-mu` is merge then update).

### New repository
**WARNING: INCOMPLETE-DO-NOT-BLINDLY-APPLY**
````bash
BOB_REPO=oci-jupyter-base
BOB_DIST=alpine
BOB_DIST_RELEASE=3.7

mkdir ${BOB_REPO} 
cd ${BOB_REPO}
git init
git checkout -b bob-master
git remote add bob https://github.com/taqtiqa/bob.git
git branch --set-upstream-to=bob/master
git config core.sparsecheckout true
echo scripts/${BOB_DIST}/${BOB_DIST_RELEASE}/ >> .git/info/sparse-checkout
echo another/sub/tree >> .git/info/sparse-checkout
git --depth=1 pull bob master

````

### Existing repository
**WARNING: INCOMPLETE-DO-NOT-BLINDLY-APPLY**
````bash
BOB_REPO=jupyter-base
BOB_DIST=alpine
BOB_DIST_RELEASE=3.7

cd ${BOB_REPO}
# create new branch
git checkout --orphan bob-master
rm -rf ./
rm .gitignore
#git rm --cached ./*
git remote add bob https://github.com/taqtiqa/bob.git
git branch --set-upstream-to=bob/master bob
git config core.sparsecheckout true
echo scripts/${BOB_DIST}/${BOB_DIST_RELEASE}/ >> .git/info/sparse-checkout
git pull --depth 1 bob master
git checkout master
git merge bob-master
echo scripts >>.gitignore
```` 

# License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

# Contribution

All contributions welcome for any distribution and any application. Please try to adhere to the stated conventions, or propose a change with the reasons why.

Unless you explicitly state otherwise, any contribution submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, 
shall be dual licensed as above, without any additional terms or conditions.