import subprocess
import sys
from pathlib import Path

def is_terraform_installed():
    """
    Check if Terraform is installed.
    """
    try:
        result = subprocess.run(
            ["terraform", "--version"], 
            check=True, 
            stdout=subprocess.DEVNULL, 
            stderr=subprocess.DEVNULL
        )
        print("Terraform is installed.")
        return True
    except FileNotFoundError:
        print("Terraform is not installed: command not found.")
        return False
    except subprocess.CalledProcessError as e:
        print(f"Terraform installation check failed with exit code {e.returncode}.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False


def format_terraform_files(files):
    """
    Run `terraform fmt` on the specified Terraform files.
    """
    modified_files = []
    for file in files:
        try:
            print(f"Formatting {file}...")
            result = subprocess.run(
                ["terraform", "fmt", "-write=true", str(file)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            if result.returncode == 0:
                print(result.stdout.strip())
                modified_files.append(file)
            else:
                print(f"Error formatting {file}: {result.stderr.strip()}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to format {file}: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            sys.exit(1)
    return modified_files


def stage_files(files):
    """
    Stage the specified files using `git add`.
    """
    for file in files:
        try:
            print(f"Staging {file}...")
            subprocess.run(["git", "add", str(file)], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error staging {file}: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            sys.exit(1)


def main():
    # Check if Terraform is installed
    if not is_terraform_installed():
        sys.exit(1)

    # Get the list of staged Terraform files
    try:
        staged_files_output = subprocess.run(
            ["git", "diff", "--cached", "--name-only", "--diff-filter=ACM"],
            stdout=subprocess.PIPE,
            check=True,
            text=True,
        ).stdout.splitlines()
        # Filter for `.tf` files
        terraform_files = [Path(file) for file in staged_files_output if file.endswith(".tf")]
        if not terraform_files:
            print("No Terraform files to format.")
            sys.exit(0)
    except subprocess.CalledProcessError as e:
        print(f"Error in identifying staged terraform files: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred while identifying staged terraform files: {e}")
        sys.exit(1)

    # Format the Terraform files
    modified_files = format_terraform_files(terraform_files)

    # Stage the modified files
    if modified_files:
        stage_files(modified_files)
        print("Terraform files formatted and staged successfully.")
    else:
        print("No changes were made to the Terraform files.")

    sys.exit(0)


if __name__ == "__main__":
    main()