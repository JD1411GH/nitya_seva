- Raise PR to merge version branch to main
    - https://github.com/JD1411GH/nitya_seva
    - merge PR
- Draft a new release in github
    - https://github.com/JD1411GH/nitya_seva/releases/new
    - apply release tag to main
    - give release title e.g. 2.0.0
    - upload apk from `build\app\outputs\flutter-apk\app-release.apk`
    - publish release. mark as pre-release if all changes are not tested.
- release in play store for internal testing
    - https://play.google.com/console/u/1/developers/6521479509564445390/app/4972540978463446215/tracks/internal-testing
    - Create new release
        - https://play.google.com/console/u/1/developers/6521479509564445390/app/4972540978463446215/tracks/4701310773386831062/releases/16/prepare
    - upload the app bundle from `build\app\outputs\bundle\release\app-release.aab`
