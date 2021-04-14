# Contribute to phpBB Documentation

Do you have an improvement, bug fix or translation for our Docs?

## Contents:
1. [Fork and Clone](#fork-and-clone)
2. [Create a Branch](#create-a-branch)
3. [Submit a Pull Request](#submit-a-pull-request)
4. [Build Development Docs](#build-development-docs)

## Fork and Clone

1. On GitHub, create a fork of `phpbb/documentation` to your GitHub account.

2. Create a local clone of your fork:
```shell
$ git clone git://github.com/YOUR_GITHUB_NAME/documentation.git
```

## Create a Branch

1. Create a new branch in your repository before doing any work. It should be based off the branch you intend to update:
```shell
$ git checkout -b myNewbranch origin/master
```

2. Do work on your branch, commit your changes and push it to your repository:
```shell
$ git commit -a -m "My new feature or bug fixes"
$ git push origin myNewbranch
```

## Submit a Pull Request

1. Go to your repository on GitHub.com.

2. Click the Pull Request button.

3. Make sure the correct branch is selected in the base branch dropdown menu.

## Build Development Docs

You can build our Development Docs in your local environment to make it easier when writing new or updated
documentation. The following steps may vary slightly depending on your OS, so if you run into any trouble you may
ask for guidance in our [Discord or IRC Channels](https://www.phpbb.com/support/chat/).

1. Make sure you have Python3 installed (you can check by running `$ python -V`)

2. Make sure your have PIP installed (you can check by running `$ pip -V`)

3. Install [Sphinx Docs](https://www.sphinx-doc.org/en/master/usage/installation.html):
    ```shell
    $ pip install -U sphinx
    ```

4. Verify Sphinx installed:
   ```shell
   $ sphinx-build --version
   ```
   > You may need to set a shell $PATH variable to point to wherever your Sphinx binaries were installed in your system

5. Install all the dependencies needed for our Docs:
    ```shell
    $ pip install sphinx_rtd_theme
    $ pip install sphinxcontrib-phpdomain
    $ pip install sphinx-multiversion
    $ sudo pip install git+https://github.com/marc1706/sphinx-php.git
    ```

6. Build the Docs
    ```shell
    $ cd development
    $ make html
    ```

7. You can now view the Docs by pointing a browser to `development/_build/html/index.html`
