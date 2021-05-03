## This Source Code Form is subject to the terms of the Mozilla Public
## License, v. 2.0. If a copy of the MPL was not distributed with this
## file, You can obtain one at https://mozilla.org/MPL/2.0/.

# shellcheck shell=sh

NPM_DIR="${HOME}/.npm"
if [ -d "$NPM_DIR" ] ; then
	export PATH="${NPM_DIR}/bin:${PATH}"
#	export MANPATH="${NPM_DIR}/share/man:$(manpath)"
	export NODE_PATH="${NPM_DIR}/lib/node_modules:${NODE_PATH}"
fi
