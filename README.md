# mt - tool for working with monorepos.

[![MIT Licensed](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)
[![Powered by Modus_Create](https://img.shields.io/badge/powered_by-Modus_Create-blue.svg?longCache=true&style=flat&logo=data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMzIwIDMwMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNOTguODI0IDE0OS40OThjMCAxMi41Ny0yLjM1NiAyNC41ODItNi42MzcgMzUuNjM3LTQ5LjEtMjQuODEtODIuNzc1LTc1LjY5Mi04Mi43NzUtMTM0LjQ2IDAtMTcuNzgyIDMuMDkxLTM0LjgzOCA4Ljc0OS01MC42NzVhMTQ5LjUzNSAxNDkuNTM1IDAgMCAxIDQxLjEyNCAxMS4wNDYgMTA3Ljg3NyAxMDcuODc3IDAgMCAwLTcuNTIgMzkuNjI4YzAgMzYuODQyIDE4LjQyMyA2OS4zNiA0Ni41NDQgODguOTAzLjMyNiAzLjI2NS41MTUgNi41Ny41MTUgOS45MjF6TTY3LjgyIDE1LjAxOGM0OS4xIDI0LjgxMSA4Mi43NjggNzUuNzExIDgyLjc2OCAxMzQuNDggMCA4My4xNjgtNjcuNDIgMTUwLjU4OC0xNTAuNTg4IDE1MC41ODh2LTQyLjM1M2M1OS43NzggMCAxMDguMjM1LTQ4LjQ1OSAxMDguMjM1LTEwOC4yMzUgMC0zNi44NS0xOC40My02OS4zOC00Ni41NjItODguOTI3YTk5Ljk0OSA5OS45NDkgMCAwIDEtLjQ5Ny05Ljg5NyA5OC41MTIgOTguNTEyIDAgMCAxIDYuNjQ0LTM1LjY1NnptMTU1LjI5MiAxODIuNzE4YzE3LjczNyAzNS41NTggNTQuNDUgNTkuOTk3IDk2Ljg4OCA1OS45OTd2NDIuMzUzYy02MS45NTUgMC0xMTUuMTYyLTM3LjQyLTEzOC4yOC05MC44ODZhMTU4LjgxMSAxNTguODExIDAgMCAwIDQxLjM5Mi0xMS40NjR6bS0xMC4yNi02My41ODlhOTguMjMyIDk4LjIzMiAwIDAgMS00My40MjggMTQuODg5QzE2OS42NTQgNzIuMjI0IDIyNy4zOSA4Ljk1IDMwMS44NDUuMDAzYzQuNzAxIDEzLjE1MiA3LjU5MyAyNy4xNiA4LjQ1IDQxLjcxNC01MC4xMzMgNC40Ni05MC40MzMgNDMuMDgtOTcuNDQzIDkyLjQzem01NC4yNzgtNjguMTA1YzEyLjc5NC04LjEyNyAyNy41NjctMTMuNDA3IDQzLjQ1Mi0xNC45MTEtLjI0NyA4Mi45NTctNjcuNTY3IDE1MC4xMzItMTUwLjU4MiAxNTAuMTMyLTIuODQ2IDAtNS42NzMtLjA4OC04LjQ4LS4yNDNhMTU5LjM3OCAxNTkuMzc4IDAgMCAwIDguMTk4LTQyLjExOGMuMDk0IDAgLjE4Ny4wMDguMjgyLjAwOCA1NC41NTcgMCA5OS42NjUtNDAuMzczIDEwNy4xMy05Mi44Njh6IiBmaWxsPSIjRkZGIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz4KPC9zdmc+)](https://moduscreate.com)

- [Getting Started](#getting-started)
- [How it Works](#how-it-works)
- [Developing](#developing)
  - [Prerequisites](#prerequisites)
  - [Testing](#testing)
  - [Contributing](#contributing)
- [Modus Create](#modus-create)
- [Licensing](#licensing)

# Getting Started

The biggest reason to use monorepos for Dart projects is to share (common) custom packages between the programs also in the monorepo.

There is an obvious need for a command line tool (or tools in the IDE) to work with monorepos. The mt tool is meant to make managing monorepos easy. For example, mt can (recursively) run pub get on any package directory containing a pubspec.yaml file.

Doing recursive pub get is only one pain point of working with monorepos and Dart.

mt is designed to work on the whole monorepo or any subdirectory/subtree of it, or individual files.

While mt features a rich set of commands and options/flags for those commands, you can create a mt.yaml file within each project/package directory of your monorepo to provide additional hints or directives to be honored by mt when it runs.

## Recursive pub get

In a Dart program(s) monorepo, we may have a packages/ folder with some number of individual package directories. Each of those package directories will have its own pubspec.yaml, and we need to run pub get within.

## Bump version number

To bump a package's version number, you need to edit CHANGELOG.md and add text for the new version, you need to edit the pubspec.yaml file to have the proper version number in it.

You also may need to update several other pubspec.yaml files within the monorepo to reference the package's new version number.

You can bump the pacakge's version number: major, minor, and or point values.

## Shared packages

While working on/developing packages that you ultimately want to publish to pub.dev (pub publish), the pubspec.yaml files in your project and package directories might contain relative links to dependencies in your monorepo. But when published, you need to edit all those pubspec.yaml files and convert the relative path entries to version numbers.

The mt tool can recursively edit your pubspec.yaml files to convert to, or create, relative links or convert those links to package versions to be fetched from pub.dev.

### Published packages

When you bump a package's version number, you may want to pub publish it, too. And you then may need to update all the pubspec.yaml files that refer to it.

## Maintaining docker-compose.yml

Your monorepo might contain a number of programs to be built as Docker containers and run via docker-compose.  The mt tool can automatically maintain your docker-compose.yml file by adding or removing service definitions.

As well, you can use mt to run any or all of the containers in production or development mode.

## Create new package or program directory

The mt command can be used to generate the directory structure for a new program or package within the monorepo.

The package directory needs to have a README.md, a CHANGELOG.md, a lib/ directory, a pubspec.yaml file, a mt.yaml file, a lib/package-name.dart file, etc.

Additionally, the files need to be added to git.

## Package coverage

You can use mt to generate relative and/or pub.dev specific dependencies within all the pubspec.yaml files in the repo or subtree.

You can have mt automatically generate local dependencies by examining the import statements in the .dart files in your package/program directories.

At some point, you will want to prune any packages not used.

See https://pub.dev/documentation/pub_api_client/latest/


## Prerequisites
Docker is used by the RoboDomo samples.

## Contributing

PRs welcome.  Fork this repository, create a branch to do your work, and when ready, make a PR from your branch.

# Modus Create


[Modus Create](https://moduscreate.com) is a digital product consultancy. We use a distributed team of the best talent in the world to offer a full suite of digital product design-build services; ranging from consumer facing apps, to digital migration, to agile development training, and business transformation.

<a href="https://moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=dart-samples"><img src="https://res.cloudinary.com/modus-labs/image/upload/h_80/v1533109874/modus/logo-long-black.svg" height="80" alt="Modus Create"/></a>
<br />

This project is part of [Modus Labs](https://labs.moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=dart-samples).

<a href="https://labs.moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=dart-samples"><img src="https://res.cloudinary.com/modus-labs/image/upload/h_80/v1531492623/labs/logo-black.svg" height="80" alt="Modus Labs"/></a>

# Licensing

This project is [MIT licensed](./LICENSE).
