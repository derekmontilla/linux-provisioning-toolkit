#!/usr/bin/env bash
#          FILE:  DotSetup.sh
#         USAGE:  ./DotSetup.sh
#        AUTHOR:  Derek Montilla

set -o errexit
set -o pipefail
set -o nounset

ts=$(date +%y-%m-%d-%H-%M)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDA_DIR="$HOME/miniconda"
CONDA_SCRIPT="$HOME/miniconda.sh"
CONDA_ENV="test_env"

setup_local_bin()
{
    echo "Configuring your local bin"
    echo "*** Creating Link to $HOME/bin from $DOTFILES/bin folder"

    if [[ -L "$HOME/bin" || -d "$HOME/bin" ]]; then
        echo "*** Removing old Link"
        rm -rf "$HOME/bin"
        echo "*** Creating new Link"
    else
        echo "*** Creating Link"
    fi

    ln -s "$DOTFILES/bin" "$HOME/bin"
    chmod +x "$DOTFILES"/bin/*

    if ! grep -qF 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo "*** Adding $HOME/bin to your PATH variable in .bashrc"
        printf '\n# Added by DotSetup.sh on %s\nexport PATH="$HOME/bin:$PATH"\n' \
            "$ts" >> "$HOME/.bashrc"
    else
        echo "*** $HOME/bin already in your PATH variable in .bashrc"
    fi

    # Make the new folder visible to this shell so we can test immediately
    export PATH="$HOME/bin:$PATH"

    echo "*** Testing the local bin setup with hello_local_bin"
    if hello_local_bin; then
        echo "*** [OK] hello_local_bin ran as a local binary"
    else
        echo "*** [FAILED] could not run hello_local_bin" >&2
        return 1
    fi

    return 0
}

install_conda()
{
    echo "Installing Conda Python Environment"

    if [[ -d "$CONDA_DIR" ]]; then
        echo "*** Removing the conda folder"
        rm -rf "$CONDA_DIR"
    fi

    echo "*** Downloading the conda setup script"
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O "$CONDA_SCRIPT"

    echo "*** Installing conda"

    bash "$CONDA_SCRIPT" -b -p "$CONDA_DIR"

    set +o nounset

    source "$CONDA_DIR/etc/profile.d/conda.sh"

    echo "*** Creating a test conda environment"
    conda create --name "$CONDA_ENV" python=3.11 --yes

    echo "*** Activating the test conda environment"
    conda activate "$CONDA_ENV"

    echo "*** Installing the test conda environment"
    conda install --yes --channel conda-forge \
        --file "$DOTFILES/requirements.txt"

    echo "*** Running task2.py to verify the modules"
    python "$DOTFILES/task2.py"

    echo "*** Deactivating the test conda environment"
    conda deactivate
    set -o nounset

    echo "*** Removing the conda setup script"
    rm -f "$CONDA_SCRIPT"

    return 0
}
install_packages()
{
    echo "Installing extra build packages"

    echo "*** Updating the apt package list"
    sudo apt update

    echo "*** Installing packages from packages.txt"
    while read -r package; do

        [[ -z "$package" || "$package" == \#* ]] && continue
        echo "*** Installing $package"
        sudo apt install -y "$package"
    done < "$DOTFILES/packages.txt"

    echo "*** Verifying installed packages"
    while read -r package; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        if dpkg -s "$package" &> /dev/null; then
            version=$(dpkg-query -W -f='${Version}' "$package")
            echo "*** [OK]     $package ($version) -> $(which "$package" || echo 'no binary in PATH')"
        else
            echo "*** [FAILED] $package was not installed"
        fi
    done < "$DOTFILES/packages.txt"

    return 0
}

system_report()
{
    echo "Reading system and hardware information"

    if python3 "$DOTFILES/task4.py"; then
        echo "*** task4.py exited with code 0 (success)"
    else
        rc=$?
        echo "*** ERROR: task4.py exited with code $rc" >&2
        return 1
    fi

    return 0
}

separator()
{
    printf '%.0s-' {1..82}
    printf '\n'
}

main()
{
    # Task 1
    setup_local_bin
    separator

    # Task 2
    install_conda
    separator

    # Task 3
    install_packages
    separator

    # Task 4
    system_report
    separator

    echo "To complete your GitHub Setup run the following commnad:"
    echo "$DOTFILES gh auth login $ts"
}

main "$@" 

exit 0