# Github SemVer Automatic Release
This action automatically creates a compliant semver release, by generating a changelog from your commits. 
It automatically manages the MAJOR, MINOR and PATCH version numbers, depending on the input provided.

## Contents

1. [🚀 Usage Examples](#usage-examples)
1. [💻 Input Parameters](#input-parameter)
1. [🏷 Versioning](#versioning)
1. [🔐 Security](#security)
1. [📜 License](#license)

## Usage Examples
### Manually release your software and decide which version to increment
``` yml
---
name: "Release"

on:
  workflow_dispatch:
    inputs:
      semver:
        description: 'Which version you want to increment? Use MAJOR, MINOR or PATCH'
        required: true
        default: 'PATCH'
      label:
        description: 'Add Labels. i.e final, alpha, rc'
        required: false
        default: ''

jobs:
  release:
    name: "Release"
    runs-on: "ubuntu-latest"

    steps:
      # Checkout sources
      - name: "Checkout"
        uses: actions/checkout@v2
    
      # ...
      - name: "👷‍♂️ Build"
        run: |
          echo "BUILD COMPLETE 👍"

      # ...
      - name: "🧪 TEST"
        run: |
          echo "TESTS PASSED 🎉"

      - uses: "rui-costa/action-automatic-semver-releases@latest"
        with:
          SEMVER: "${{ github.event.inputs.semver }}" 
          LABEL:  "${{ github.event.inputs.label }}"
```


## Input Parameters
Below is a list of all supported input parameters
| Parameter | Description | Required | Default |
| - | - | - | - | 
| TOKEN | Secret token from GitHub. secrets.GITHUB_TOKEN | YES | _null_ |
| SEMVER | Which version you want to increment? Use MAJOR, MINOR or PATCH | __NO__ | __PATCH__ |
| LABEL | Add Labels. i.e final, alpha, rc | NO | _null_ |
| MAIN_BRANCH | The name of your main branch | NO | main |
| CHANGELOG_FORMAT | Format of the line to appear on the changelog. [View format](https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History#pretty_format)  | NO | - [[%h]\(https://www.github.com//<<GITHUB_REPOSITORY>>/commit/%H)]: %s\n |


## Versioning
All commits to `main` will generate a new `PATCH` version of this action. If you want to use the most recent one, keep the `@latest` tag.

## Security
Security is a very important topic. As explained in the bullet above, any changes will generate a new tag. But even by tagging a specific version you can never be 100% sure of the code that will run on your workflow. 
If you don't trust the code that will be execute, don't worry, there are other ways.
- You can fork the repo for yourself and use it, validate the code and use it as is. Or,
- You can copy the workflow `resources/release.yml` into your repo and get the same value from this GitHub action. There is no reference to any third-party actions or software.
> ___Disadvantage:___ If you opt by the `resources/release.yml` approach, you will not receive any updates when new features are released.

## License
The source code for this project is released under the [MIT License](https://mit-license.org/).