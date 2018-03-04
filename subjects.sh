#! /bin/bash

WORKING_DIR="/opt/src"
SUBJECTS_DIR="${WORKING_DIR}/subjects"
SUBJECTS_LIST="${WORKING_DIR}/subjects-list"
DATA_DIR="${WORKING_DIR}/data"
USER=$(ls -ld $0 | awk '{print $3}')


optimization()
{
    echo "---------- OPTIMIZATION ----------"
    ORIGINAL_DIR="$1/mutants/ORIGINAL"
    JAVA_DIR="/usr/lib/jvm/default-jvm/"
    RT_JAR="${JAVA_DIR}jre/lib/rt.jar"
    SOOT_JAR="${WORKING_DIR}/soot/soot.jar"
    OPT_DIR="$1/soot_opt/"

    i=0

    while read -r line || [[ -n "$line" ]]; do
        CLASS_MODIFIED_DIR[i]=${line//.//}
        ((i++))
    done < $2

    if [ -d "$1/build" ]; then
        BUILD_DIR="$1/build"
    elif [ -d "$1/target" ]; then
        BUILD_DIR="$1/target"
    fi

    if [ -d "$BUILD_DIR/lib" ]; then
        LIB_DIR="${BUILD_DIR}/lib"
    fi

    if [ -d "$BUILD_DIR/classes" ]; then
        BUILD_DIR="${BUILD_DIR}/classes"
    fi


    for class_modified in ${CLASS_MODIFIED_DIR}
    do
        mkdir -p ${ORIGINAL_DIR}/${class_modified%$(echo ${class_modified} | awk -F/ '{print $NF}')}


        SRC_DIR="$1/source"

        if [ -d "$1/src" ]; then
            SRC_DIR="$1/src"
        fi

        if [ -d "$SRC_DIR/main" ]; then
            SRC_DIR="$SRC_DIR/main"
        fi

        if [ -d "$SRC_DIR/java" ]; then
            SRC_DIR="$SRC_DIR/java"
        fi

        cp ${BUILD_DIR}/${class_modified}.class ${ORIGINAL_DIR}/${class_modified}.class
        cp ${SRC_DIR}/${class_modified}.java ${ORIGINAL_DIR}/${class_modified}.java

    done

    PROJECT_CLASSPATH="${BUILD_DIR}"
    if [ -n "$LIB_DIR" ]; then
        for jar in $(ls ${LIB_DIR})
        do
            PROJECT_CLASSPATH="${PROJECT_CLASSPATH}:${LIB_DIR}/${jar}"
        done

        if [ -d "$LIB_DIR/rhino1_7R5pre" ]; then
            PROJECT_CLASSPATH="${PROJECT_CLASSPATH}:${LIB_DIR}/rhino1_7R5pre/js.jar"
        fi
    fi

    if [ -d "$1/lib" ]; then
        for jar in $(ls $1/lib/)
        do
            PROJECT_CLASSPATH="${PROJECT_CLASSPATH}:$1/lib/${jar}"
        done
    fi


    for mutant_dir in $(ls $1/mutants/)
    do
        for class_modified in ${CLASS_MODIFIED_DIR}
        do
            TARGET=$1/mutants/${mutant_dir}/${class_modified}
            DEST_DIR=${TARGET%$(echo ${TARGET} | awk -F/ '{print $NF}')}

            javac -cp "${PROJECT_CLASSPATH}" "${TARGET}.java"
            java -jar ${SOOT_JAR} -cp "${RT_JAR}:$1/mutants/${mutant_dir}:${PROJECT_CLASSPATH}" -d "${OPT_DIR}${mutant_dir}" -O "${class_modified////.}"
        done
    done

    echo "MutantNo,Status" >> "$1/tce.csv"

    for mutant_dir in $(ls ${OPT_DIR})
    do
        if [ "$mutant_dir" != "ORIGINAL" ]; then
            for class_modified in ${CLASS_MODIFIED_DIR}
            do
                if diff "${OPT_DIR}ORIGINAL/${class_modified}.class" "${OPT_DIR}${mutant_dir}/${class_modified}.class" &> /dev/null ; then
                    echo "${mutant_dir},TCE_CONFIRMED" >> "$1/tce.csv"
                else
                    echo "${mutant_dir},NOT_CONFIRMED" >> "$1/tce.csv"
                fi
            done
        fi
    done

    chown -R ${USER} ${OPT_DIR}
}



if [ ! -d "${SUBJECTS_DIR}" ]; then
  mkdir ${SUBJECTS_DIR}
fi

if [ ! -d "${DATA_DIR}" ]; then
  mkdir ${DATA_DIR}
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
  IFS='-' read -ra tokens <<< "$line"
  project=${tokens[0]}
  version=${tokens[1]}

  if [ ! -d "${DATA_DIR}/${line}" ]; then

     PROJECT_DIR=${SUBJECTS_DIR}/${line}
     PROJECT_DATA_DIR=${DATA_DIR}/${line}

     mkdir ${PROJECT_DATA_DIR}

     defects4j checkout -p ${project} -v ${version}f -w ${PROJECT_DIR}
     defects4j export -p classes.modified -w ${PROJECT_DIR} > ${PROJECT_DATA_DIR}/classes.modified
     defects4j mutation -w ${PROJECT_DIR} -r

     optimization "${PROJECT_DIR}" "${PROJECT_DATA_DIR}/classes.modified"

     cp ${PROJECT_DIR}/mutants.log ${PROJECT_DATA_DIR}
     cp ${PROJECT_DIR}/mutants.context ${PROJECT_DATA_DIR}
     cp ${PROJECT_DIR}/*.csv ${PROJECT_DATA_DIR}
     cp -r ${PROJECT_DIR}/mutants ${PROJECT_DATA_DIR}
     cp -r ${PROJECT_DIR}/soot_opt ${PROJECT_DATA_DIR}

     chown -R ${USER} ${PROJECT_DIR}
     chown -R ${USER} ${PROJECT_DATA_DIR}
  fi

done < ${SUBJECTS_LIST}


