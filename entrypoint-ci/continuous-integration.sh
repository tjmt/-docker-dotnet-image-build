#!/bin/bash

dotnet sonarscanner begin /k:"${PROJECT_NAME}" /v:"${PROJECT_VERSION}" /d:sonar.verbose=true /d:sonar.cs.opencover.reportsPaths="${COVERAGE_PATH}/**/coverage.opencover.xml" /d:sonar.cs.vstest.reportsPaths="${RESULT_PATH}/*.trx"

dotnet build ${SOLUTION_NAME} -c ${CONFIGURATION} --no-restore -v m

for testFolder in $(ls test); do \
    dotnet test test/$testFolder --no-build -c ${CONFIGURATION} -r "${RESULT_PATH}/" -l "trx;LogFileName=${testFolder}.trx"; exit 0 & \
    coverlet test/${testFolder}/bin/${CONFIGURATION}/*/${testFolder}.dll --target "dotnet" --targetargs "test test/${testFolder} --no-build -c ${CONFIGURATION}" --format opencover --format cobertura --output "${COVERAGE_PATH}/${testFolder}/"; \
done;

dotnet sonarscanner end