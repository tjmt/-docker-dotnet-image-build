FROM microsoft/dotnet:2.1-sdk

#---------Argumentos
ARG TimeZone="America/Cuiaba"
ARG SONAR_SCANNER_DOTNET_VERSION="4.4.2"
ARG COVERLET_CONSOLE_VERSION="1.2.1"
ARG NUGET_SOURCE_EXTERNO="https://api.nuget.org/v3/index.json"
ARG NUGET_SOURCE_INTERNO
ARG HTTP_PROXY
ARG HTTP_PROXY_USER
ARG HTTP_PROXY_PASSWORD

#---------Configura o TimeZone
RUN ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime \
    && echo $TimeZone > /etc/timezone

#---------Instalando ferramentas
RUN dotnet tool install --global coverlet.console --version ${COVERLET_CONSOLE_VERSION}
RUN dotnet tool install --global dotnet-sonarscanner --version ${SONAR_SCANNER_DOTNET_VERSION}
ENV PATH "$PATH:/root/.dotnet/tools/"

#---------Copiando arquivos sh para dentro da imagem
COPY ./entrypoint-ci /entrypoint-ci
COPY ./sh /utils
RUN chmod +x /entrypoint-ci/continuous-integration.sh \
            /entrypoint-ci/wait-for-it.sh \
            /utils/nuget-config-creator.sh \
            /utils/copy-project-structure.sh

#---------Criando o arquivo Nuget.config
RUN /utils/nuget-config-creator.sh

#Variaveis de ambiente com valores padrões. É possivel mudar estes valores, informando no docker run ou no docker-compose
ENV COVERAGE_PATH="/TestResults/codecoverage"
ENV RESULT_PATH="/TestResults/result"


#---------COMANDOS ONBUILD (serão rodados no Dockerfile de quem herdar desta imagem)

#Argumentos para o build
ONBUILD ARG CONFIGURATION="Release"
ONBUILD ARG SOLUTION_NAME=""
ONBUILD ARG PATHS

#Criando variaveis de ambientes com os argumentos, necessário para rodar o CI (entrypoint)
ONBUILD ENV CONFIGURATION=$CONFIGURATION
ONBUILD ENV SOLUTION_NAME=$SOLUTION_NAME

#Criando estrutura final de pasta
ONBUILD RUN mkdir /app \ 
&& mkdir /packages \ 
&& mkdir /TestResults

#Copiando arquivos para dentro do estágio build
ONBUILD WORKDIR /src

ONBUILD COPY . .
ONBUILD RUN /utils/copy-project-structure.sh

#Restaurando pacotes nuget da solução
ONBUILD RUN if [ "${SOLUTION_NAME}" = "" ]; then \  
                dotnet restore -v m; \
            else \
                dotnet restore ${SOLUTION_NAME} -v m; \
            fi

#Buildando solução
ONBUILD RUN if [ "${SOLUTION_NAME}" = "" ]; then \  
                dotnet build -c ${CONFIGURATION} --no-restore -v m; \
            else \
                dotnet build ${SOLUTION_NAME} -c ${CONFIGURATION} --no-restore -v m; \
            fi