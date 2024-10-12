import subprocess
import sys

def run_command(command):
    result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

def main():
    print("get the version number")
    branch_name = run_command('git rev-parse --abbrev-ref HEAD')
    version_number = branch_name.lstrip('v')

    print("generate the changelog from git log")
    base_branch = run_command('git merge-base origin/main HEAD')
    logs = run_command(f'git log {base_branch}..HEAD --pretty=%B')
    log_messages = logs.split('\n\n')
    filtered_log_messages = []
    for log_message in log_messages:
        first_line = log_message.split('\n')[0]
        if first_line.startswith("feature") or first_line.startswith("fix"):
            filtered_log_messages.append(log_message)
    log_messages = filtered_log_messages

    print("write changelog")
    with open('changelog.md', 'r') as file:
        existing_contents = file.read()
    with open('changelog.md', 'w') as file:
        file.write(f'# {version_number}\n')
        for log_message in log_messages:
            file.write(f'- {log_message}\n')
        file.write('\n')  
        file.write(existing_contents)


    print("commit all changes and push to git")
    if run_command('git status --porcelain'):
        run_command('git add -A')
        run_command(f'git commit -m "release {version_number}"')
        run_command('git push origin')
    else:
        print("No changes to commit")

    print("run the commands to build the release APK and AAB")
    commands = [
        "flutter clean",
        "flutter pub get",
        "flutter build apk --release",
        "flutter build appbundle --release"
    ]
    try:
        for command in commands:
            subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while executing: {e.cmd}")
        sys.exit(1)

if __name__ == '__main__':
    main()
