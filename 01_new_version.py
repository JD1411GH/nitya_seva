import sys
import subprocess
import sys

def branch_exists(branch_name):
    """Check if a branch exists locally."""
    result = subprocess.run(["git", "branch", "--list", branch_name], capture_output=True, text=True)
    return branch_name in result.stdout

def create_or_switch_branch(new_branch, latest_branch):
    """Create a new branch """
    subprocess.check_output(["git", "checkout", "-b", new_branch, latest_branch])
    print(f"Created and switched to new branch: {new_branch}")

def main():
    # Prompt for version type
    version_type = input("Enter version type (1. major, 2. minor, 3. bugfix): ")

    # Set the version variable based on user input
    if version_type == "1":
        version = "major"
    elif version_type == "2":
        version = "minor"
    elif version_type == "3":
        version = "bugfix"
    else:
        print("Invalid version type")
        sys.exit(1)

    # Get the latest remote branch
    try:
        output = subprocess.check_output(["git", "ls-remote", "--heads", "origin"]).decode("utf-8")
        branches = [line.split("\t")[1].split("refs/heads/")[1] for line in output.splitlines()]
        latest_branch = max(branches)
    except subprocess.CalledProcessError:
        print("Failed to retrieve remote branches")

    # Increment the version number based on user selection
    if version == "major":
        # Split the latest branch version into major, minor, and bugfix parts
        major, minor, bugfix = latest_branch[1:].split(".")
        # Increment the major version and reset minor and bugfix to 0
        major = str(int(major) + 1)
        minor = "0"
        bugfix = "0"
    elif version == "minor":
        # Split the latest branch version into major, minor, and bugfix parts
        major, minor, bugfix = latest_branch[1:].split(".")
        # Increment the minor version and reset bugfix to 0
        minor = str(int(minor) + 1)
        bugfix = "0"
    elif version == "bugfix":
        # Split the latest branch version into major, minor, and bugfix parts
        major, minor, bugfix = latest_branch[1:].split(".")
        # Increment the bugfix version
        bugfix = str(int(bugfix) + 1)

    # Create the new branch name
    new_branch = f"v{major}.{minor}.{bugfix}"

    # Read the value of the 'version' key from pubspec.yaml
    with open('pubspec.yaml', 'r') as file:
        lines = file.readlines()
        for line in lines:
            if line.startswith('version:'):
                version = line.split(':')[1].strip()
                break
    revision = version.split('+')[-1]
    revision = str(int(revision) + 1)

    # Check if --dry_run option is set
    if "--dry_run" not in sys.argv:
        # Checkout a new branch based on the latest branch
        try:
            create_or_switch_branch(new_branch, latest_branch)
            print("New branch created:", new_branch)

            # Update the version in pubspec.yaml
            with open('pubspec.yaml', 'w') as file:
                for line in lines:
                    if line.startswith('version:'):
                        file.write(f'version: {new_branch[1:]}+{revision}\n')  # Remove the 'v' prefix
                    else:
                        file.write(line)

        except subprocess.CalledProcessError:
            print("Failed to create new branch")
    
        # Set the remote for the new branch
        try:
            subprocess.check_output(["git", "push", "-u", "origin", new_branch])
            print("Remote set for new branch")
        except subprocess.CalledProcessError:
            print("Failed to set remote for new branch")

if __name__ == "__main__":
    main()