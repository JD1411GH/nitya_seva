import git
import subprocess
import sys

def main():
    repo = git.Repo('.')
    

    print("get the version number")
    branch_name = repo.active_branch.name
    version_number = branch_name.lstrip('v')

    print("generate the changelog from git log")
    logs = repo.git.log('--pretty=%B', f'{branch_name}..HEAD')
    log_messages = logs.split('\n\n')
    filtered_log_messages = []
    for i, log_message in enumerate(log_messages):
        first_line = log_message.split('\n')[0]
        word_count = len(first_line.split())
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
    if repo.is_dirty(untracked_files=True):
        repo.git.add(A=True)
        repo.index.commit(f'release {version_number}')
        origin = repo.remote(name='origin')
        origin.push()
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