#!/usr/bin/env bash
sh scripts/test/download.sh
sh scripts/test/lsp.sh src
selene src

