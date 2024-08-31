import git
    
def main():
    repo = git.Repo('.')
    current_branch = repo.active_branch.name
    repo.git.checkout('main')
    repo.git.merge(current_branch)
    


if __name__ == '__main__':
    main()


