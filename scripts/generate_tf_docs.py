#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path


def check_terraform_docs_installed():
    """
    Check if `terraform-docs` is installed. If not, install it using pipx.
    """
    try:
        subprocess.run(["terraform-docs", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("terraform-docs is already installed.")
    except Exception as e:
        print(f"Encountered exception when determining if terraform-docs is installed. {e} . Installing it now...")
        try:
            subprocess.run(["pip", "install", "terraform-docs"], check=True)
            print("terraform-docs installed successfully.")
        except Exception as e:
            print(f"Error installing terraform-docs: {e}")
            sys.exit(1)


def generate_documentation(module_dirs):
    """
    Use `terraform-docs` to generate documentation for the specified module directories.
    """
    for module_dir in module_dirs:
        module_path = Path(module_dir)
        if not module_path.exists():
            print(f"Module directory {module_dir} does not exist. Skipping...")
            continue

        output_file = "README.md"
        try:
            print(f"Generating documentation for {module_dir}...")
            subprocess.run(
                ["terraform-docs", "markdown", f"--output-file={output_file}", str(module_path)],
                check=True,
            )
            print(f"Documentation generated for {module_dir}: {output_file}")
        except subprocess.CalledProcessError as e:
            print(f"Error generating documentation for {module_dir}: {e}")
            sys.exit(1)


def stage_files(module_dirs):
    """
    Stage the generated README.md files for each module directory.
    """
    for module_dir in module_dirs:
        readme_file = Path(module_dir) / "README.md"
        if readme_file.exists():
            try:
                print(f"Staging {readme_file}...")
                subprocess.run(["git", "add", str(readme_file)], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Error staging {readme_file}: {e}")
                sys.exit(1)


def main():
    """
    Main entry point for the script.
    """
    # Define the module directories to process
    module_dirs = ["."]  # List of module directories within this repo. Use "." for a single repo module.

    # Ensure the script is run from the repository root
    repo_root = Path(subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip())
    os.chdir(repo_root)

    # Check if terraform-docs is installed
    check_terraform_docs_installed()

    # Generate documentation for each module
    generate_documentation(module_dirs)

    # Stage the generated README.md files
    stage_files(module_dirs)

    print("Pre-commit hook executed successfully.")
    sys.exit(0)


if __name__ == "__main__":
    main()