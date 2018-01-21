#! /bin/bash

WORKING_DIR="/opt/src"
SUBJECTS_DIR="${WORKING_DIR}/subjects"
SUBJECTS_LIST="${WORKING_DIR}/subjects-list"
DATA_DIR="${WORKING_DIR}/data"

if [ -d "${SUBJECTS_DIR}" ]; then
  rm -rf ${SUBJECTS_DIR}
fi

mkdir ${SUBJECTS_DIR}


if [ -d "${DATA_DIR}" ]; then
  rm -rf ${DATA_DIR}
fi

mkdir ${DATA_DIR}

while IFS='' read -r line || [[ -n "$line" ]]; do
  IFS='-' read -ra tokens <<< "$line"
  project=${tokens[0]}
  version=${tokens[1]}
  mkdir ${DATA_DIR}/${line}
  defects4j checkout -p ${project} -v ${version}f -w ${SUBJECTS_DIR}/${line}
  defects4j export -p classes.modified -w ${SUBJECTS_DIR}/${line} > ${DATA_DIR}/${line}/classes.modified
  defects4j mutation -w ${SUBJECTS_DIR}/${line} -r
  cp ${SUBJECTS_DIR}/${line}/mutants.log ${DATA_DIR}/${line}
  cp ${SUBJECTS_DIR}/${line}/mutants.context ${DATA_DIR}/${line}
  cp ${SUBJECTS_DIR}/${line}/*.csv ${DATA_DIR}/${line}

done < ${SUBJECTS_LIST}

chmod -R 775 ${SUBJECTS_DIR}
