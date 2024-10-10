#!/bin/bash

# null 문자열을 'latest'로 설정
: ${VELOCITY_VERSION:='3.3.0-SNAPSHOT'}
: ${BUILD:='latest'}
: ${MC_RAM:='512M'}
: ${JAVA_OPTS:=''}

while getopts "m:" opt; do
  case ${opt} in
    m)
      MC_RAM=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      ;;
  esac
done


# 버전 정보를 가져오고 다운로드 URL과 jar 이름 생성
URL='https://papermc.io/api/v2/projects/velocity'
if [[ $VELOCITY_VERSION == latest ]]
then
  # 최신 버전 가져오기
  VELOCITY_VERSION=$(wget -qO - "$URL" | jq -r '.versions[-1]')
fi

# 최신 빌드 가져오기
URL="${URL}/versions/${VELOCITY_VERSION}"
BUILD=$(wget -qO - "$URL" | jq '.builds[-1]')

JAR_NAME="velocity-${VELOCITY_VERSION}-${BUILD}.jar"
URL="${URL}/builds/${BUILD}/downloads/${JAR_NAME}"

if [[ ! -e $JAR_NAME ]]
then
  # 이전 서버 jar 파일 제거
  rm -f *.jar
  # 새 서버 jar 다운로드
  wget "$URL" -O "$JAR_NAME"
fi

if [[ -n $MC_RAM ]]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

exec java -server $JAVA_OPTS -jar "$JAR_NAME" nogui