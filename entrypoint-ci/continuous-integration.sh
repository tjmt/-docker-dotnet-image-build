#!/bin/bash

echo "Variaveis de ambiente"
printenv

if [[ ${SONAR_HOST_URL} != "" ]]; then
    echo "Iniciando sonarscanner" & \
    dotnet sonarscanner begin /k:"${PROJECT_NAME}" /v:"${PROJECT_VERSION}" /d:sonar.login="${SONAR_LOGIN}" /d:sonar.host.url="${SONAR_HOST_URL}" /d:sonar.verbose=true /d:sonar.cs.opencover.reportsPaths="${COVERAGE_PATH}/**/coverage.opencover.xml" /d:sonar.cs.vstest.reportsPaths="${RESULT_PATH}/*.trx"
fi

if [[ ${SOLUTION_NAME} != "" ]]; then
    echo "Iniciando dotnet build informando a solution" & \
    dotnet build ${SOLUTION_NAME} -c ${CONFIGURATION} --no-restore -v m
else
    echo "Iniciando dotnet build" & \
    dotnet build -c ${CONFIGURATION} --no-restore -v m
fi

echo "########## Iniciando testes ##########"

for testFolder in $(ls test); do \
    echo $testFolder

    echo '------dotnet test------' & \
    dotnet test test/$testFolder --no-build -c ${CONFIGURATION} -r "${RESULT_PATH}/" -l "trx;LogFileName=${testFolder}.trx"; exit 0 & \

    echo '------coverlet test------' & \
    coverlet test/${testFolder}/bin/${CONFIGURATION}/*/${testFolder}.dll --target "dotnet" --targetargs "test test/${testFolder} --no-build -c ${CONFIGURATION}" --format opencover --format cobertura --output "${COVERAGE_PATH}/${testFolder}/"; \
done;

if [[ ${SONAR_HOST_URL} != "" ]]; then
    echo "Finalizando sonarscanner" & \
    dotnet sonarscanner end /d:sonar.login="${SONAR_LOGIN}"
fi