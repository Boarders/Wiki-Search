#!/bin/bash

usage() {
  cat <<-ENDOFUSAGE
Usage: $(basename $0) [OPTION] [SEARCH QUERY]
  -i [query]     Displays the introduction to the wiki page
  -c [query]     Displays the contents of the wiki page

Example:

Notes:

ENDOFUSAGE
  exit
}

function lookupWikiPage {
#    echo "looking up "${@:·-0}""
    topic_spaces="${@: -0}"
    # replace spaces with underscores in input
    topic_underscores=$(echo ${topic_spaces} | sed 's@\ @_@g')
    resp_full=$(wget -O- "https://en.wikipedia.org/wiki/${topic_underscores}?action=raw")
    # Remove all internal wiki syntax between {{ and }}
    resp_remove_syntax=$(echo "${resp_full}" | sed -e 's@\([{{][^}]*[}]*\)@@g')
    # Remove all [[ and ]] symbols. Note if the linked page is named differently than
    # the link it will appear as [[name of linked page | link ]] and so we deal with
    # that first
    resp_remove_links=$(echo "${resp_remove_syntax}" |
                        sed -e 's@\(['\[''\['][^'\]''\|']*['\|']\)@@g' |
                        sed -e 's@\(['\[''\[']\)@@g' |
                        sed -e 's@\(['\]''\]']\)@@g')
    echo "${resp_remove_links}"

    #TODO: remove images properly first in above parsing
    #      remove hrefs
}
function lookupIntro {
    response=$(lookupWikiPage "${@: -0}")
    section_mark="\=\="
    # Get everything before == Section marker
    response_intro=$(echo "${response}" | sed -e '/==/q' | sed \$d | head -n 20)
    echo "${response_intro}"
    }


while getopts 'hi:c:' flag; do
  case ${flag} in
    h)
      # help
      usage
      exit 1
      ;;
    i)
      # introduction
        lookupIntro ${OPTARG}
        echo "here"
      exit 1
      ;;
    c)
      # contents
      lookupWikiPage ${OPTARG}
      ;;
    *)
      # Unknown flag
      echo "unknown argument ${flag}"
      exit 1
      ;;
  esac
done
