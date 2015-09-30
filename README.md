# octohook

Manipulating Jenkins and friends with GitHub Webhooks.

# License
[MIT](https://tldrlegal.com/license/mit-license)

# Contributors
  * [Chris Olstrom](https://colstrom.github.io/) | [e-mail](mailto:chris@olstrom.com) | [Twitter](https://twitter.com/ChrisOlstrom)

# Architecture
receiver -> identifier -> dispatcher -> reporter
overseer stands off to the side and cleans up queues and stuff and provides some visibility: https://overseer.domain.com/

